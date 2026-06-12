# Rubric Validation Framework - 하네스 통합 가이드

**기술 스택**: Quality Rubric + Harness Architecture
**난이도**: Advanced
**목적**: 프로젝트 품질을 객관적으로 측정하고 추적

최종 수정: 2026-06-12

---

## 개요

루브릭 검증은 **Coordinator Manual Loop의 VERIFYING 단계**에 통합되어 각 사이클마다 품질을 평가합니다.

```
Coordinator
    ↓
VERIFYING Phase
    ├─ 루브릭 평가 (9개 차원)
    ├─ 점수 계산 (100점 만점)
    ├─ 등급 판정 (Diamond/Gold/Silver/Bronze/Lead)
    ├─ Memory에 저장
    └─ Pass/Fail 판정
        ├─ (Pass) → 다음 사이클
        └─ (Fail) → ERROR_HANDLING/ROLLBACK
```

---

## 1. 루브릭 9개 차원

### 1.1 차원 정의 및 가중치

| # | 차원 | 가중치 | 평가 대상 | Tier |
|---|------|--------|----------|------|
| 1 | **Functionality** (기능성) | 15% | Findings, Completions | TIER 2 |
| 2 | **Code Quality** (코드 품질) | 15% | Completions | TIER 2 |
| 3 | **Architecture** (아키텍처) | 12% | Completions | TIER 2 |
| 4 | **Testing** (테스트) | 12% | Completions | TIER 2 |
| 5 | **Documentation** (문서화) | 10% | Doc Updates | TIER 2 |
| 6 | **UX/Design** (사용자경험) | 12% | Completions | TIER 2 |
| 7 | **Performance** (성능) | 10% | Completions | TIER 2 |
| 8 | **Maintainability** (유지보수성) | 10% | Completions | TIER 2 |
| 9 | **Security** (보안) | 4% | Completions | TIER 2 |

### 1.2 각 차원별 점수 범위

```python
# 점수 등급
SCORE_RANGES = {
    "excellent": (15, 12, 12, 12, 10, 12, 10, 10, 4),  # 우수 (100%)
    "good": (12, 10, 10, 10, 8, 10, 8, 8, 3),          # 양호 (80%)
    "fair": (8, 7, 7, 7, 5, 7, 5, 5, 2),               # 보통 (60%)
    "poor": (3, 2, 2, 2, 1, 2, 1, 1, 0),               # 미흡 (30%)
}

# 최종 등급
FINAL_GRADES = {
    "diamond": (95, 100),      # 💎 완벽한 수준
    "gold": (85, 94),          # 🥇 높은 품질
    "silver": (75, 84),        # 🥈 양호
    "bronze": (60, 74),        # 🥉 기본 작동
    "lead": (0, 59),           # 🔴 심각한 문제
}
```

---

## 2. TIER별 검증 전략

### 2.1 TIER 1: Coordinator Verification

Coordinator의 **VERIFYING 단계**에서 루브릭 평가를 수행합니다.

```python
class CoordinatorVerifier:
    def __init__(self, memory_tool, rubric_scorer):
        self.memory = memory_tool
        self.scorer = rubric_scorer
    
    def verify_cycle(self, cycle_context: CycleContext) -> VerificationResult:
        """현재 사이클을 루브릭으로 평가"""
        
        # 1️⃣ 각 차원별 점수 계산
        scores = self.scorer.evaluate_all_dimensions(cycle_context)
        
        # 2️⃣ 최종 점수 계산
        final_score = self._calculate_final_score(scores)
        
        # 3️⃣ 등급 판정
        grade = self._get_grade(final_score)
        
        # 4️⃣ Memory에 저장
        self._save_rubric_scores(cycle_context.cycle_id, scores, final_score, grade)
        
        # 5️⃣ Pass/Fail 판정
        is_valid = self._determine_pass_fail(grade, cycle_context)
        
        return VerificationResult(
            scores=scores,
            final_score=final_score,
            grade=grade,
            is_valid=is_valid,
            recommendations=self._generate_recommendations(scores)
        )
    
    def _calculate_final_score(self, scores: Dict[str, float]) -> float:
        """가중치를 고려한 최종 점수 계산"""
        
        weights = {
            "functionality": 0.15,
            "code_quality": 0.15,
            "architecture": 0.12,
            "testing": 0.12,
            "documentation": 0.10,
            "ux_design": 0.12,
            "performance": 0.10,
            "maintainability": 0.10,
            "security": 0.04,
        }
        
        final = sum(scores[dim] * weights[dim] for dim in scores)
        return round(final, 2)
    
    def _determine_pass_fail(self, grade: str, context: CycleContext) -> bool:
        """등급에 따른 Pass/Fail 판정"""
        
        # Gold 이상 → Pass
        if grade in ["diamond", "gold"]:
            return True
        
        # Silver → 조건부 Pass (이전 사이클과 비교)
        if grade == "silver":
            prev_grade = self._get_previous_grade(context.cycle_id - 1)
            if prev_grade and prev_grade in ["silver", "gold", "diamond"]:
                return True  # 이전 사이클보다 나쁘지 않으면 Pass
        
        # Bronze, Lead → Fail
        return False
```

### 2.2 TIER 2: Agent Awareness

각 Tool Runner는 루브릭 기준을 염두에 두고 작업합니다.

#### Issue Writer (Analyzer)

```yaml
# Issue Writer가 고려할 루브릭 차원:
# - Functionality: 요구사항 명확성
# - Code Quality: 개선 가능 코드 발견
# - Documentation: 문서 부족 식별

system: |
  당신은 GitHub Issues 분석 전문가입니다.
  
  **루브릭 기준을 고려하여 분석하세요:**
  
  1. Functionality (15%)
     - 요구사항이 100% 명확한가?
     - 버그는 0개인가?
     - 엣지 케이스가 모두 처리되었는가?
  
  2. Code Quality (15%)
     - camelCase 규칙을 준수하는가?
     - 함수가 50줄 이하인가?
     - 미사용 코드가 있는가?
  
  3. Documentation (10%)
     - README가 최신인가?
     - soul.md가 정확한가?
     - 주석이 적절한가?
  
  **발견사항 포맷:**
  {
    "id": "issue-XXX",
    "type": "bug|feature|refactor|docs|test",
    "title": "...",
    "rubric_dimension": "functionality|code_quality|documentation|...",
    "priority": "high|medium|low",
    "confidence": 0.0-1.0
  }
```

#### Issue Runner (Executor)

```yaml
# Issue Runner가 고려할 루브릭 차원:
# - Architecture: 단일 책임 원칙
# - Testing: 테스트 커버리지
# - Performance: 로딩 속도, 반응성
# - Security: 입력값 검증

system: |
  당신은 GitHub Issues 실행 전문가입니다.
  
  **루브릭 기준에 따라 구현하세요:**
  
  1. Code Quality Checklist
     - [ ] camelCase 준수
     - [ ] 함수 50줄 이하
     - [ ] WHY only 주석
     - [ ] soul.md 규칙 준수
  
  2. Testing Checklist
     - [ ] 3개+ 브라우저에서 테스트
     - [ ] 100+ 항목 성능 테스트
     - [ ] 입력값/날짜/중복 검증
  
  3. Performance Checklist
     - [ ] 초기 로딩 < 1초
     - [ ] 상호작용 < 100ms
     - [ ] 메모리 누수 없음
  
  4. Security Checklist
     - [ ] XSS 방지
     - [ ] CSV 인젝션 방지
     - [ ] 입력값 검증
  
  **완료 후:**
  {
    "issue_id": "issue-XXX",
    "status": "success|failed",
    "rubric_scores": {
      "code_quality": 15,
      "architecture": 12,
      "testing": 12,
      "performance": 10,
      "security": 4
    }
  }
```

#### Doc Optimizer (Documentarian)

```yaml
# Doc Optimizer가 고려할 루브릭 차원:
# - Documentation: 완전성, 정확성, 최신성
# - Maintainability: 명확한 지시

system: |
  당신은 기술 문서 최적화 전문가입니다.
  
  **루브릭 기준에 따라 문서화하세요:**
  
  1. Documentation Checklist
     - [ ] README: 기능/사용법/설정 명확
     - [ ] soul.md: 아키텍처/원칙 최신
     - [ ] CLAUDE.md: 협업 가이드 적절
     - [ ] 주석: WHY 명확
     - [ ] 커밋 메시지: 명확
  
  2. Maintainability Checklist
     - [ ] 파일 구조 명확
     - [ ] 함수명 자설명적
     - [ ] 의존성 명확
  
  **완료:**
  {
    "file": "README.md",
    "status": "updated|skipped",
    "rubric_scores": {
      "documentation": 10,
      "maintainability": 8
    }
  }
```

### 2.3 TIER 3: Tool Support

각 Tool은 루브릭 검증을 지원합니다.

```python
# code_execution: 코드 품질 측정
class CodeQualityAnalyzer:
    def check_naming_conventions(code: str) -> float:
        """camelCase 준수율 계산 (0.0~1.0)"""
        pass
    
    def check_function_length(code: str) -> float:
        """함수 50줄 이하 비율 (0.0~1.0)"""
        pass
    
    def check_dead_code(code: str) -> float:
        """미사용 코드 비율 (0.0~1.0)"""
        pass

# bash: 테스트 실행
class TestRunner:
    def run_cross_browser_tests() -> Dict:
        """Chrome, Edge, Firefox에서 테스트 실행"""
        return {
            "chrome": {"passed": 10, "failed": 0},
            "edge": {"passed": 10, "failed": 0},
            "firefox": {"passed": 10, "failed": 0},
            "coverage": 0.95  # 95%
        }
    
    def run_performance_tests() -> Dict:
        """성능 테스트"""
        return {
            "initial_load_ms": 800,
            "interaction_ms": 80,
            "memory_leak": False
        }

# memory: 루브릭 점수 저장
class RubricScoreStorage:
    def save_cycle_scores(cycle_id: int, scores: Dict):
        """각 사이클의 루브릭 점수 저장"""
        pass
    
    def get_score_trend(dimension: str, cycles: int = 5):
        """특정 차원의 점수 트렌드 조회"""
        pass
```

---

## 3. Memory Schema 통합

### 3.1 루브릭 점수 저장 구조

```json
{
  "memory": {
    "project-enhancement": {
      "rubric": {
        "cycles": {
          "0": {
            "scores": {
              "functionality": 15,
              "code_quality": 12,
              "architecture": 10,
              "testing": 10,
              "documentation": 8,
              "ux_design": 10,
              "performance": 8,
              "maintainability": 8,
              "security": 3
            },
            "final_score": 84.0,
            "grade": "silver",
            "is_valid": true,
            "timestamp": "2026-06-12T14:30:00Z",
            "recommendations": [
              "Architecture 개선 필요",
              "Testing 커버리지 증가 권장"
            ]
          },
          "1": {
            "scores": {...},
            "final_score": 88.0,
            "grade": "gold",
            ...
          }
        },
        "dimension_trends": {
          "functionality": [15, 15, 14, 15, 15],
          "code_quality": [12, 12, 12, 12, 12],
          "architecture": [10, 11, 12, 12, 12],
          ...
        },
        "grade_history": ["silver", "gold", "gold", "gold", "gold"],
        "final_score_history": [84.0, 88.0, 90.0, 91.0, 92.0],
        "metrics": {
          "avg_final_score": 89.0,
          "best_grade": "gold",
          "worst_grade": "silver",
          "improvement_trend": "↗ 상승세"
        }
      }
    }
  }
}
```

### 3.2 Memory 쿼리 함수

```python
class RubricMemoryQueries:
    def get_cycle_score(cycle_id: int) -> Dict:
        """특정 사이클의 루브릭 점수 조회"""
        path = f"project-enhancement/rubric/cycles/{cycle_id}"
        # return memory.read(path)
    
    def get_dimension_trend(dimension: str, last_n: int = 5) -> List[float]:
        """차원별 점수 트렌드 (최근 N 사이클)"""
        path = f"project-enhancement/rubric/dimension_trends/{dimension}"
        # return memory.read(path)[-last_n:]
    
    def get_worst_dimensions(cycle_id: int) -> List[str]:
        """가장 낮은 점수의 차원들"""
        scores = get_cycle_score(cycle_id)["scores"]
        sorted_dims = sorted(scores.items(), key=lambda x: x[1])
        return [dim for dim, score in sorted_dims[:3]]
    
    def get_improvement_potential(cycle_id: int) -> Dict:
        """개선 가능성 분석"""
        current = get_cycle_score(cycle_id)
        worst_dims = get_worst_dimensions(cycle_id)
        
        return {
            "worst_3_dimensions": worst_dims,
            "potential_points": sum(
                4 - (current["scores"][dim] // 4)  # 차이 계산
                for dim in worst_dims
            ),
            "next_target_grade": "gold" if current["grade"] == "silver" else "diamond"
        }
    
    def compare_cycles(cycle_a: int, cycle_b: int) -> Dict:
        """두 사이클의 루브릭 점수 비교"""
        scores_a = get_cycle_score(cycle_a)["scores"]
        scores_b = get_cycle_score(cycle_b)["scores"]
        
        improvements = {}
        for dim in scores_a:
            diff = scores_b[dim] - scores_a[dim]
            if diff != 0:
                improvements[dim] = {
                    "from": scores_a[dim],
                    "to": scores_b[dim],
                    "improvement": diff
                }
        
        return improvements
```

---

## 4. VERIFYING 단계 상세 구현

### 4.1 검증 플로우

```python
def _verify_phase(self) -> bool:
    """
    VERIFYING 단계: 루브릭 검증 + 기존 검증
    """
    
    print("🔍 VERIFYING Phase 시작")
    
    # 1️⃣ 루브릭 평가
    verifier = CoordinatorVerifier(self.memory, self.rubric_scorer)
    verification = verifier.verify_cycle(self.context)
    
    # 결과 출력
    print(f"\n📊 루브릭 평가 결과")
    print(f"   최종 점수: {verification.final_score}/100")
    print(f"   등급: {verification.grade.upper()}")
    print(f"   차원별 점수:")
    for dim, score in verification.scores.items():
        print(f"     - {dim}: {score}")
    
    # 2️⃣ 기존 검증 (Breaking changes, git state 등)
    basic_checks = [
        self._check_no_breaking_changes(),
        self._check_git_state(),
        self._check_findings_count(),
        self._check_execution_quality(),
        self._check_documentation_completeness(),
    ]
    
    # 3️⃣ 최종 판정
    all_checks_passed = all(basic_checks) and verification.is_valid
    
    if all_checks_passed:
        print("✅ 검증 통과: 다음 사이클 진행")
        self.context.rubric_validation = {
            "final_score": verification.final_score,
            "grade": verification.grade,
            "scores": verification.scores,
            "passed": True
        }
    else:
        print("❌ 검증 실패: 에러 처리")
        self.context.errors.append({
            "type": "VALIDATION_FAILED",
            "rubric_score": verification.final_score,
            "rubric_grade": verification.grade,
            "recommendations": verification.recommendations
        })
    
    return all_checks_passed

def _parse_rubric_scores(cycle_context) -> Dict[str, float]:
    """
    Completions, Doc Updates, Test Results에서
    루브릭 점수 추출
    """
    
    scorer = RubricScorer()
    
    # 기본 데이터 수집
    findings = cycle_context.findings
    completions = cycle_context.completions
    doc_updates = cycle_context.doc_updates
    
    # 각 차원별 점수 계산
    scores = {
        "functionality": scorer.score_functionality(findings, completions),
        "code_quality": scorer.score_code_quality(completions),
        "architecture": scorer.score_architecture(completions),
        "testing": scorer.score_testing(completions),
        "documentation": scorer.score_documentation(doc_updates),
        "ux_design": scorer.score_ux_design(completions),
        "performance": scorer.score_performance(completions),
        "maintainability": scorer.score_maintainability(completions),
        "security": scorer.score_security(completions),
    }
    
    return scores
```

### 4.2 루브릭 스코어러 구현

```python
class RubricScorer:
    """각 차원별 점수 계산"""
    
    def score_functionality(self, findings: List, completions: List) -> float:
        """
        기능성 (15점)
        - 요구사항 충족율 (%)
        - 버그 밀도
        - 엣지 케이스 처리율
        """
        
        requirement_coverage = len(completions) / len(findings) if findings else 0
        bug_count = sum(1 for c in completions if c.get("status") == "failed")
        bug_density = 1.0 - (bug_count / len(completions)) if completions else 1.0
        
        score = (requirement_coverage * 0.5 + bug_density * 0.5) * 15
        return min(15, max(0, score))
    
    def score_code_quality(self, completions: List) -> float:
        """
        코드 품질 (15점)
        - camelCase 준수율
        - 함수 길이 (50줄 이하)
        - 주석 품질
        - 미사용 코드 제거
        """
        
        # completions에 포함된 code_quality metrics 사용
        metrics = {}
        for c in completions:
            if "code_metrics" in c:
                metrics.update(c["code_metrics"])
        
        if not metrics:
            return 8  # 기본값: 보통
        
        score = (
            metrics.get("naming_convention_rate", 0.8) * 4 +
            metrics.get("function_length_compliance", 0.8) * 4 +
            metrics.get("comment_quality", 0.8) * 4 +
            metrics.get("dead_code_removal", 0.9) * 3
        )
        
        return min(15, max(0, score))
    
    def score_testing(self, completions: List) -> float:
        """
        테스트 (12점)
        - 브라우저 호환성 (3개 이상)
        - 입력값 검증
        - 성능 테스트
        - 커버리지
        """
        
        test_results = {}
        for c in completions:
            if "test_results" in c:
                test_results = c["test_results"]
        
        if not test_results:
            return 6  # 기본값: 보통
        
        browser_coverage = min(3, test_results.get("browsers_tested", 1)) / 3
        validation_coverage = test_results.get("validation_coverage", 0.5)
        performance_tested = 1.0 if test_results.get("performance_tested") else 0.0
        coverage_percent = test_results.get("coverage_percent", 50) / 100
        
        score = (
            browser_coverage * 3 +
            validation_coverage * 3 +
            performance_tested * 3 +
            coverage_percent * 3
        )
        
        return min(12, max(0, score))
    
    def score_documentation(self, doc_updates: List) -> float:
        """
        문서화 (10점)
        - README 업데이트
        - soul.md 최신성
        - 주석 품질
        - 커밋 메시지 명확성
        """
        
        if not doc_updates:
            return 3  # 기본값: 미흡
        
        files_updated = {u.get("file") for u in doc_updates if u.get("status") == "updated"}
        
        score = 0
        if "README.md" in files_updated:
            score += 2.5
        if "soul.md" in files_updated:
            score += 2.5
        if "CLAUDE.md" in files_updated:
            score += 2.5
        if len(doc_updates) >= 2:
            score += 2.5
        
        return min(10, max(0, score))
    
    # ... 나머지 차원들도 유사하게 구현
```

---

## 5. Pass/Fail 판정 기준

### 5.1 자동 판정

```python
class GradeValidator:
    """등급에 따른 Pass/Fail 판정"""
    
    def is_cycle_valid(grade: str, cycle_id: int, history: List[str]) -> bool:
        """
        Pass/Fail 규칙:
        
        Diamond (95~100): 항상 Pass
        Gold (85~94):     항상 Pass
        Silver (75~84):   이전 사이클이 Silver 이상이면 Pass
        Bronze (60~74):   Fail (수정 후 재시도 필요)
        Lead (<60):       Fail (긴급 수정 필요)
        """
        
        if grade in ["diamond", "gold"]:
            return True
        
        if grade == "silver":
            prev_grade = history[-1] if history else None
            return prev_grade in ["silver", "gold", "diamond"]
        
        return False
    
    def get_action_plan(grade: str, recommendations: List[str]) -> Dict:
        """등급에 따른 액션 플랜"""
        
        plans = {
            "diamond": {
                "action": "PROCEED",
                "message": "완벽한 수준 - 즉시 릴리스 가능",
                "next_steps": ["배포 진행"]
            },
            "gold": {
                "action": "PROCEED",
                "message": "높은 품질 - 1주내 릴리스 권장",
                "next_steps": ["1주내 배포", "사용자 피드백 수집"]
            },
            "silver": {
                "action": "CONDITIONAL",
                "message": "양호 - 2주내 개선 필요",
                "next_steps": [
                    "우선순위 낮은 개선사항 구현",
                    "2주 후 재평가"
                ] + recommendations
            },
            "bronze": {
                "action": "HALT",
                "message": "기본 작동 - 개선 필요",
                "next_steps": [
                    "주요 문제점 식별",
                    "3주 이내 개선",
                    "재평가 후 진행"
                ] + recommendations
            },
            "lead": {
                "action": "HALT",
                "message": "심각한 문제 - 전체 검토 필요",
                "next_steps": [
                    "긴급 회의",
                    "원인 분석",
                    "전체 리팩토링 계획",
                    "재구현"
                ] + recommendations
            }
        }
        
        return plans.get(grade, plans["lead"])
```

---

## 6. 대시보드 및 리포팅

### 6.1 사이클별 보고서

```python
def generate_cycle_report(cycle_id: int) -> str:
    """사이클별 루브릭 평가 보고서"""
    
    scores = memory.read(f"project-enhancement/rubric/cycles/{cycle_id}")
    
    report = f"""
╔════════════════════════════════════════════╗
║  📊 CYCLE {cycle_id} RUBRIC EVALUATION REPORT
╚════════════════════════════════════════════╝

🎯 최종 결과
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  최종 점수: {scores['final_score']}/100
  등급: {scores['grade'].upper()} {'💎' if scores['grade'] == 'diamond' else '🥇' if scores['grade'] == 'gold' else '🥈'}
  상태: {'✅ PASS' if scores['is_valid'] else '❌ FAIL'}

📈 차원별 점수
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"""
    
    for dim, score in scores['scores'].items():
        bar = '█' * int(score / 1.5) + '░' * (10 - int(score / 1.5))
        report += f"  {dim:20} {score:5.1f} │{bar}│\n"
    
    report += f"""
💡 개선 권고사항
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"""
    
    for rec in scores['recommendations']:
        report += f"  • {rec}\n"
    
    report += f"""
🎬 다음 단계
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {scores['action_plan']['message']}
"""
    
    return report
```

### 6.2 트렌드 분석

```python
def analyze_rubric_trends() -> Dict:
    """전체 사이클의 루브릭 점수 트렌드 분석"""
    
    trends = memory.read("project-enhancement/rubric/dimension_trends")
    
    analysis = {
        "overall_trend": "↗ 상승세" if trends["final_score_history"][-1] > trends["final_score_history"][0] else "↘ 하강세",
        "best_performing": max(trends["dimension_trends"], key=lambda d: trends["dimension_trends"][d][-1]),
        "worst_performing": min(trends["dimension_trends"], key=lambda d: trends["dimension_trends"][d][-1]),
        "improvement_potential": calculate_improvement_potential(trends),
        "cycles_to_gold": estimate_cycles_to_gold(trends),
    }
    
    return analysis
```

---

## 7. 체크리스트

- [ ] RubricScorer 구현 (9개 차원)
- [ ] Memory Schema에 rubric_scores 경로 추가
- [ ] VERIFYING 단계에 루브릭 검증 로직 추가
- [ ] Tool Runners에 루브릭 기준 반영
- [ ] 트렌드 분석 함수 구현
- [ ] 보고서 생성 함수 구현
- [ ] 단위 테스트 (각 차원별 스코어러)
- [ ] 통합 테스트 (전체 루브릭 검증)

---

## 8. 다음 단계

1. **Immediate**: RubricScorer 클래스 구현
2. **Week 1**: Memory Schema 업데이트, VERIFYING 단계 수정
3. **Week 2**: Tool Runner들의 루브릭 기준 반영
4. **Week 3**: 대시보드 및 리포팅 기능 완성
5. **Week 4**: 본격 운영 (루브릭 검증으로 품질 추적)

---

**마지막 업데이트**: 2026-06-12
**상태**: DESIGN_COMPLETE
