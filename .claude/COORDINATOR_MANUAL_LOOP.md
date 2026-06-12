# Coordinator Manual Agentic Loop 구현 가이드

**기술 스택**: Claude SDK + Manual Loop + Memory Tool
**난이도**: Advanced
**유지보수성**: High (명시적 상태 관리)

---

## 개요

Coordinator는 **Manual Agentic Loop** 패턴을 사용하여 4단계 사이클을 직접 제어합니다.

| 단계 | 역할 | 결과 |
|------|------|------|
| **ANALYZE** | Issue Writer 호출 → 코드 분석 | findings JSON |
| **EXECUTE** | Issue Runner 호출 → 구현 | completion JSON |
| **DOCUMENT** | Doc Optimizer 호출 → 문서화 | doc_updates JSON |
| **VERIFY** | 상태 검증 | pass/fail + rollback trigger |

---

## 1단계: 상태 머신 정의

### 1.1 상태 열거

```python
from enum import Enum

class CoordinatorState(Enum):
    IDLE = "idle"
    ANALYZING = "analyzing"
    EXECUTING = "executing"
    DOCUMENTING = "documenting"
    VERIFYING = "verifying"
    ERROR_HANDLING = "error_handling"
    COMPLETE = "complete"
```

### 1.2 상태 전이 다이어그램

```
IDLE
  ↓ start_cycle()
ANALYZING
  ├─ call Issue Writer
  ├─ receive findings
  └─ on_analysis_complete()
    ↓
EXECUTING (if findings exist)
  ├─ call Issue Runner
  ├─ receive completion
  └─ on_execution_complete()
    ↓
DOCUMENTING
  ├─ call Doc Optimizer
  ├─ receive doc_updates
  └─ on_documentation_complete()
    ↓
VERIFYING
  ├─ verify all outputs
  ├─ check safety
  └─ on_verification_complete()
    ├─ (valid) → IDLE → next cycle
    ├─ (invalid) → ERROR_HANDLING
    └─ (dry) → COMPLETE
```

---

## 2단계: Context 데이터 구조

### 2.1 Cycle Context

```python
from dataclasses import dataclass, field
from datetime import datetime
from typing import List, Dict, Any

@dataclass
class CycleContext:
    """한 사이클의 전체 상태"""
    
    cycle_id: int
    started_at: str  # ISO 8601
    state: CoordinatorState
    
    # 단계별 결과
    findings: List[Dict[str, Any]] = field(default_factory=list)
    completions: List[Dict[str, Any]] = field(default_factory=list)
    doc_updates: List[Dict[str, Any]] = field(default_factory=list)
    
    # 에러 추적
    errors: List[Dict[str, Any]] = field(default_factory=list)
    rollback_point: Optional[str] = None  # git SHA
    
    # 통계
    findings_count: int = 0
    execution_success_rate: float = 0.0
    documentation_coverage: float = 0.0
    
    def to_dict(self) -> Dict:
        """Memory Tool에 저장할 형식"""
        return {
            "cycle_id": self.cycle_id,
            "started_at": self.started_at,
            "state": self.state.value,
            "findings": self.findings,
            "completions": self.completions,
            "doc_updates": self.doc_updates,
            "errors": self.errors,
            "rollback_point": self.rollback_point,
            "findings_count": self.findings_count,
            "execution_success_rate": self.execution_success_rate,
            "documentation_coverage": self.documentation_coverage,
        }
```

---

## 3단계: Manual Loop 구현

### 3.1 기본 루프 구조

```python
from anthropic import Anthropic

class ProjectEnhancementCoordinator:
    def __init__(self, api_key: str):
        self.client = Anthropic(api_key=api_key)
        self.context = CycleContext(
            cycle_id=0,
            started_at=datetime.now().isoformat(),
            state=CoordinatorState.IDLE
        )
        self.cycle_history = []
        self.max_cycles = 5
    
    def run(self) -> Dict:
        """메인 사이클 루프"""
        print("🚀 Project Enhancement Coordinator 시작")
        
        while self.context.cycle_id < self.max_cycles:
            try:
                # 1️⃣ ANALYZING
                self._transition_to(CoordinatorState.ANALYZING)
                findings = self._analyze_phase()
                
                if not findings:
                    print("✅ 분석 결과: 개선사항 없음")
                    break
                
                self.context.findings = findings
                self.context.findings_count = len(findings)
                
                # 2️⃣ EXECUTING
                self._transition_to(CoordinatorState.EXECUTING)
                completions = self._execute_phase(findings)
                self.context.completions = completions
                
                # 실행 성공률 계산
                success_count = sum(
                    1 for c in completions 
                    if c.get("status") == "success"
                )
                self.context.execution_success_rate = (
                    success_count / len(completions) 
                    if completions else 0.0
                )
                
                # 3️⃣ DOCUMENTING
                self._transition_to(CoordinatorState.DOCUMENTING)
                doc_updates = self._document_phase()
                self.context.doc_updates = doc_updates
                self.context.documentation_coverage = (
                    len(doc_updates) / len(completions)
                    if completions else 0.0
                )
                
                # 4️⃣ VERIFYING
                self._transition_to(CoordinatorState.VERIFYING)
                is_valid = self._verify_phase()
                
                if not is_valid:
                    self._handle_error()
                    continue
                
                # ✅ 사이클 완료
                self._save_cycle_to_memory()
                self.context.cycle_id += 1
                
            except Exception as e:
                self.context.state = CoordinatorState.ERROR_HANDLING
                self.context.errors.append({
                    "cycle": self.context.cycle_id,
                    "error": str(e),
                    "timestamp": datetime.now().isoformat()
                })
                self._handle_error()
                break
        
        self._transition_to(CoordinatorState.COMPLETE)
        return self._finalize()
    
    def _transition_to(self, new_state: CoordinatorState):
        """상태 전이"""
        old_state = self.context.state
        self.context.state = new_state
        print(f"📍 상태 변경: {old_state.value} → {new_state.value}")
    
    def _save_cycle_to_memory(self):
        """Memory Tool에 사이클 저장 (나중에 rollback용)"""
        # Memory Tool 호출 (실제 구현은 SDK에 따라 다름)
        memory_key = f"cycles/{self.context.cycle_id}"
        # memory_tool.write(memory_key, self.context.to_dict())
        print(f"💾 사이클 {self.context.cycle_id} 메모리에 저장")
```

### 3.2 각 단계의 세부 구현

#### ANALYZING Phase

```python
def _analyze_phase(self) -> List[Dict]:
    """
    Issue Writer (Tool Runner)를 호출하여 코드 분석
    
    Returns:
        findings: [
            {
                "id": "issue-001",
                "type": "bug|feature|refactor",
                "title": "...",
                "description": "...",
                "priority": "high|medium|low",
                "estimated_effort": "2h"
            }
        ]
    """
    
    analysis_prompt = """
    다음 프로젝트의 코드를 분석하고 개선점을 찾아주세요:
    
    1. 버그 및 오류 처리 누락
    2. 성능 최적화 기회
    3. 코드 품질 개선
    4. 문서화 부족
    5. 테스트 커버리지 부족
    
    각 발견사항은 다음 형식으로 구조화:
    {
        "id": "issue-XXX",
        "type": "bug|feature|refactor",
        "title": "명확한 제목",
        "description": "상세 설명",
        "priority": "high|medium|low",
        "estimated_effort": "시간"
    }
    """
    
    # Issue Writer (Tool Runner)에게 위임
    response = self.client.messages.create(
        model="claude-opus-4-8",
        max_tokens=4000,
        thinking={
            "type": "adaptive"
        },
        messages=[
            {
                "role": "user",
                "content": analysis_prompt
            }
        ]
    )
    
    # 응답 파싱 (실제로는 더 복잡한 파싱 필요)
    findings = self._parse_findings_from_response(response)
    print(f"🔍 분석 완료: {len(findings)}개의 개선사항 발견")
    
    return findings

def _parse_findings_from_response(self, response) -> List[Dict]:
    """응답에서 findings 추출"""
    # Issue Writer의 응답 형식에 따라 파싱
    # 이 예제는 구조화된 JSON 응답을 가정
    text = response.content[0].text
    
    # 실제로는 JSON 파싱 + 검증 필요
    import json
    import re
    
    # JSON 블록 추출
    json_match = re.search(r'\[[\s\S]*\]', text)
    if json_match:
        findings = json.loads(json_match.group())
        return findings
    
    return []
```

#### EXECUTING Phase

```python
def _execute_phase(self, findings: List[Dict]) -> List[Dict]:
    """
    Issue Runner (Tool Runner)를 호출하여 구현
    
    Returns:
        completions: [
            {
                "issue_id": "issue-001",
                "status": "success|failed",
                "commits": ["abc123", "def456"],
                "artifacts": ["file1.py", "file2.md"],
                "test_results": {...}
            }
        ]
    """
    
    completions = []
    
    for finding in findings:
        execution_prompt = f"""
        다음 Issue를 구현해주세요:
        
        Issue ID: {finding['id']}
        Title: {finding['title']}
        Description: {finding['description']}
        
        워크플로우:
        1. git branch 생성: feature/{finding['id']}
        2. 코드 수정 (code_execution tool 사용)
        3. 테스트 실행
        4. git commit: "fix(#{finding['id']}): {finding['title']}"
        5. Issue 상태 업데이트 (bash tool: gh issue update)
        
        완료 시 반환:
        {{
            "issue_id": "{finding['id']}",
            "status": "success|failed",
            "commits": ["..."],
            "test_results": {{...}}
        }}
        """
        
        # Issue Runner (Tool Runner)에게 위임
        response = self.client.messages.create(
            model="claude-opus-4-8",
            max_tokens=8000,
            thinking={"type": "adaptive"},
            messages=[
                {"role": "user", "content": execution_prompt}
            ]
        )
        
        completion = self._parse_completion_from_response(response)
        completions.append(completion)
        
        print(f"✅ {finding['id']}: {completion['status']}")
    
    return completions

def _parse_completion_from_response(self, response) -> Dict:
    """응답에서 completion 정보 추출"""
    # 구현 생략 (exec phase와 유사)
    return {
        "issue_id": "issue-xxx",
        "status": "success",
        "commits": [],
        "artifacts": []
    }
```

#### DOCUMENTING Phase

```python
def _document_phase(self) -> List[Dict]:
    """
    Doc Optimizer (Tool Runner)를 호출하여 문서화
    
    Returns:
        doc_updates: [
            {
                "file": "README.md",
                "changes": "...",
                "status": "updated|skipped"
            }
        ]
    """
    
    documentation_prompt = """
    다음 변경사항을 프로젝트 문서에 반영해주세요:
    
    1. README.md - 새로운 기능 추가 여부 업데이트
    2. soul.md - 아키텍처 변경사항 기록
    3. CLAUDE.md - 워크플로우 변경사항
    4. 링크 유효성 검사
    
    각 문서 업데이트는:
    {
        "file": "파일명",
        "changes": "변경사항",
        "status": "updated|skipped",
        "reason": "스킵한 이유 (선택)"
    }
    """
    
    response = self.client.messages.create(
        model="claude-opus-4-8",
        max_tokens=4000,
        thinking={"type": "adaptive"},
        messages=[
            {"role": "user", "content": documentation_prompt}
        ]
    )
    
    doc_updates = self._parse_doc_updates_from_response(response)
    print(f"📚 문서화 완료: {len(doc_updates)}개 파일 업데이트")
    
    return doc_updates
```

#### VERIFYING Phase

```python
def _verify_phase(self) -> bool:
    """
    현재 사이클의 모든 결과물 검증
    
    Returns:
        True: 모든 검증 통과, 다음 사이클 진행
        False: 검증 실패, 롤백 필요
    """
    
    checks = [
        self._check_findings_count(),
        self._check_execution_quality(),
        self._check_documentation_completeness(),
        self._check_no_breaking_changes(),
        self._check_git_state()
    ]
    
    if all(checks):
        print("✅ 검증 통과: 모든 체크 성공")
        return True
    else:
        print("❌ 검증 실패: 일부 체크 실패")
        return False

def _check_findings_count(self) -> bool:
    """발견된 이슈 개수 검증"""
    # 최소 1개 이상의 개선사항이 발견되었는가?
    return self.context.findings_count > 0

def _check_execution_quality(self) -> bool:
    """실행 품질 검증"""
    # 실행 성공률 >= 80%?
    return self.context.execution_success_rate >= 0.8

def _check_documentation_completeness(self) -> bool:
    """문서화 완전성 검증"""
    # 실행한 이슈의 80% 이상이 문서화되었는가?
    return self.context.documentation_coverage >= 0.8

def _check_no_breaking_changes(self) -> bool:
    """Breaking change 확인"""
    # 테스트 통과율 확인 (추후 구현)
    return True

def _check_git_state(self) -> bool:
    """Git 상태 확인"""
    # working tree가 깨끗한가?
    # (bash tool으로 git status 확인)
    return True
```

---

## 4단계: 에러 처리 및 롤백

### 4.1 에러 핸들러

```python
def _handle_error(self):
    """
    에러 처리 전략:
    - 기록
    - 롤백 또는 리트라이
    """
    
    if not self.context.errors:
        return
    
    latest_error = self.context.errors[-1]
    error_type = self._classify_error(latest_error["error"])
    
    if error_type == "RECOVERABLE":
        print(f"🔄 복구 가능한 에러: 재시도")
        # 현재 단계 재시도
        pass
    elif error_type == "ROLLBACK_NEEDED":
        print(f"⏮️ 롤백 필요")
        self._rollback_to_checkpoint()
    else:
        print(f"❌ 복구 불가능: 종료")
        self.context.cycle_id = self.max_cycles

def _classify_error(self, error_msg: str) -> str:
    """에러 분류"""
    if "conflict" in error_msg.lower():
        return "ROLLBACK_NEEDED"
    elif "timeout" in error_msg.lower():
        return "RECOVERABLE"
    else:
        return "UNRECOVERABLE"

def _rollback_to_checkpoint(self):
    """이전 체크포인트로 롤백"""
    if self.context.rollback_point:
        # git reset --hard {rollback_point}
        print(f"⏮️ {self.context.rollback_point}로 롤백")
```

---

## 5단계: 최종화 및 보고

```python
def _finalize(self) -> Dict:
    """최종 리포트 생성"""
    
    report = {
        "status": "complete",
        "total_cycles": self.context.cycle_id,
        "total_findings": sum(
            c.findings_count 
            for c in self.cycle_history
        ),
        "success_rate": self._calculate_overall_success_rate(),
        "execution_time_seconds": self._calculate_execution_time(),
        "next_steps": self._recommend_next_steps()
    }
    
    print("\n" + "="*60)
    print("📊 FINAL REPORT")
    print("="*60)
    print(f"✅ 완료된 사이클: {report['total_cycles']}")
    print(f"📈 총 개선사항: {report['total_findings']}")
    print(f"💯 성공률: {report['success_rate']:.1%}")
    print(f"⏱️ 실행 시간: {report['execution_time_seconds']:.1f}초")
    print("="*60)
    
    return report

def _calculate_overall_success_rate(self) -> float:
    """전체 성공률 계산"""
    total = sum(len(c.completions) for c in self.cycle_history)
    successful = sum(
        sum(
            1 for comp in c.completions 
            if comp.get("status") == "success"
        )
        for c in self.cycle_history
    )
    return successful / total if total > 0 else 0.0

def _recommend_next_steps(self) -> List[str]:
    """다음 단계 추천"""
    recommendations = []
    
    if self.context.execution_success_rate < 0.8:
        recommendations.append("실행 실패율이 높음 → 에러 처리 개선 필요")
    
    if self.context.documentation_coverage < 0.8:
        recommendations.append("문서화 완성도 부족 → 추가 작성 필요")
    
    if self.context.findings_count > 5:
        recommendations.append("개선사항 많음 → 다음 사이클 권장")
    
    return recommendations
```

---

## 6단계: Memory Tool 통합

### 6.1 상태 저장

```python
def _save_cycle_to_memory(self):
    """Memory Tool에 사이클 상태 저장"""
    
    # Memory Tool 경로
    memory_path = f"project-enhancement/cycles/{self.context.cycle_id}"
    
    # 저장할 데이터
    data_to_save = {
        "cycle": self.context.to_dict(),
        "timestamp": datetime.now().isoformat(),
        "git_state": {
            # bash tool으로 git log 조회
            "current_sha": "...",
            "branch": "main"
        }
    }
    
    # Memory Tool 호출 (실제 SDK에 따라 다름)
    # memory_tool.write(memory_path, data_to_save)
    
    print(f"💾 메모리 저장: {memory_path}")
```

### 6.2 상태 복구

```python
def _load_previous_state(self, cycle_id: int):
    """이전 사이클 상태 복구"""
    
    memory_path = f"project-enhancement/cycles/{cycle_id}"
    
    # Memory Tool 호출
    # previous_state = memory_tool.read(memory_path)
    
    if previous_state:
        self.context = CycleContext(**previous_state["cycle"])
        print(f"📂 이전 상태 복구: 사이클 {cycle_id}")
```

---

## 7단계: 통합 테스트

```python
def test_coordinator_loop():
    """통합 테스트"""
    
    coordinator = ProjectEnhancementCoordinator(
        api_key=os.getenv("ANTHROPIC_API_KEY")
    )
    
    result = coordinator.run()
    
    # 검증
    assert result["status"] == "complete"
    assert result["total_cycles"] > 0
    assert result["success_rate"] >= 0.8
    
    print("✅ 테스트 통과")
```

---

## 요약

이 구현은:

✅ **명시적 상태 관리** - 각 단계가 명확함
✅ **에러 복구** - 롤백 및 재시도 메커니즘
✅ **메모리 통합** - 상태 영속성
✅ **메트릭 추적** - 성공률, 커버리지 등
✅ **보고서 생성** - 최종 결과물

다음: **TOOL_RUNNER_PATTERNS.md** - Tool Runner 세부 구현

---

**마지막 업데이트**: 2026-06-12
**구현 상태**: BLUEPRINT_READY
