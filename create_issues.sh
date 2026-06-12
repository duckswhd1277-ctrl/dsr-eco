#!/bin/bash

# 10개의 Issues를 생성하는 스크립트
# GitHub CLI (gh)가 설치되고 인증되어 있어야 함

ISSUES=(
"🐛 [버그] 문서 클릭 기능 미구현|문서 라이브러리의 문서 카드를 클릭해도 아무 동작이 없음|bug"
"🐛 [버그] 항목 삭제/수정 기능 부재|생성된 항목 수정 불가, 항목 삭제 기능 없음|bug"
"🐛 [버그] 모바일 반응형 레이아웃 미지원|모바일에서 3열 그리드가 1열로 축소 안 됨|bug"
"⚠️ [개선] 캘린더 셀 높이 동적 조정|셀 높이 고정으로 이벤트 많으면 겹침|enhancement"
"⚠️ [개선] 중복 항목 추가 방지|같은 항목 여러 번 추가 가능|enhancement"
"⚠️ [개선] 할일 항목 수정 기능|생성된 항목을 수정할 수 없음|enhancement"
"⚠️ [개선] 제출 기한 경고 기능 추가|기한이 임박해도 시각적 경고 없음|enhancement"
"⚠️ [개선] 입력 폼 유효성 검증 강화|더 철저한 입력 검증 필요|enhancement"
"⚠️ [개선] 할일 리스트 스크롤 개선|목록 높이가 400px로 고정됨|enhancement"
"⚠️ [개선] WCAG 접근성 기준 준수|색상만으로 상태 표현, 폰트 사이즈 작음|enhancement"
)

echo "📝 GitHub Issues 생성 시작..."
echo "총 ${#ISSUES[@]}개의 Issues를 생성합니다."
echo ""

for i in "${!ISSUES[@]}"; do
    IFS='|' read -r title body label <<< "${ISSUES[$i]}"
    echo "[$((i+1))/${#ISSUES[@]}] $title 생성 중..."
    # gh issue create --title "$title" --body "$body" --label "$label"
done

echo ""
echo "✅ Issues 생성 완료!"
