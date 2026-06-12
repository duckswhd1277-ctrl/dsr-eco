# Harness Architecture Design
## Claude 공식 문서 기반 하네스 구조 설계

최종 수정: 2026-06-12

---

## 1. 아키텍처 개요

이 프로젝트는 **Multi-Tier Agentic Loop 하네스**를 채택합니다.

```
┌─────────────────────────────────────────────────────────┐
│ TIER 1: Coordinator (Manual Agentic Loop)              │
│ - 상태 머신: ANALYZE → EXECUTE → DOCUMENT → VERIFY      │
│ - 컨텍스트 관리 (메모리 저장, 롤백 전략)                │
│ - 에러 처리 및 재시도 로직                               │
└─────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────┐
│ TIER 2: Specialized Agents (Tool Runners)              │
│ ┌────────────────┬────────────────┬────────────────┐   │
│ │ Issue Writer   │ Issue Runner   │ Doc Optimizer  │   │
│ │ (Analyzer)     │ (Executor)     │ (Documentarian)│   │
│ │ Tool Runner    │ Tool Runner    │ Tool Runner    │   │
│ └────────────────┴────────────────┴────────────────┘   │
└─────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────┐
│ TIER 3: Tools (Server-side & Client-side)              │
│ ┌─────────┬─────────┬─────────┬─────────┬──────────┐  │
│ │ GitHub  │ Code    │ Memory  │ Web     │ Computer │  │
│ │ CLI     │ Exec    │ Tool    │ Fetch   │ Use      │  │
│ │ (bash)  │ (exec)  │ (read)  │ (fetch) │ (vision) │  │
│ └─────────┴─────────┴─────────┴─────────┴──────────┘  │
└─────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────┐
│ CLIENT: HTML Tools (Browser-side)                      │
│ • heat_no_mapper.html (Excel → Matching → Issues)     │
│ • safety_env_psm_dashboard.html (PSM Management)      │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Tier 1: Coordinator (Manual Agentic Loop)

### 역할
최상위 에이전트로서 전체 사이클을 **수동으로 조율**합니다.
현재 `briefing-improver` 스킬이 이 역할을 수행하지만, 더 체계적인 상태 머신 구조가 필요합니다.

### 구현 방식: Manual Agentic Loop
```python
# 의사코드 (Claude API 호출 구조)

class ProjectEnhancementCoordinator:
    def __init__(self):
        self.state = "IDLE"
        self.context = {
            "current_cycle": 0,
            "findings": [],
            "issues": [],
            "completions": [],
        }
    
    def run_cycle(self):
        while self.context["current_cycle"] < 5:
            # 1단계: ANALYZE (Issue Writer에게 위임)
            self.state = "ANALYZING"
            findings = self.delegate_to_issue_writer()
            self.context["findings"].append(findings)
            
            if not findings:
                break
            
            # 2단계: EXECUTE (Issue Runner에게 위임)
            self.state = "EXECUTING"
            execution_result = self.delegate_to_issue_runner(findings)
            self.context["issues"].append(execution_result)
            
            # 3단계: DOCUMENT (Doc Optimizer에게 위임)
            self.state = "DOCUMENTING"
            doc_result = self.delegate_to_doc_optimizer()
            
            # 4단계: VERIFY (자체 검증)
            self.state = "VERIFYING"
            is_valid = self.verify_completion()
            
            if not is_valid:
                self.state = "ERROR_HANDLING"
                self.handle_error()
                continue
            
            self.context["current_cycle"] += 1
        
        return self.context
```

### 상태 머신
```
IDLE
  ↓
ANALYZING → [Issue Writer Tool Runner]
  ↓ (findings exist)
EXECUTING → [Issue Runner Tool Runner]
  ↓
DOCUMENTING → [Doc Optimizer Tool Runner]
  ↓
VERIFYING → [Self-check logic]
  ↓
  ├─→ (valid) → next cycle
  └─→ (invalid) → ERROR_HANDLING → retry or rollback
```

### 컨텍스트 관리 (Memory Tool)
```json
{
  "cycle": 1,
  "timestamp": "2026-06-12T14:30:00Z",
  "findings": [
    {
      "id": "issue-001",
      "type": "bug|feature|refactor",
      "title": "...",
      "description": "...",
      "priority": "high|medium|low",
      "estimated_effort": "2h"
    }
  ],
  "completions": [
    {
      "issue_id": "issue-001",
      "status": "closed",
      "commits": ["abc123", "def456"],
      "artifacts": ["README.md updated"]
    }
  ],
  "error_log": [],
  "rollback_points": [
    {
      "cycle": 0,
      "git_commit": "abc123",
      "memory_state": {...}
    }
  ]
}
```

---

## 3. Tier 2: Specialized Agents (Tool Runner Pattern)

각 에이전트는 **SDK의 Tool Runner**를 사용합니다.
(Python SDK: `client.beta.messages.tool_runner()`)

### 3.1 Issue Writer Agent (Analyzer)

```yaml
# .claude/agents/issue-writer-runner.yaml
name: Issue Writer
type: tool_runner
model: claude-opus-4-8
thinking: enabled
effort: high

system: |
  당신은 GitHub Issues 분석 전문가입니다.
  
  도구:
  - code_execution (Python로 코드 분석)
  - web_fetch (프로젝트 문서 읽기)
  - memory (과거 분석 기록 참고)
  
  입력: 프로젝트 코드 또는 요청사항
  출력: 구조화된 Issue 데이터
    {
      "title": "...",
      "body": "Problem / Reproduction / Expected / Actual / Acceptance",
      "labels": ["bug", "feature", "refactor"],
      "priority": "high|medium|low"
    }
  
  성공 기준:
  - Issue는 실행 가능해야 함 (SMART 원칙)
  - 재현 단계가 명확함
  - 수용 기준이 측정 가능함

tools:
  - type: code_execution
  - type: web_fetch
  - type: memory
    mode: read
    path: /findings/
```

### 3.2 Issue Runner Agent (Executor)

```yaml
# .claude/agents/issue-runner-executor.yaml
name: Issue Runner
type: tool_runner
model: claude-opus-4-8

system: |
  당신은 GitHub Issues 실행 전문가입니다.
  
  도구:
  - bash (git, gh CLI)
  - code_execution (구현)
  - memory (진행 상황 기록)
  
  워크플로우:
  1. Issue 상태: Backlog → In Progress
  2. 브랜치 생성: feature/{issue-id}
  3. 코드 구현 (code_execution)
  4. 테스트 (code_execution)
  5. Commit: "fix(#{issue-id}): ..." format
  6. Issue 상태: In Review
  7. Issue close with commit SHA
  
  에러 처리:
  - 테스트 실패 → rollback (git reset --soft)
  - Conflict → manual merge 요청
  - 구현 불가능 → issue reopen with note

tools:
  - type: bash
  - type: code_execution
  - type: memory
    mode: write
    path: /completions/
```

### 3.3 Doc Optimizer Agent (Documentarian)

```yaml
# .claude/agents/doc-optimizer-writer.yaml
name: Doc Optimizer
type: tool_runner
model: claude-opus-4-8

system: |
  당신은 기술 문서 최적화 전문가입니다.
  
  도구:
  - web_fetch (현재 문서 읽기)
  - bash (git, file ops)
  - memory (문서 버전 기록)
  
  작업:
  1. README.md 검토
     - 최신 기능 반영 여부
     - 사용 예제 정확성
     - 링크 유효성
  2. soul.md 검토
     - 아키텍처 변경사항 반영
     - 기술 결정 문서화
  3. CLAUDE.md 검토
     - 협업 가이드 적절성
     - 워크플로우 변경사항
  4. 헤더 일관성, 스타일 검토
  
  출력:
  - 변경사항 patch (git diff 형식)
  - 또는 직접 파일 업데이트 commit

tools:
  - type: web_fetch
  - type: bash
  - type: code_execution
  - type: memory
    mode: write
    path: /documentation/
```

---

## 4. Tier 3: Tools (Anthropic Server-side & Client-side)

### 4.1 Server-side Tools (Anthropic 제공)

| Tool | Agent | Purpose |
|------|-------|---------|
| **code_execution** | All | 코드 실행 및 분석 |
| **web_fetch** | All | 문서 및 URL 내용 읽기 |
| **memory** | All | 상태 및 컨텍스트 유지 |
| **bash** | Issue Runner | git, gh CLI 실행 |

### 4.2 Client-side Tools (프로젝트 정의)

```yaml
# .claude/tools/heat-no-matcher.yaml
name: heat_no_matcher
type: client
description: HEAT NO 자동 매칭 (Excel → Matching → GitHub Issues)

entry: heat_no_mapper.html
input_schema:
  type: object
  properties:
    file1:
      type: file
      description: 정리파일(수출).xls
    file2:
      type: file
      description: OT 열처리.xls
    file3:
      type: file
      description: 원재료 조회 파일 (선택)
    create_issue:
      type: boolean
      description: GitHub Issue 자동 생성 여부
  required: [file1, file2]

output_schema:
  type: object
  properties:
    matches:
      type: array
      items:
        type: object
        properties:
          manufNo: string
          heatNo: string
          company: string
          status: string
    statistics:
      type: object
      properties:
        total: integer
        matched: integer
        failed: integer
    issues_created:
      type: array
      items: string
      description: GitHub Issue URLs
```

---

## 5. 통합 흐름: Manual Loop + Tool Runners

```
사용자 요청
    ↓
Coordinator (Manual Agentic Loop)
    ├─ State: ANALYZING
    │   ↓
    │   Issue Writer (Tool Runner)
    │   ├─ code_execution: 코드 분석
    │   ├─ web_fetch: 문서 조회
    │   └─ Output: findings JSON
    │
    ├─ State: EXECUTING
    │   ↓
    │   Issue Runner (Tool Runner)
    │   ├─ bash: git, gh CLI
    │   ├─ code_execution: 구현
    │   └─ Output: completion record
    │
    ├─ State: DOCUMENTING
    │   ↓
    │   Doc Optimizer (Tool Runner)
    │   ├─ web_fetch: 문서 읽기
    │   ├─ bash: git commit
    │   └─ Output: doc updates
    │
    ├─ State: VERIFYING
    │   ├─ 상태 검증
    │   ├─ 에러 감지
    │   └─ 다음 사이클 or 종료
    │
    └─ Output: cycle_context JSON
        └─ Memory에 저장 (rollback용)
```

---

## 6. 에러 처리 및 롤백 전략

### 6.1 에러 분류

```
Category | Example | Handler | Recoverable
---------|---------|---------|----------
VALIDATION | 파일 포맷 오류 | 에러 메시지 반환 | 입력 재시도
EXECUTION | git conflict | Issue Runner rollback | git reset --soft
LOGIC | 이슈가 없음 | 사이클 종료 | 다음 기간 대기
API | GitHub API 500 | exponential backoff | 자동 재시도
SAFETY | 검증 실패 | rollback + alert | 수동 개입
```

### 6.2 Rollback 메커니즘

```python
class CoordinatorRollback:
    def __init__(self, memory_tool):
        self.memory = memory_tool
        self.rollback_points = []
    
    def create_checkpoint(self, cycle: int):
        """각 사이클 시작 시 체크포인트 생성"""
        checkpoint = {
            "cycle": cycle,
            "git_commit": git_current_sha(),  # bash tool
            "memory_state": self.memory.read(),  # memory tool
            "timestamp": now()
        }
        self.rollback_points.append(checkpoint)
        return checkpoint
    
    def rollback_to_checkpoint(self, cycle: int):
        """특정 사이클로 롤백"""
        checkpoint = self.rollback_points[cycle]
        
        # 1. Git 롤백
        bash_tool.run(f"git reset --hard {checkpoint['git_commit']}")
        
        # 2. Memory 상태 복구
        memory_tool.write(checkpoint['memory_state'])
        
        return True
```

---

## 7. 구현 체크리스트

### Phase 1: 기반 구축 (이번 sprint)
- [ ] Coordinator Manual Loop 구조 설계 (의사코드 작성)
- [ ] 상태 머신 YAML 정의
- [ ] Memory Tool 스키마 설계

### Phase 2: Tool Runners 구현
- [ ] Issue Writer Tool Runner 작성
- [ ] Issue Runner Tool Runner 작성
- [ ] Doc Optimizer Tool Runner 작성

### Phase 3: 통합 및 테스트
- [ ] 3개 Tool Runners 모두 연동
- [ ] 롤백 로직 테스트
- [ ] 에러 처리 통합 테스트

### Phase 4: 본격 운영
- [ ] heat_no_mapper.html 통합
- [ ] GitHub Issues 자동화 완성
- [ ] 모니터링 대시보드 추가

---

## 8. 용어 정의 (Claude 공식 문서)

| 용어 | 의미 | 프로젝트 위치 |
|------|------|-------------|
| **Harness** | 에이전트 루프를 관리하는 상위 구조 | Coordinator |
| **Manual Agentic Loop** | 사용자/상위 에이전트가 루프 제어 | Coordinator state machine |
| **Tool Runner** | SDK가 자동으로 도구 루프 관리 | Issue Writer/Runner/Optimizer |
| **Tool** | 에이전트가 호출할 수 있는 액션 | GitHub CLI, code_execution, etc |
| **Context Window** | 에이전트가 한 번에 처리할 수 있는 텍스트 | ~200K tokens (claude-opus-4-8) |
| **Memory Tool** | 상태 및 컨텍스트 유지 도구 | /findings, /completions 경로 |
| **Rollback** | 이전 안정 상태로 복귀 | git reset + memory restore |

---

## 9. 다음 단계

이 문서는 설계 기반입니다. 다음 문서를 참고하세요:

1. **[COORDINATOR_MANUAL_LOOP.md]** - Coordinator 상세 구현
2. **[TOOL_RUNNER_PATTERNS.md]** - Tool Runner 구현 패턴
3. **[ERROR_HANDLING.md]** - 에러 처리 상세
4. **[MEMORY_SCHEMA.md]** - Memory Tool 데이터 구조

---

**마지막 업데이트**: 2026-06-12
**아키텍처 상태**: DESIGN_APPROVED
**다음 마일스톤**: Coordinator 구현 (Phase 2)
