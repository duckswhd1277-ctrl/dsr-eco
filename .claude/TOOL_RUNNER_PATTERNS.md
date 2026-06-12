# Tool Runner Patterns 구현 가이드

**기술 스택**: Claude SDK Tool Runner (Beta)
**난이도**: Advanced
**특징**: SDK가 자동으로 루프 관리

---

## 개요

Tool Runner는 SDK의 자동 루프 관리 기능을 사용합니다.
각 Specialized Agent(Issue Writer, Issue Runner, Doc Optimizer)가 이 패턴을 따릅니다.

```
Manual Agentic Loop (Coordinator)
    ↓
Coordinator가 subagent 호출
    ↓
Subagent가 Tool Runner로 실행
    ↓ SDK가 자동으로 loop 관리
Tool use → execution → response → next tool?
    ↓
Coordinator가 결과 수신
```

---

## 패턴 1: Issue Writer (Analyzer)

### 역할
프로젝트 코드를 분석하여 개선점을 GitHub Issues 형식으로 구조화.

### 도구
- `code_execution` - Python 코드 실행 및 파일 분석
- `web_fetch` - 프로젝트 문서 읽기
- `memory` - 과거 분석 기록 참고 (context enrichment)

### 구현

#### 1. System Prompt 정의

```python
ISSUE_WRITER_SYSTEM_PROMPT = """
당신은 GitHub Issues 분석 및 작성 전문가입니다.

# 역할
코드를 분석하여 다음 유형의 이슈를 발견:
1. 🐛 Bugs: 잠재적 버그 및 에러 처리 누락
2. ✨ Features: 누락된 기능 또는 개선 기회
3. ♻️ Refactoring: 코드 품질 개선 기회
4. 📚 Documentation: 문서화 부족
5. 🧪 Testing: 테스트 커버리지 부족

# 도구 사용 워크플로우

## Step 1: 코드 구조 파악 (code_execution)
Python으로 다음을 분석:
- 파일 구조: os.listdir, Path.glob
- 코드 복잡도: 함수/클래스 개수
- 의존성: import 분석

## Step 2: 핵심 파일 읽기 (code_execution)
- 메인 파일 읽기: open(file).read()
- 라인 수, 함수 개수 집계

## Step 3: 문서 조회 (web_fetch)
- README.md, soul.md, CLAUDE.md 읽기
- 문서 최신성 확인

## Step 4: 이슈 구조화
각 이슈는 반드시 포함:
{
    "id": "issue-{number:03d}",
    "type": "bug|feature|refactor|docs|test",
    "title": "명확한 제목 (동사로 시작, 10-50글자)",
    "description": "Problem / Current State / Expected Behavior",
    "priority": "high|medium|low",
    "estimated_effort": "1h|2h|4h|8h",
    "acceptance_criteria": ["...", "..."],
    "confidence": 0.9  # 0.0~1.0
}

# 성공 기준
✅ 각 이슈는 실행 가능해야 함 (SMART 원칙)
✅ 재현 단계가 명확하거나 필요 없음
✅ 수용 기준이 측정 가능함
✅ confidence >= 0.8

# 출력 형식
JSON 배열로 모든 이슈를 반환:
[
    { issue object },
    { issue object },
    ...
]

최소 1개, 최대 10개 이슈.
"""
```

#### 2. Tool Runner 호출

```python
from anthropic import Anthropic

def run_issue_writer(project_context: str) -> List[Dict]:
    """
    Issue Writer Tool Runner 실행
    
    Args:
        project_context: 분석 대상 프로젝트 설명
    
    Returns:
        findings: 발견된 이슈 목록
    """
    
    client = Anthropic()
    
    # Tool Runner 실행 (SDK가 루프 관리)
    response = client.beta.messages.tool_runner.create(
        model="claude-opus-4-8",
        max_tokens=4000,
        thinking={"type": "adaptive"},
        system=ISSUE_WRITER_SYSTEM_PROMPT,
        tools=[
            {
                "type": "code_execution",
                "name": "python"
            },
            {
                "type": "web_fetch"
            },
            {
                "type": "memory",
                "mode": "read",
                "path": "/analysis-history/"
            }
        ],
        messages=[
            {
                "role": "user",
                "content": f"""
                다음 프로젝트를 분석하고 개선 이슈를 찾아주세요:
                
                {project_context}
                
                과거 분석 기록도 참고하여 중복을 피하세요.
                새로운 이슈만 추가하세요.
                """
            }
        ]
    )
    
    # 응답에서 이슈 추출
    findings = _extract_findings_from_response(response)
    return findings

def _extract_findings_from_response(response) -> List[Dict]:
    """응답 파싱"""
    import json
    import re
    
    # Tool Runner 응답에서 텍스트 추출
    text = response.content[-1].text if response.content else ""
    
    # JSON 블록 찾기
    json_match = re.search(r'\[[\s\S]*?\]', text)
    if json_match:
        try:
            findings = json.loads(json_match.group())
            # 유효성 검증
            return [f for f in findings if f.get("confidence", 0) >= 0.8]
        except json.JSONDecodeError:
            return []
    
    return []
```

#### 3. Memory 통합 (이전 분석 참고)

```python
def enrich_with_memory(findings: List[Dict], memory_path: str) -> List[Dict]:
    """
    과거 분석 결과와 비교하여 중복 제거
    """
    
    # Memory에서 이전 이슈 로드
    # previous_findings = memory_tool.read(memory_path)
    
    # 이전 이슈의 ID 목록
    # previous_ids = {f["title"] for f in previous_findings}
    
    # 새로운 이슈만 필터링
    # new_findings = [f for f in findings if f["title"] not in previous_ids]
    
    # Memory에 저장
    # memory_tool.write(memory_path, findings)
    
    return findings
```

---

## 패턴 2: Issue Runner (Executor)

### 역할
GitHub Issues를 실행하고 코드를 수정, 테스트, 커밋.

### 도구
- `bash` - git, gh CLI, 일반 쉘 명령
- `code_execution` - Python으로 실제 구현
- `memory` - 진행 상황 기록

### 구현

#### 1. System Prompt

```python
ISSUE_RUNNER_SYSTEM_PROMPT = """
당신은 GitHub Issues 실행 전문가입니다.

# 역할
다음 워크플로우로 Issue를 완료:

1. Issue 상태 확인 (bash: gh issue view)
2. 브랜치 생성 (bash: git checkout -b feature/issue-{id})
3. 코드 수정 (code_execution: 파일 수정)
4. 테스트 (code_execution: 테스트 실행)
5. Commit (bash: git commit -m "fix(#{id}): ...")
6. Push (bash: git push origin feature/issue-{id})
7. Issue 상태 업데이트 (bash: gh issue edit {id} --state open)

# 에러 처리

## Conflict 발생
```bash
git diff
git rebase origin/main
# 수동 해결 필요 → user 통지
```

## 테스트 실패
```bash
git reset --soft HEAD~1
# 수정 후 재커밋
```

## 구현 불가능
```bash
gh issue comment {id} -b "구현 불가능한 이유: ..."
```

# 출력 형식
{
    "issue_id": "issue-001",
    "status": "success|failed|partial",
    "commits": ["abc123", "def456"],
    "test_results": {
        "passed": 10,
        "failed": 0,
        "skipped": 1
    },
    "artifacts": [
        "modified: src/file.py",
        "created: tests/test_file.py"
    ]
}
"""
```

#### 2. Tool Runner 호출

```python
def run_issue_runner(issue: Dict) -> Dict:
    """
    Issue Runner Tool Runner 실행
    
    Args:
        issue: 실행할 이슈
    
    Returns:
        completion: 실행 결과
    """
    
    client = Anthropic()
    
    execution_prompt = f"""
    다음 Issue를 실행해주세요:
    
    Issue ID: {issue['id']}
    Title: {issue['title']}
    Description: {issue['description']}
    Priority: {issue['priority']}
    
    다음을 완료하세요:
    1. 코드 수정
    2. 테스트 작성/실행
    3. Git commit 및 push
    4. GitHub Issue 상태 업데이트
    
    모든 단계를 완료하면 JSON 형식으로 결과 보고.
    """
    
    response = client.beta.messages.tool_runner.create(
        model="claude-opus-4-8",
        max_tokens=8000,
        thinking={"type": "adaptive"},
        system=ISSUE_RUNNER_SYSTEM_PROMPT,
        tools=[
            {
                "type": "bash"
            },
            {
                "type": "code_execution",
                "name": "python"
            },
            {
                "type": "memory",
                "mode": "write",
                "path": "/executions/"
            }
        ],
        messages=[
            {
                "role": "user",
                "content": execution_prompt
            }
        ]
    )
    
    completion = _extract_completion_from_response(response)
    return completion
```

#### 3. Rollback 메커니즘

```python
def rollback_issue(issue_id: str, git_sha: str):
    """
    이슈 실행 실패 시 롤백
    """
    
    import subprocess
    
    # 1. Git 롤백
    subprocess.run(
        ["git", "reset", "--hard", git_sha],
        check=True
    )
    print(f"✅ Git 롤백: {git_sha}")
    
    # 2. Issue 상태 복구
    subprocess.run(
        ["gh", "issue", "comment", issue_id, 
         "-b", "❌ 실행 실패: 롤백되었습니다."],
        check=True
    )
```

---

## 패턴 3: Doc Optimizer (Documentarian)

### 역할
프로젝트 문서를 검토하고 최신화.

### 도구
- `web_fetch` - 현재 문서 읽기
- `bash` - git, 파일 작업
- `code_execution` - 링크 검증, 문서 변환

### 구현

#### 1. System Prompt

```python
DOC_OPTIMIZER_SYSTEM_PROMPT = """
당신은 기술 문서 최적화 전문가입니다.

# 검토 대상 문서
1. README.md
   - 최신 기능 설명
   - 사용 방법 명확성
   - 링크 유효성

2. soul.md
   - 아키텍처 설명 최신성
   - 기술 결정 문서화
   - 변경사항 반영

3. CLAUDE.md
   - AI 협업 가이드 적절성
   - 워크플로우 변경사항
   - 예제 정확성

4. 일반
   - 마크다운 형식 일관성
   - 헤더 계층 구조
   - 코드 블록 유효성

# 작업 워크플로우

## Step 1: 문서 읽기 (web_fetch)
- README.md 내용
- soul.md 내용
- CLAUDE.md 내용

## Step 2: 링크 검증 (code_execution)
Python으로 모든 마크다운 링크 검증:
```python
import re
import os

def check_links(content):
    links = re.findall(r'\[.*?\]\((.*?)\)', content)
    for link in links:
        if link.startswith('./') or link.startswith('/'):
            path = os.path.exists(link)
            print(f"{link}: {'✅' if path else '❌'}")
```

## Step 3: 문서 업데이트
필요한 변경사항 나열:
{
    "file": "README.md",
    "changes": [
        "- 새로운 기능 추가됨",
        "- 사용 예제 개선됨"
    ],
    "status": "updated|skipped",
    "reason": "스킵한 이유"
}

## Step 4: Git Commit
```bash
git add README.md soul.md
git commit -m "docs: 문서 최신화"
git push origin main
```

# 출력 형식
[
    {
        "file": "README.md",
        "changes": [...],
        "status": "updated",
        "commit": "abc123"
    }
]
"""
```

#### 2. Tool Runner 호출

```python
def run_doc_optimizer(recent_changes: List[Dict]) -> List[Dict]:
    """
    Doc Optimizer Tool Runner 실행
    
    Args:
        recent_changes: 최근 코드 변경사항
    
    Returns:
        doc_updates: 문서 업데이트 결과
    """
    
    client = Anthropic()
    
    doc_prompt = f"""
    다음 변경사항이 발생했습니다:
    
    {json.dumps(recent_changes, indent=2)}
    
    프로젝트 문서를 검토하고 필요한 부분을 업데이트하세요:
    
    1. README.md - 새로운 기능 반영
    2. soul.md - 아키텍처 변경사항 기록
    3. CLAUDE.md - 워크플로우 변경사항
    4. 모든 링크 유효성 검증
    
    각 문서에 대해 다음 형식으로 보고:
    {{
        "file": "파일명",
        "changes": ["변경사항1", "변경사항2"],
        "status": "updated|skipped",
        "reason": "선택사항"
    }}
    """
    
    response = client.beta.messages.tool_runner.create(
        model="claude-opus-4-8",
        max_tokens=4000,
        thinking={"type": "adaptive"},
        system=DOC_OPTIMIZER_SYSTEM_PROMPT,
        tools=[
            {
                "type": "web_fetch"
            },
            {
                "type": "bash"
            },
            {
                "type": "code_execution",
                "name": "python"
            }
        ],
        messages=[
            {
                "role": "user",
                "content": doc_prompt
            }
        ]
    )
    
    doc_updates = _extract_doc_updates_from_response(response)
    return doc_updates
```

---

## 공통 패턴: Tool Runner 응답 처리

### 패턴

```python
def handle_tool_runner_response(response):
    """
    Tool Runner 응답 처리
    
    Tool Runner는 SDK가 자동으로 루프를 관리하므로,
    우리가 받는 응답은 최종 결과(JSON 형식)입니다.
    """
    
    # 1. 응답 타입 확인
    if response.stop_reason == "end_turn":
        # 정상 완료
        final_text = response.content[-1].text
        return json.loads(final_text)
    
    elif response.stop_reason == "tool_use":
        # Tool을 호출했으나 끝나지 않음 (드문 경우)
        # Manual loop을 직접 처리해야 함
        pass
    
    else:
        # 에러
        raise Exception(f"Unexpected stop reason: {response.stop_reason}")

def parse_json_from_response(response) -> Dict:
    """응답에서 JSON 추출"""
    import json
    import re
    
    text = response.content[-1].text if response.content else ""
    
    # JSON 블록 찾기
    json_match = re.search(r'\{[\s\S]*?\}|\[[\s\S]*?\]', text)
    if json_match:
        try:
            return json.loads(json_match.group())
        except json.JSONDecodeError:
            return {}
    
    return {}
```

---

## Tool Runner vs Manual Loop 비교

| 특성 | Tool Runner | Manual Loop |
|------|-----------|-----------|
| 루프 관리 | SDK 자동 | 사용자 코드 |
| 코드 복잡도 | 간단함 | 복잡함 |
| 제어 정밀도 | 낮음 | 높음 |
| 다단계 조율 | 어려움 | 쉬움 |
| 상태 관리 | 제한적 | 완전함 |
| 사용 시기 | 단일 에이전트 | Coordinator |

---

## 구현 체크리스트

### Issue Writer
- [ ] System Prompt 정의
- [ ] code_execution tool 호출
- [ ] web_fetch tool 호출
- [ ] memory tool 통합 (이전 분석 참고)
- [ ] findings JSON 파싱
- [ ] confidence 필터링 (>= 0.8)

### Issue Runner
- [ ] System Prompt 정의
- [ ] bash tool로 git 명령
- [ ] code_execution으로 실제 구현
- [ ] test 실행 및 검증
- [ ] error handling (conflict, test fail)
- [ ] completion JSON 파싱

### Doc Optimizer
- [ ] System Prompt 정의
- [ ] web_fetch로 문서 읽기
- [ ] 링크 유효성 검증
- [ ] 문서 업데이트
- [ ] git commit & push
- [ ] doc_updates JSON 파싱

---

## 다음 단계

1. **MEMORY_SCHEMA.md** - Memory Tool 데이터 구조
2. **각 스킬 SKILL.md** 작성
3. **Integration Test** 작성
4. **Live Execution** 시작

---

**마지막 업데이트**: 2026-06-12
**구현 상태**: BLUEPRINT_READY
