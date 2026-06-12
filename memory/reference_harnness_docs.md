---
name: reference_harness_docs
description: 프로젝트의 하네스 아키텍처 관련 문서 위치 및 내용 개요
metadata:
  type: reference
---

## 하네스 아키텍처 문서 맵

프로젝트 내 하네스 관련 문서들은 모두 `.claude/` 디렉토리에 저장되어 있습니다.

### 1. 아키텍처 설계 문서

**📐 HARNESS_ARCHITECTURE.md**
- **내용**: 3-Tier 구조 개요, Manual Loop vs Tool Runner 개념
- **용도**: 전체 구조 이해
- **작성일**: 2026-06-12

**🔄 COORDINATOR_MANUAL_LOOP.md**
- **내용**: Coordinator 상태 머신 상세 구현 (ANALYZE → EXECUTE → DOCUMENT → VERIFY)
- **용도**: 사이클 진행 방식 이해
- **작성일**: 2026-06-12

**🛠️ TOOL_RUNNER_PATTERNS.md**
- **내용**: Issue Writer, Issue Runner, Doc Optimizer 3개 에이전트 구현 패턴
- **용도**: 각 에이전트의 역할 및 도구 사용법
- **작성일**: 2026-06-12

**💾 MEMORY_SCHEMA.md**
- **내용**: 상태 영속성 설계, JSON 스키마, 쿼리 함수
- **용도**: Memory Tool 사용 방식, 데이터 저장 구조
- **작성일**: 2026-06-12

### 2. 품질 평가 문서

**📊 RUBRIC_VALIDATION_FRAMEWORK.md**
- **내용**: 9개 차원 (Functionality, Code Quality 등) 루브릭, 점수 계산, Pass/Fail 판정
- **용도**: 사이클별 품질 평가 기준
- **상태**: 설계 완료, 구현 진행 중
- **작성일**: 2026-06-12

### 3. 에이전트 설정

**🤖 AGENTS.md**
- **내용**: Claude Agent Teams 구성, 팀 역할, 작업 흐름
- **용도**: 에이전트 협력 방식 이해
- **작성일**: 2026-06-12

**📁 agents/ 디렉토리**
- `issue-writer.yaml`: 분석 에이전트 설정
- `issue-runner.yaml`: 실행 에이전트 설정
- `doc-optimizer.yaml`: 문서 에이전트 설정
- `coordinator.yaml`: 조율 에이전트 설정
- `environment.yaml`: 환경 변수 설정

### 4. 평가 기록

**📋 CYCLE_001_RUBRIC_EVALUATION.md**
- **내용**: 첫 사이클 평가 결과 (88/100, Gold)
- **용도**: 프로젝트 진행 추적
- **작성일**: 2026-06-12

## 다음 단계

1. **RUBRIC 구현** (P2): 자동 평가 스크립트 추가
2. **Agent 활성화** (P3): 실제 에이전트 팀 운영 시작
3. **CYCLE_002 평가** (P4): 다음 평가 수행

## 문서 업데이트 규칙

- 새로운 사이클 시작 시: CYCLE_XXX_RUBRIC_EVALUATION.md 생성
- 아키텍처 변경 시: 해당 문서 (HARNESS_ARCHITECTURE.md 등) 업데이트
- 규칙 변경 시: soul.md 또는 CLAUDE.md 업데이트
