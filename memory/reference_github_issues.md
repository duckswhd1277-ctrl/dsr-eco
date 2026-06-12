---
name: reference_github_issues
description: GitHub Issues 관리 및 조회 방법, 이슈 템플릿
metadata:
  type: reference
---

## GitHub Issues 현황

**저장소**: AI REPORT  
**URL**: https://github.com/dsr-eco/AI-REPORT  
**이슈 조회**: `gh issue list --state all --json number,title,state`

## 이슈 처리 패턴

### 1. Issue 등록 단계
```markdown
## 문제 상황
설명...

## 원하는 결과
설명...

## 재현 방법
1. 단계 1
2. 단계 2

## 추가 정보
- 환경: Chrome, Edge 등
- 스크린샷
```

### 2. 요청 방식
```
"이 부분을 바꿔줄래?"
→ 나: Issue 등록
→ 당신: "skill로 해결해줄래?"
→ 나: 구현 + Commit & Push + Issue closed
```

## 최근 사이클 이슈들

**CYCLE_001 (2026-06-12 완료)**:
- `#38`: 파일 유효성 검증 부족
- `#39`: 큰 파일 처리 UI 응답성 문제
- `#40`: 같은 제조번호 여러 개 중 첫 번째만 매칭
- `#41`: 비어있는 HEAT NO 처리 방식 불명확
- `#42`: 미리보기 테이블 행 수 선택 불가
- `#43-48`: 추가 개선사항 (OPEN)

## 이슈 작성 가이드

**제목 작성**:
- ✅ 좋음: "bug: 비어있는 HEAT NO 처리 방식 불명확"
- ✅ 좋음: "feat: Z열에 Excel 수식 입력 - 동적 HEAT NO 계산"
- ❌ 나쁨: "뭔가 이상해"

**설명 작성**:
- 문제를 명확히 (현재 → 원하는 결과)
- 재현 방법 상세히
- 스크린샷 첨부
