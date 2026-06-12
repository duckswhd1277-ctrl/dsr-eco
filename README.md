# 🔥 HEAT NO 자동 매칭 도구

철강 제조 현장에서 **강종 + 선경 + ROD MAKER 기준으로 HEAT NO를 자동 매칭**하고, 정리파일에 즉시 반영하는 도구입니다.

## 🤖 Claude Agent Teams + Harness Architecture ✨ [NEW]

이 프로젝트는 **Claude Harness Architecture**를 통해 체계적인 자동화를 수행합니다.

### 3-Tier 하네스 구조

```
┌─ TIER 1: Coordinator (Manual Agentic Loop) ────────┐
│  상태 머신: ANALYZE → EXECUTE → DOCUMENT → VERIFY   │
│  에러 처리 & 롤백 메커니즘                          │
└────────────────────────────────────────────────────┘
         ↓
┌─ TIER 2: Specialized Agents (Tool Runners) ───────┐
│  Issue Writer | Issue Runner | Doc Optimizer       │
│  각 에이전트가 자신의 도구를 활용                   │
└────────────────────────────────────────────────────┘
         ↓
┌─ TIER 3: Tools (Server-side & Client-side) ──────┐
│  GitHub CLI | Code Execution | Memory Tool         │
│  WebFetch | Bash | heat_no_mapper.html             │
└────────────────────────────────────────────────────┘
```

### 아키텍처 문서

- 📐 [`하네스 아키텍처 설계`](./.claude/HARNESS_ARCHITECTURE.md) - 전체 구조 및 개념
- 🔄 [`Coordinator Manual Loop`](./.claude/COORDINATOR_MANUAL_LOOP.md) - 상태 머신 상세 구현
- 🛠️ [`Tool Runner 패턴`](./.claude/TOOL_RUNNER_PATTERNS.md) - 3개 에이전트 구현
- 💾 [`Memory Schema`](./.claude/MEMORY_SCHEMA.md) - 상태 영속성 설계
- 📊 [`루브릭 검증 프레임워크`](./.claude/RUBRIC_VALIDATION_FRAMEWORK.md) - 품질 평가 & 하네스 통합

### 핵심 팀 역할

- **Coordinator** (수동 루프 제어): 4단계 사이클 조율, 상태 머신 관리
- **Issue Writer** (분석 에이전트): 코드 분석 → 이슈 도출
- **Issue Runner** (실행 에이전트): 이슈 구현 → 테스트 → 커밋
- **Doc Optimizer** (문서 에이전트): 문서 검토 → 최신화 → 커밋

👉 [`Agent Teams 가이드`](./.claude/AGENTS.md) | [`빠른 시작`](./.claude/agents/QUICKSTART.md)

---

## 🚀 빠른 시작

### 🔥 HEAT NO 자동 매칭 도구
```bash
# 1. 브라우저에서 열기
./heat_no_mapper.html

# 2. 정리파일(수출).xls + OT 열처리.xls 선택
# 3. 📊 파일 분석하기 → 자동 매칭
# 4. 💾 결과 다운로드 → 정리파일에 HEAT NO 입력
```

---

## 📋 개요

- **용도**: HEAT NO 자동 매칭 및 정리파일 업데이트
- **기준**: 강종 + 선경 + ROD MAKER(포스코)
- **입력**: OT 열처리 데이터 (WL 작업번호 제외)
- **출력**: 정리파일(수출).xls에 HEAT NO 자동 입력

---

## 🎯 주요 기능
- **자동 저장**: 모든 데이터는 브라우저 LocalStorage에 저장
- **CSV 내보내기**: 엑셀에서 분석 가능한 형식
- **크로스 브라우저**: Chrome, Edge, Firefox 모두 지원

---

## 🔧 HEAT NO 자동 매칭 도구 (heat_no_mapper.html)

철강 제조 현장에서 **강종 + 선경 + ROD MAKER 기준 HEAT NO 자동 매칭**을 수행합니다.

### 주요 기능

✨ **정확한 3단계 매칭**
- 1단계: 강종 + 선경 + ROD MAKER(포스코) 매칭 (가장 정확)
- 2단계: 제조번호 매칭 (폴백)
- 3단계: 원재료 조회 파일 확인 (최종 검증)
- **WL 작업번호 자동 제외**

📊 **OT 열처리 기준 미리보기**
- OT 열처리 파일 데이터 중심 표시
- 테이블: 제조번호 | 작업번호 | 선경 | 거래처 | HEAT NO | 상태
- 모든 컬럼 정렬 가능 (↑/↓)
- 상태: ✅ 정리파일에 존재 / ⚠️ 신규

📥 **결과 다운로드**
- 💾 정리파일(수출).xls에 HEAT NO 자동 입력
- 열처리 데이터 기준으로 정확한 매칭 결과 제공

### 사용 방법

1. **파일 선택**
   - 📊 정리파일(수출).xls: 제품 정보
   - 🔥 OT 열처리.xls: 열처리 데이터 (WL 제외)
   - 🌾 원재료 조회 파일 (선택): 추가 HEAT NO 보정

2. **분석 실행**
   - "📊 파일 분석하기" 버튼 클릭
   - 자동으로 매칭 시작

3. **결과 확인**
   - 미리보기 테이블 (OT 열처리 기준)
   - 제조번호, 작업번호, 선경, 거래처 확인
   - 헤더 클릭으로 정렬

4. **결과 적용**
   - "💾 결과 다운로드" 클릭
   - 정리파일에 HEAT NO 자동 입력

---

## ⚙️ 3단계 매칭 로직

```
1단계: 강종 + 선경 + ROD MAKER(포스코)
       ↓ 가장 정확한 매칭 (우선 사용)
2단계: 제조번호 매칭
       ↓ 폴백 (1단계 실패 시)
3단계: 원재료 조회 파일 확인
       ↓ 최종 검증
결과: HEAT NO 확정 → 정리파일에 입력
```

---

## 📊 미리보기 테이블

| 제조번호 | 작업번호 | 선경 | 거래처 | HEAT NO | 상태 |
|---------|---------|------|------|--------|------|
| OT 기준 | OT 기준 | OT 기준 | OT 기준 | OT | 정리파일 매칭 여부 |

- ✅ 정리파일에 존재
- ⚠️ 신규 항목

**정렬**: 모든 컬럼 클릭으로 오름/내림차순 정렬 가능

---

## 🔧 기술 스택

- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **파일 처리**: Excel 파일 읽기/쓰기 (XLSX)
- **호환성**: Chrome, Edge, Firefox, Safari

---

## 📋 필터링 규칙

- **WL 작업번호 자동 제외**: OT 열처리 파일의 작업번호가 'WL'로 시작하는 항목은 매칭에서 제외
- **제조번호 매칭**: 정리파일과 OT 파일의 제조번호 비교
- **강종 정규화**: 숫자만 추출하여 비교 (SAE9254 = 9254)
- **선경 오차 허용**: ±0.5mm 범위에서 매칭

---

## 👥 사용 대상

- **현장 담당자**: 원재료 확인 및 HEAT NO 기록
- **품질팀**: 열처리 데이터 관리
- **생산팀**: 제품 정보 업데이트

---

## 📝 버전 히스토리

### v2.0 (2026-06-12) - HEAT NO 도구 메이저 업데이트
- ✅ OT 열처리 파일 기준 미리보기
- ✅ 강종 + 선경 + ROD MAKER 정확 매칭
- ✅ 작업번호 'WL' 자동 필터링
- ✅ 3단계 매칭 로직 구현
- ✅ 모든 컬럼 정렬 기능

### v1.0 (2026-06-11) - 초기 버전
- ✅ 기본 HEAT NO 매칭 기능
- ✅ Excel 파일 읽기/쓰기
- ✅ 미리보기 테이블

---

## 📞 문의

문제나 제안사항은 [Issues 페이지](../../issues)에서 등록해주세요.

---

**마지막 업데이트**: 2026년 6월 12일
