# Claude Agent Teams 설정

이 프로젝트는 **Claude Agent Teams**를 통해 협력적인 개발을 수행합니다.

## 🤖 팀 구성

### 1. **Issue Writer** (분석가)
- 역할: 프로젝트 분석 및 이슈 작성
- 목표: 잠재적 문제점 발견, 명확한 GitHub Issues 작성
- 책임: 코드 리뷰, 개선점 도출, 우선순위 결정

### 2. **Issue Runner** (실행자)
- 역할: GitHub Issues 실행 및 추적
- 목표: 이슈 상태 관리, 진행 상황 모니터링
- 책임: 구현, 테스트, Issue 종료

### 3. **Doc Optimizer** (문서 작성자)
- 역할: 프로젝트 문서 최적화
- 목표: README, soul.md 등 문서 개선
- 책임: 문서 검토, 최신화, 가독성 향상

### 4. **Coordinator** (조율자)
- 역할: 팀 조율 및 전체 사이클 관리
- 목표: 체계적 프로젝트 개선
- 책임: 우선순위 결정, 진행 상황 모니터링, 팀 간 조정

## 📋 작업 흐름

```
Coordinator
    ↓
    ├─→ Issue Writer (분석) → Issues 도출
    │
    ├─→ Issue Runner (실행) → 문제 해결
    │
    └─→ Doc Optimizer (문서) → 문서 개선
```

### 단계별 프로세스

#### 1단계: 분석 (Analysis)
- Issue Writer가 프로젝트 코드 분석
- 버그, 개선점, 누락된 기능 발견
- GitHub Issues로 정식화

#### 2단계: 실행 (Execution)
- 우선순위 높은 Issue 선택
- Issue Runner가 구현 및 테스트
- 완료된 작업 Issue에 기록

#### 3단계: 문서화 (Documentation)
- 변경사항을 프로젝트 문서에 반영
- Doc Optimizer가 README, soul.md 등 업데이트
- 가이드 문서 최신화

#### 4단계: 검토 및 계획 (Review & Planning)
- 완료된 사이클 검토
- 다음 우선순위 결정
- 새로운 사이클 시작

## 🚀 팀 활용 방법

### 분석 요청
```
Coordinator에게:
"프로젝트 코드를 분석하고 개선점을 찾아줘"
```

→ Issue Writer가 분석 후 GitHub Issues 작성

### 이슈 실행
```
Coordinator에게:
"우선순위 높은 Issues를 완료해줘"
```

→ Issue Runner가 구현 및 테스트 완료

### 문서 개선
```
Coordinator에게:
"README와 soul.md를 최신화해줘"
```

→ Doc Optimizer가 문서 검토 및 개선

## 🎯 팀의 특징

✅ **전문화**: 각 팀이 자신의 영역에 집중
✅ **협력**: 하나의 공유 워크스페이스에서 작업
✅ **체계성**: 분석→실행→문서화의 순환 구조
✅ **확장성**: 필요시 팀원 추가 가능

## 📍 설정 위치

에이전트 설정 파일:
- `.claude/agents/issue-writer.yaml` - Issue 분석/작성
- `.claude/agents/issue-runner.yaml` - Issue 실행
- `.claude/agents/doc-optimizer.yaml` - 문서 최적화
- `.claude/agents/coordinator.yaml` - 팀 조율 (multiagent)
- `.claude/agents/environment.yaml` - 작업 환경 설정

## 💡 팁

1. **명확한 요청**: Coordinator에게 구체적 목표 제시
2. **우선순위**: "높음", "중간", "낮음"으로 명시
3. **피드백**: 각 팀의 작업 결과에 대해 의견 제시
4. **정기 검토**: 일정 주기로 팀 성과 평가

---

마지막 업데이트: 2026-06-12
