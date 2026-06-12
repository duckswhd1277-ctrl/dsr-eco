---
name: implement_heat_no_matching
description: GitHub Issue를 구현하고, 테스트 후, heat_no_mapper.html을 수정하며, 커밋해주는 스킬
metadata:
  type: skill
  category: implementation
  tier: TIER 2 (Issue Runner)
---

# HEAT NO 매칭 구현 스킬

GitHub Issue를 실제로 구현하고, 코드를 수정하며, 테스트하고 커밋합니다.

## 사용 시점

```
Issue #XX가 등록된 후:
"Issue #XX를 구현해줄래? (또는 skill로 해결해줄래?)"
→ 이 스킬 실행
→ 코드 수정 + 테스트 + 커밋 + Issue closed
```

## 구현 체크리스트

### 1. 코드 수정
- [ ] issue 내용 정확히 이해
- [ ] soul.md 규칙 준수 확인 (라이브러리, 구조 등)
- [ ] 변경 범위 최소화 (필요한 부분만)
- [ ] camelCase 준수, 함수 80줄 이하

### 2. 테스트
- [ ] 브라우저에서 직접 테스트 (heat_no_mapper.html 열기)
- [ ] 정상 케이스 확인
- [ ] Edge case 테스트 (빈 파일, 큰 파일, 특수 문자 등)
- [ ] 여러 브라우저 테스트 (Chrome, Edge, Firefox)

### 3. 커밋
- [ ] 메시지 형식: `[타입]: [설명] - Closes #XX`
  - 예: `fix: 빈 HEAT NO 처리 개선 - Closes #41`
  - 예: `feat: Z열에 Excel 수식 입력 - Closes #48`
- [ ] 변경 파일 명시
- [ ] 간단한 변경 사유 포함

### 4. GitHub 업데이트
- [ ] Issue에 구현 내용 코멘트
- [ ] Issue 자동 종료 (Closes 사용) 확인

## 변경 대상 파일

**주요 파일**:
```
heat_no_mapper.html
├── CSS 섹션 (200줄)
├── HTML 섹션 (100줄)
└── JavaScript 섹션 (300줄)
    ├── readExcel() - 파일 읽기
    ├── matchData() - 3단계 매칭
    ├── filterWLRows() - WL 필터
    ├── downloadFullFile() - 전체 다운로드
    └── downloadMatchesOnly() - 결과만 다운로드
```

## 주의사항

### ❌ 피해야 할 것
- 외부 라이브러리 추가 (ExcelJS 제외)
- 함수 80줄 초과
- 과도한 주석
- heat_no_mapper.html 구조 크게 변경

### ✅ 준수할 것
- soul.md 개발 원칙 따르기
- 변경 범위 최소화
- 테스트 후 커밋
- 명확한 커밋 메시지

## 에러 처리 규칙

**파일 처리 오류**:
```javascript
if (!file || !['application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'text/csv'].includes(file.type)) {
  alert('지원하는 파일 형식: .xls, .xlsx, .csv');
  return;
}
```

**데이터 검증**:
```javascript
if (!gritData || gritData.length === 0) {
  alert('파일에 데이터가 없습니다.');
  return;
}
```

## 산출물

**JSON 형식** (memory에 저장):
```json
{
  "completions": [
    {
      "issue_id": "#XX",
      "status": "success|failed",
      "changes": ["readExcel() 개선", "matchData() 수정"],
      "test_results": {
        "browsers_tested": 3,
        "functionality": "pass",
        "edge_cases": "pass|fail"
      },
      "commit_hash": "a1b2c3d"
    }
  ]
}
```

## 완료 시 확인

```bash
# 1. 로컬에서 테스트
open heat_no_mapper.html

# 2. 변경사항 확인
git status
git diff heat_no_mapper.html

# 3. 커밋
git commit -m "..."

# 4. Issue 확인
gh issue view #XX
```
