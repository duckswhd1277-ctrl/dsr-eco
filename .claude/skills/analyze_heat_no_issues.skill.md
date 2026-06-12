---
name: analyze_heat_no_issues
description: HEAT NO 매칭 로직의 문제점을 분석하고 GitHub Issues로 정식화
metadata:
  type: skill
  category: analysis
  tier: TIER 2 (Issue Writer)
---

# HEAT NO 이슈 분석 스킬

HEAT NO 매칭 도구의 코드를 분석하여 버그, 개선점, 테스트 케이스를 발견하고 GitHub Issues로 등록합니다.

## 사용 시점

```
"HEAT NO 도구 코드를 분석하고 개선점을 찾아줄래?"
→ 이 스킬 실행
→ GitHub Issues 자동 생성 (confidence >= 0.8)
```

## 분석 항목

### 1. Functionality (기능성)
- [ ] 3단계 매칭 로직이 모든 케이스 처리하는가?
- [ ] WL 작업번호 필터링이 정확한가?
- [ ] 강종 정규화가 예외 케이스를 처리하는가?
- [ ] Edge case: 빈 값, 중복, 특수 문자

### 2. Code Quality (코드 품질)
- [ ] 함수가 80줄 이하인가?
- [ ] camelCase 규칙 준수 여부
- [ ] 매직 넘버 (25, 19 등)가 상수화되었는가?
- [ ] 복잡한 로직에 주석이 있는가?

### 3. Architecture (아키텍처)
- [ ] 함수 단일 책임 원칙 준수
- [ ] 관심사의 분리 (파일 읽기, 매칭, 다운로드)
- [ ] 확장 가능한 구조인가?

### 4. Testing (테스트)
- [ ] 자동화된 테스트 있는가?
- [ ] 수동 테스트 체크리스트 있는가?
- [ ] 브라우저 호환성 테스트 (Chrome, Edge, Firefox)
- [ ] 성능 테스트 (대용량 파일)

### 5. Documentation (문서화)
- [ ] README 최신인가?
- [ ] 3단계 매칭 로직이 명확히 설명되어 있는가?
- [ ] 사용자 가이드 완전한가?

## Issue 템플릿

```markdown
## 제목
[타입]: [간단한 설명]

예시:
- bug: 빈 HEAT NO 처리 미흡
- feat: Z열에 Excel 수식 입력
- test: 자동화 테스트 추가

## 문제 상황
현재 상태를 명확히 기술

## 원하는 결과
구체적인 변경사항 설명

## 우선순위
P1 (높음) / P2 (중간) / P3 (낮음)

## 신뢰도
confidence: 0.8 이상 (0.0~1.0)
```

## 산출물

**JSON 형식** (memory에 저장):
```json
{
  "findings": [
    {
      "id": "issue-XXX",
      "type": "bug|feature|refactor|docs|test",
      "title": "...",
      "description": "...",
      "rubric_dimension": "functionality|code_quality|...",
      "priority": "P1|P2|P3",
      "confidence": 0.85,
      "evidence": "파일명:줄번호 또는 현상 설명"
    }
  ],
  "total_findings": 5,
  "high_confidence_findings": 4
}
```

## 주의사항

- ❌ 추측으로 issue 작성 금지
- ✅ 코드에서 실제 발견한 것만 포함
- ✅ confidence >= 0.8만 포함
- ✅ 중복 issue 확인 후 작성
