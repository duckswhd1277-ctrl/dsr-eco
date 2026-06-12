---
name: feedback_harness_development
description: 하네스 아키텍처 구축 과정에서 얻은 피드백 및 검증된 접근법
metadata:
  type: feedback
---

## 3-Tier 하네스 설계 검증됨

**규칙**: Claude Agent Teams를 통한 3-Tier 하네스 구조 (TIER 1: Coordinator, TIER 2: Agents, TIER 3: Tools) 적용 가능

**Why**: 복잡한 프로젝트 개선을 체계적으로 관리할 수 있고, 각 에이전트가 특화된 역할 수행

**How to apply**: 새로운 기능 추가 시:
- Issue Writer가 분석 → 이슈 작성
- Issue Runner가 구현 → 테스트 → 커밋
- Doc Optimizer가 문서 업데이트
- Coordinator가 전체 조율

## 루브릭 기반 평가 체계 설계됨

**규칙**: 9개 차원 (Functionality, Code Quality, Architecture 등) + 100점 만점 시스템으로 품질 측정

**Why**: 객관적인 품질 추적 가능, 개선점 명확화

**How to apply**: 각 사이클 후 CYCLE_XXX_RUBRIC_EVALUATION.md 생성하여 점수 기록

## Issue 기반 개발 워크플로우 확립

**규칙**: GitHub Issue와 커밋을 `Closes #XX` 형식으로 연결

**Why**: 작업 추적성 확보, 나중에 기록 검색 용이

**How to apply**: 
- 모든 기능은 Issue로 등록
- 커밋 메시지에 `Closes #XX` 포함
- Issue 템플릿 사용 (제목: 구체적, 설명: 왜/무엇)

## soul.md는 철저한 원칙 문서로 관리

**규칙**: soul.md에 정의된 기술 스택(vanilla JS, 단일 파일, 라이브러리 금지)과 개발 원칙을 엄격히 준수

**Why**: 프로젝트 일관성 유지, 유지보수 용이성

**How to apply**: 
- 새 기능 추가 시 soul.md 규칙 확인
- 라이브러리 추가는 사전 협의
- 코드 스타일은 soul.md 정의 따름
