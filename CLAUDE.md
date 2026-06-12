# CLAUDE.md - Claude와의 협업 가이드

이 파일은 **이 프로젝트에서 Claude Code와 효과적으로 협업하는 방법**을 정의합니다.

---

## 🎯 나(Claude)의 역할

### ✅ 할 수 있는 것
- HTML/CSS/JavaScript 코드 작성 및 수정
- GitHub Issues 자동 등록 및 관리
- Commit 및 Push 자동화
- 코드 리팩토링 및 최적화
- 버그 수정 및 개선사항 구현
- 문서 작성 (README, soul.md 등)

### ❌ 할 수 없는 것
- 실시간 모니터링 (주기적 체크만 가능)
- 최종 결정 (당신의 승인 필요)
- 프로젝트 방향 결정 (당신과 함께 논의)
- 보안 감사 (제한적 검토만 가능)

### 🤝 함께 할 것
- 아키텍처 설계
- UI/UX 개선
- 기술 결정사항
- 프로젝트 로드맵

---

## 📝 효과적인 요청 방법

### 패턴 1: Issue 먼저 등록 (권장)
```
당신: "이 부분을 이렇게 바꿔주면 좋을 것 같아"
    ↓
나: GitHub Issue 등록 (OPEN)
    ↓
당신: "skill로 해결해줄래?"
    ↓
나: 실제 수정 → Commit & Push → Issue closed
```

**언제 사용?**
- 수정사항이 명확할 때
- 나중을 위해 기록이 필요할 때
- 여러 개를 한번에 처리할 때

### 패턴 2: 즉시 처리
```
당신: "캘린더 색상을 파란색으로 바꿔줄래? 
      skill로 해결해줄래?"
    ↓
나: 즉시 수정 → Commit & Push → Issue 등록 후 closed
```

**언제 사용?**
- 빠른 피드백이 필요할 때
- 작은 수정사항일 때
- 실험적 변경일 때

---

## 💬 좋은 요청 vs 나쁜 요청

### ❌ 나쁜 요청
```
"대시보드를 좀 더 좋게 만들어줄래?"
→ 무엇을 해야 할지 불명확

"버튼이 마음에 안 들어"
→ 어떻게 바꿔야 할지 미정

"뭔가 더 추가하고 싶은데..."
→ 무엇을 추가할지 모호
```

### ✅ 좋은 요청
```
"할일 추가 버튼을 제거하고 
Excel 업로드로만 관리하게 해줄래?"
→ 정확한 변경사항, skill로 해결 가능

"캘린더의 일요일을 빨간색으로, 
토요일을 파란색으로 만들어줄까?"
→ 구체적인 스펙, 필요한 색상 명시

"Excel 양식에 담당자 필드를 추가하고,
파일 업로드 시 자동으로 반영되게 해줄래?"
→ 기능, 동작, 범위가 명확
```

---

## 📊 기대하는 응답 형식

### 1. 수정 내용 설명
```
✅ 완료된 작업:
- HTML에서 "새 항목 추가" 버튼 제거
- JavaScript에서 addTaskModal() 함수 제거
- 관련 CSS 스타일 제거
```

### 2. 변경 파일 명시
```
📁 수정된 파일:
- 안전환경PSM_통합관리_대시보드.html (75줄 삭제)
```

### 3. GitHub 기록
```
✅ 커밋: 0574b63
✅ Issue: #18 CLOSED
✅ Push: GitHub에 완료
```

### 4. 확인 사항
```
🔍 확인 완료:
- 캘린더 정상 작동
- Excel 업로드 정상 작동
- 반응형 레이아웃 정상
```

---

## 🔄 워크플로우 상세

### Issue 생명주기

**1️⃣ 등록 (당신의 요청)**
```
당신: "이거 바꿔줄래?"
나: GitHub Issue #N 등록 (상태: OPEN)
```

**2️⃣ 대기 (선택사항)**
```
당신: 검토, 추가 질문, 사소한 조정
나: Issue 내용 업데이트 (필요시)
```

**3️⃣ 실행**
```
당신: "skill로 해결해줄래?"
나: 
  1. 코드 수정
  2. GitHub에 Commit & Push
  3. Issue closed
```

**4️⃣ 완료**
```
GitHub Issues 페이지:
#N: 제목 [완료]
상태: CLOSED ✅
```

---

## 📋 코드 리뷰 기준

내가 코드를 수정할 때 확인하는 것:

### ✅ 일관성
- 함수명: camelCase
- 변수명: 명확한 영문
- 코드 스타일: 기존 코드와 동일

### ✅ 성능
- 불필요한 반복 제거
- DOM 접근 최소화
- 이벤트 리스너 정리

### ✅ 안정성
- 입력값 검증
- 에러 처리
- 데이터 무결성

### ✅ 접근성
- 키보드 네비게이션
- ARIA 라벨
- 스크린리더 지원

---

## 🏗️ Harness Architecture (하네스 구조) ✨ [NEW]

이 프로젝트는 **Claude 공식문서 기반의 Harness Architecture**를 채택했습니다.

### 아키텍처 개요

```
TIER 1: Coordinator (Manual Agentic Loop)
├─ 상태 머신: ANALYZING → EXECUTING → DOCUMENTING → VERIFYING
├─ 에러 처리 & 롤백 메커니즘
└─ Memory Tool을 통한 컨텍스트 관리

    ↓
    
TIER 2: Specialized Agents (Tool Runners)
├─ Issue Writer: 코드 분석 → 이슈 발견
├─ Issue Runner: 이슈 구현 → 테스트 → 커밋
└─ Doc Optimizer: 문서 검토 → 최신화

    ↓
    
TIER 3: Tools
├─ code_execution (Python 실행)
├─ web_fetch (문서 조회)
├─ bash (git, gh CLI)
├─ memory (상태 영속성)
└─ heat_no_mapper.html (클라이언트)
```

### 각 Tier의 역할

#### TIER 1: Coordinator (나의 역할)
- **패턴**: Manual Agentic Loop (사용자/상위 에이전트가 루프 제어)
- **책임**: 4단계 사이클 조율, 상태 관리, 에러 처리
- **상태 추적**: 각 단계의 성공/실패를 명시적으로 관리
- **Memory 관리**: 사이클별 컨텍스트 저장 및 롤백 지원

#### TIER 2: Specialized Agents
- **패턴**: Tool Runner (SDK가 도구 루프 자동 관리)
- **Issue Writer**: 
  - 도구: code_execution, web_fetch, memory
  - 산출물: findings (JSON)
  - confidence >= 0.8만 포함

- **Issue Runner**:
  - 도구: bash, code_execution, memory
  - 산출물: completions (JSON)
  - 에러 처리: conflict, test fail, implementation impossible

- **Doc Optimizer**:
  - 도구: web_fetch, bash, code_execution
  - 산출물: doc_updates (JSON)
  - 링크 검증 및 일관성 확인

#### TIER 3: Tools
- **code_execution**: Python으로 파일 분석, 코드 수정
- **web_fetch**: README, soul.md, CLAUDE.md 읽기
- **bash**: git commit, push, gh issue 관리
- **memory**: 상태 저장, 중복 방지, 롤백 포인트 관리

### 워크플로우 예시

```
사용자 요청
    ↓
Coordinator (Manual Loop)
├─ ANALYZING
│  └─ Issue Writer (Tool Runner) 호출
│     └─ code_execution, web_fetch로 분석
│        └─ findings JSON 반환
│
├─ EXECUTING
│  └─ Issue Runner (Tool Runner) 호출
│     └─ bash, code_execution으로 구현
│        └─ completions JSON 반환
│
├─ DOCUMENTING
│  └─ Doc Optimizer (Tool Runner) 호출
│     └─ web_fetch, bash로 문서화
│        └─ doc_updates JSON 반환
│
├─ VERIFYING
│  └─ 검증: 성공률, 커버리지, breaking change 확인
│     ├─ 통과 → 다음 사이클
│     └─ 실패 → 롤백 또는 종료
│
└─ 최종 리포트 생성
```

### 핵심 특징

| 특징 | 구현 방식 |
|------|---------|
| **상태 관리** | CycleContext 데이터 구조 + Memory Tool |
| **중복 방지** | Issue Writer가 과거 findings 참고 |
| **롤백 전략** | git reset + memory restore |
| **에러 분류** | RECOVERABLE (재시도), ROLLBACK_NEEDED, UNRECOVERABLE |
| **메트릭 추적** | findings_count, execution_success_rate, documentation_coverage |
| **리포트** | 최종 사이클, 성공률, 소요 시간, 다음 단계 추천 |

### 아키텍처 문서

당신은 다음 문서들을 읽으면 하네스 구조를 완벽히 이해할 수 있습니다:

1. **`.claude/HARNESS_ARCHITECTURE.md`**
   - 3-Tier 구조 개요
   - Manual Loop vs Tool Runner 개념
   - 용어 정의 (Coordinator, Tool Runner, Memory, Rollback 등)

2. **`.claude/COORDINATOR_MANUAL_LOOP.md`**
   - Coordinator 상태 머신 상세 구현
   - 각 단계별 구현 코드 (ANALYZE, EXECUTE, DOCUMENT, VERIFY)
   - 메모리 통합, 에러 처리, 최종화

3. **`.claude/TOOL_RUNNER_PATTERNS.md`**
   - Issue Writer 구현 (System Prompt, Tool 호출)
   - Issue Runner 구현 (Rollback 메커니즘)
   - Doc Optimizer 구현 (링크 검증)

4. **`.claude/MEMORY_SCHEMA.md`**
   - 저장소 구조 (경로 계층)
   - JSON 스키마 (findings, completions, doc_updates)
   - 쿼리 함수 (중복 확인, 통계, breaking change 감지)

5. **`.claude/RUBRIC_VALIDATION_FRAMEWORK.md`** ✨ NEW
   - 품질 루브릭 (9개 차원, 100점 만점)
   - VERIFYING 단계에 루브릭 검증 통합
   - 각 Tool Runner가 루브릭 기준을 따르도록 설정
   - Memory Schema에 루브릭 점수 저장 및 트렌드 분석

---

## 🎓 내가 참고하는 문서

나는 다음 문서들을 기반으로 작업합니다:

1. **soul.md**: 프로젝트 아키텍처, 원칙
2. **CLAUDE.md**: 이 파일 (협업 가이드)
3. **README.md**: 사용자 매뉴얼
4. **GitHub Issues**: 구체적 요청사항
5. **하네스 아키텍처** (위 4개 문서):
   - HARNESS_ARCHITECTURE.md
   - COORDINATOR_MANUAL_LOOP.md
   - TOOL_RUNNER_PATTERNS.md
   - MEMORY_SCHEMA.md

당신이 이 파일들을 업데이트하면, 나의 작업 품질도 향상됩니다!

---

## 🚫 피해야 할 요청

### ❌ 실행 불가능한 요청
```
"뭔가 더 멋지게 만들어줄래?"
→ 구체적이지 않음

"기타 등등 개선해줘"
→ 범위가 불명확

"알아서 좋게 해줄래?"
→ 최종 결정은 당신이 해야 함
```

### ❌ 권장하지 않는 요청
```
"외부 라이브러리 추가해줄래?"
→ soul.md의 철학과 배치

"데이터베이스 연동해줄래?"
→ 서버 구축 필요, 범위 커짐

"완전히 다른 디자인으로 리디자인해줄래?"
→ 큰 변경, 당신과 함께 논의 필요
```

---

## 💡 팁

### 효율적 협업 팁
1. **Issue 설명은 상세하게**
   - 현재: "이렇게 되어 있음"
   - 원하는 것: "이렇게 되었으면 함"
   - 이유: "왜 필요한가"

2. **여러 개 요청 시 한번에**
   - Issue 5개 등록 후
   - "모두 skill로 해결해줄래?"
   - 훨씬 효율적

3. **변경 후 검증**
   - 브라우저에서 직접 테스트
   - 이상하면 즉시 말하기
   - 피드백은 빠를수록 좋음

4. **문서 업데이트**
   - soul.md 변경시 알려주기
   - README 수정사항 공유
   - 나의 작업 범위 명확히

---

## 📞 특수한 상황

### "이전에 했던 것 같은데..."
이미 작업한 내용은 GitHub Issues에 기록되어 있습니다.
```
당신: "#5번 이슈처럼 처리해줄래?"
나: GitHub에서 #5를 참고해서 유사하게 처리
```

### "다시 원래대로 돌려줄래?"
가능하지만, 이전 커밋으로 복구하는 것이 정확합니다.
```
당신: "#10 이슈 이전으로 롤백해줄래?"
나: git revert로 안전하게 처리
```

### "이거 왜 이렇게 했어?"
내 작업의 근거는 GitHub Issues와 커밋 메시지에 있습니다.
```
당신: "이 부분은 왜 이렇게 구현했어?"
나: "Issue #X에서 요청했던 사항입니다" (링크 제공)
```

---

## ✨ 최종 원칙

> **명확하고, 구체적이고, 함께 결정하자**

1. **명확함**: 무엇을, 왜, 어떻게를 명시
2. **구체성**: 추상적 표현 피하기
3. **협력**: 큰 결정은 함께 하기
4. **신뢰**: 작은 결정은 내게 맡기기

---

**함께 만들어가는 프로젝트!** 🚀

---

**마지막 업데이트**: 2026년 6월 11일
