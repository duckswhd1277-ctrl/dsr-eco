# Agent Teams Quick Start

Claude Agent Teams를 사용하여 프로젝트를 개선하는 방법입니다.

## 🎬 빠른 시작

### 1단계: Coordinator에게 작업 요청

```bash
"프로젝트를 분석하고 개선할 점을 찾아줄래?"
```

Coordinator가 Issue Writer를 통해:
- 코드 분석
- 버그 및 개선점 발견
- GitHub Issues 자동 생성

### 2단계: 우선순위 Issues 실행

```bash
"생성된 Issues 중에서 중요한 것부터 처리해줄래?"
```

Issue Runner가:
- Issue 상태 확인
- 구현 및 테스트
- 완료된 Issue 종료

### 3단계: 문서 업데이트

```bash
"변경사항을 README와 가이드에 반영해줄래?"
```

Doc Optimizer가:
- README 업데이트
- 가이드 문서 최신화
- 사용 설명서 개선

## 📊 실행 예시

### 예시 1: 코드 분석 및 버그 찾기

```
요청: "heat_no_mapper.html 코드를 분석하고 잠재적 문제를 찾아줄래?"

결과:
- Issue Writer가 코드 분석
- 5개의 개선 Issue 생성
- 우선순위 순으로 정렬
```

### 예시 2: 우선순위 높은 기능 구현

```
요청: "Issue #1~#3을 완료해줄래? 테스트도 함께."

결과:
- Issue Runner가 각 Issue 구현
- 테스트 및 검증
- Issue 종료 및 커밋
```

### 예시 3: 프로젝트 문서 개선

```
요청: "README와 heat_no_mapper.md를 최신화해줄래?"

결과:
- Doc Optimizer가 문서 검토
- 누락된 설명 추가
- 사용 예제 개선
```

## 🎯 각 팀의 역할

| 팀 | 입력 | 출력 | 시간 |
|----|------|------|------|
| **Issue Writer** | 프로젝트 코드 | GitHub Issues | 5~10분 |
| **Issue Runner** | GitHub Issues | 구현된 코드 + 테스트 | 10~30분 |
| **Doc Optimizer** | 변경사항 | 업데이트된 문서 | 5~10분 |

## 💬 효과적인 요청 팁

✅ **구체적인 목표**
```
"heat_no_mapper 에러 처리를 개선해줄래?"
```

❌ **모호한 요청**
```
"뭔가 개선해줄래?"
```

---

더 자세한 내용: [`AGENTS.md`](AGENTS.md)
