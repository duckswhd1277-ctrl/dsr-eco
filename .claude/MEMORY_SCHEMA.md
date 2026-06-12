# Memory Tool Schema 설계 가이드

**기술 스택**: Memory Tool (Anthropic Server-side)
**난이도**: Intermediate
**용도**: 상태 영속성, 컨텍스트 관리, 롤백 지원

---

## 개요

Memory Tool은 에이전트 간 상태를 공유하고, 사이클 간 정보를 유지하는 핵심 도구입니다.

```
Coordinator
    ↓ memory.write()
    ├── /project-enhancement/cycles/{n}
    ├── /project-enhancement/findings/
    ├── /project-enhancement/completions/
    └── /project-enhancement/documentation/
    
Issue Writer → memory.read() → 과거 분석 기록
Issue Runner → memory.write() → 진행 상황 기록
Doc Optimizer → memory.read() → 문서화 히스토리
```

---

## 저장소 구조

### 경로 계층

```
memory/
├── project-enhancement/              # 프로젝트 최상위
│   ├── cycles/                       # 각 사이클 기록
│   │   ├── 0/                        # 사이클 0
│   │   │   ├── context.json          # 상태 스냅샷
│   │   │   ├── findings.json         # 분석 결과
│   │   │   ├── completions.json      # 실행 결과
│   │   │   └── doc-updates.json      # 문서화 결과
│   │   └── 1/                        # 사이클 1
│   │       └── ...
│   │
│   ├── findings/                     # 누적 발견사항 (중복 방지)
│   │   ├── by-type/
│   │   │   ├── bugs.json
│   │   │   ├── features.json
│   │   │   ├── refactors.json
│   │   │   ├── docs.json
│   │   │   └── tests.json
│   │   └── by-priority/
│   │       ├── high.json
│   │       ├── medium.json
│   │       └── low.json
│   │
│   ├── completions/                  # 누적 완료 기록
│   │   ├── successful.json           # 성공한 이슈들
│   │   ├── failed.json               # 실패한 이슈들
│   │   └── stats.json                # 통계
│   │
│   ├── documentation/                # 문서화 히스토리
│   │   ├── README-versions.json      # README 변경 기록
│   │   ├── soul-md-versions.json     # soul.md 변경 기록
│   │   ├── CLAUDE-md-versions.json   # CLAUDE.md 변경 기록
│   │   └── broken-links.json         # 깨진 링크 기록
│   │
│   ├── git-state/                    # Git 상태 스냅샷
│   │   ├── checkpoint-{n}.json       # 각 사이클별 git sha
│   │   └── branch-history.json       # 브랜치 기록
│   │
│   └── metadata.json                 # 프로젝트 전체 메타데이터
│
└── session-info/                     # 세션 정보
    ├── user.json                     # 사용자 정보
    ├── environment.json              # 환경 정보
    └── settings.json                 # 설정 (model, effort 등)
```

---

## 스키마 정의

### 1. Cycle Context

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Cycle Context",
  "type": "object",
  "properties": {
    "cycle_id": {
      "type": "integer",
      "description": "사이클 번호 (0부터 시작)"
    },
    "started_at": {
      "type": "string",
      "format": "date-time",
      "description": "사이클 시작 시간 (ISO 8601)"
    },
    "completed_at": {
      "type": "string",
      "format": "date-time",
      "description": "사이클 완료 시간"
    },
    "state": {
      "type": "string",
      "enum": ["analyzing", "executing", "documenting", "verifying", "complete", "error"],
      "description": "현재 상태"
    },
    "findings": {
      "type": "array",
      "description": "분석 결과",
      "items": {
        "type": "object",
        "properties": {
          "id": {"type": "string"},
          "type": {"type": "string", "enum": ["bug", "feature", "refactor", "docs", "test"]},
          "title": {"type": "string"},
          "priority": {"type": "string", "enum": ["high", "medium", "low"]},
          "confidence": {"type": "number", "minimum": 0, "maximum": 1}
        }
      }
    },
    "completions": {
      "type": "array",
      "description": "실행 결과",
      "items": {
        "type": "object",
        "properties": {
          "issue_id": {"type": "string"},
          "status": {"type": "string", "enum": ["success", "failed", "partial"]},
          "commits": {"type": "array", "items": {"type": "string"}},
          "test_results": {
            "type": "object",
            "properties": {
              "passed": {"type": "integer"},
              "failed": {"type": "integer"},
              "skipped": {"type": "integer"}
            }
          }
        }
      }
    },
    "doc_updates": {
      "type": "array",
      "description": "문서화 결과",
      "items": {
        "type": "object",
        "properties": {
          "file": {"type": "string"},
          "status": {"type": "string", "enum": ["updated", "skipped"]},
          "changes_count": {"type": "integer"}
        }
      }
    },
    "metrics": {
      "type": "object",
      "properties": {
        "findings_count": {"type": "integer"},
        "execution_success_rate": {"type": "number", "minimum": 0, "maximum": 1},
        "documentation_coverage": {"type": "number", "minimum": 0, "maximum": 1},
        "duration_seconds": {"type": "number"}
      }
    },
    "git_state": {
      "type": "object",
      "properties": {
        "branch": {"type": "string"},
        "current_sha": {"type": "string", "description": "현재 commit hash"},
        "checkpoint_sha": {"type": "string", "description": "사이클 시작 시점 commit hash"}
      }
    },
    "errors": {
      "type": "array",
      "description": "발생한 에러 목록",
      "items": {
        "type": "object",
        "properties": {
          "timestamp": {"type": "string", "format": "date-time"},
          "error_type": {"type": "string"},
          "message": {"type": "string"},
          "recoverable": {"type": "boolean"}
        }
      }
    }
  },
  "required": ["cycle_id", "started_at", "state"]
}
```

### 2. Finding (발견사항)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Finding",
  "type": "object",
  "properties": {
    "id": {
      "type": "string",
      "pattern": "^issue-\\d{3}$",
      "description": "이슈 ID (issue-001 형식)"
    },
    "type": {
      "type": "string",
      "enum": ["bug", "feature", "refactor", "docs", "test"],
      "description": "이슈 타입"
    },
    "title": {
      "type": "string",
      "minLength": 10,
      "maxLength": 50,
      "description": "이슈 제목"
    },
    "description": {
      "type": "string",
      "description": "상세 설명 (Problem / Current State / Expected Behavior)"
    },
    "priority": {
      "type": "string",
      "enum": ["high", "medium", "low"],
      "description": "우선순위"
    },
    "estimated_effort": {
      "type": "string",
      "enum": ["1h", "2h", "4h", "8h", "16h"],
      "description": "예상 작업 시간"
    },
    "acceptance_criteria": {
      "type": "array",
      "items": {"type": "string"},
      "description": "수용 기준"
    },
    "confidence": {
      "type": "number",
      "minimum": 0,
      "maximum": 1,
      "description": "발견사항 신뢰도 (0.0~1.0, 0.8 이상만 포함)"
    },
    "discovered_at": {
      "type": "string",
      "format": "date-time",
      "description": "발견 시간"
    },
    "cycle_id": {
      "type": "integer",
      "description": "발견된 사이클 번호"
    },
    "tags": {
      "type": "array",
      "items": {"type": "string"},
      "description": "추가 태그 (예: performance, security, accessibility)"
    }
  },
  "required": ["id", "type", "title", "priority", "confidence", "discovered_at"]
}
```

### 3. Completion (완료 기록)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Completion",
  "type": "object",
  "properties": {
    "issue_id": {
      "type": "string",
      "pattern": "^issue-\\d{3}$"
    },
    "status": {
      "type": "string",
      "enum": ["success", "failed", "partial"],
      "description": "완료 상태"
    },
    "started_at": {
      "type": "string",
      "format": "date-time"
    },
    "completed_at": {
      "type": "string",
      "format": "date-time"
    },
    "commits": {
      "type": "array",
      "items": {"type": "string"},
      "description": "관련 commit hash 목록"
    },
    "test_results": {
      "type": "object",
      "properties": {
        "passed": {"type": "integer"},
        "failed": {"type": "integer"},
        "skipped": {"type": "integer"},
        "coverage_percent": {"type": "number", "minimum": 0, "maximum": 100}
      },
      "description": "테스트 결과"
    },
    "artifacts": {
      "type": "array",
      "items": {"type": "string"},
      "description": "생성/수정된 파일 목록"
    },
    "errors": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "type": {"type": "string"},
          "message": {"type": "string"},
          "resolved": {"type": "boolean"}
        }
      },
      "description": "발생한 에러들"
    },
    "github_issue_number": {
      "type": "integer",
      "description": "GitHub Issue 번호"
    },
    "pull_request_number": {
      "type": "integer",
      "description": "관련 PR 번호 (있으면)"
    }
  },
  "required": ["issue_id", "status", "started_at"]
}
```

### 4. Documentation Update

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Documentation Update",
  "type": "object",
  "properties": {
    "file": {
      "type": "string",
      "description": "수정된 파일 경로"
    },
    "status": {
      "type": "string",
      "enum": ["updated", "created", "skipped"],
      "description": "업데이트 상태"
    },
    "reason": {
      "type": "string",
      "description": "스킵한 이유 (status=skipped일 때)"
    },
    "changes": {
      "type": "array",
      "items": {"type": "string"},
      "description": "변경 사항 목록"
    },
    "changes_count": {
      "type": "integer",
      "description": "수정된 라인 수"
    },
    "commit": {
      "type": "string",
      "description": "관련 commit hash"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time"
    },
    "cycle_id": {
      "type": "integer"
    }
  },
  "required": ["file", "status", "updated_at"]
}
```

---

## 연산 쿼리 (Memory Tool 활용)

### 1. 중복 발견사항 방지

```python
def is_finding_duplicate(new_finding: Dict) -> bool:
    """새로운 발견사항이 기존에 있는지 확인"""
    
    # memory.read("/project-enhancement/findings/")
    # existing_findings = memory.read(...)
    
    existing_titles = {f["title"] for f in existing_findings}
    return new_finding["title"] in existing_titles
```

### 2. 최근 성공률 계산

```python
def get_recent_success_rate(cycles: int = 3) -> float:
    """최근 N 사이클의 성공률"""
    
    # recent_completions = memory.read(
    #     "/project-enhancement/completions/successful.json"
    # )
    # all_completions = memory.read(
    #     "/project-enhancement/completions/"
    # )
    
    successful = len([c for c in recent_completions if c["status"] == "success"])
    total = len([c for c in all_completions])
    
    return successful / total if total > 0 else 0.0
```

### 3. 브레이킹 체인지 감지

```python
def detect_breaking_changes(cycle_id: int, prev_cycle_id: int) -> List[str]:
    """사이클 간 breaking change 감지"""
    
    # current_cycle = memory.read(f"/project-enhancement/cycles/{cycle_id}/")
    # prev_cycle = memory.read(f"/project-enhancement/cycles/{prev_cycle_id}/")
    
    breaking_changes = []
    
    # Test 실패 여부 확인
    if current_cycle["completions"]:
        for comp in current_cycle["completions"]:
            test_failed = (
                comp.get("test_results", {}).get("failed", 0) > 0
            )
            if test_failed:
                breaking_changes.append(f"테스트 실패: {comp['issue_id']}")
    
    return breaking_changes
```

### 4. 예상 변수 추출

```python
def extract_metrics_trend(cycles: int = 5) -> Dict:
    """최근 N 사이클의 메트릭 트렌드"""
    
    trends = {
        "findings_count": [],
        "success_rate": [],
        "documentation_coverage": [],
        "avg_duration_seconds": []
    }
    
    # for i in range(cycles):
    #     cycle = memory.read(f"/project-enhancement/cycles/{i}/context.json")
    #     trends["findings_count"].append(cycle["metrics"]["findings_count"])
    #     trends["success_rate"].append(cycle["metrics"]["execution_success_rate"])
    #     ...
    
    return trends
```

---

## 저장 및 로드 구현

### Python SDK 예제

```python
from anthropic import Anthropic

class MemoryManager:
    def __init__(self, api_key: str):
        self.client = Anthropic(api_key=api_key)
    
    def save_cycle(self, cycle_id: int, context: Dict):
        """사이클 컨텍스트 저장"""
        
        # Memory Tool을 통해 저장
        # (실제 구현은 SDK의 memory tool API 사용)
        
        path = f"project-enhancement/cycles/{cycle_id}/context.json"
        
        # memory_tool.write(path, context)
        print(f"💾 저장: {path}")
    
    def save_findings(self, findings: List[Dict]):
        """발견사항 저장"""
        
        # 타입별로 분류
        by_type = {}
        for finding in findings:
            type_ = finding["type"]
            if type_ not in by_type:
                by_type[type_] = []
            by_type[type_].append(finding)
        
        # 각 타입별로 저장
        for type_, items in by_type.items():
            path = f"project-enhancement/findings/by-type/{type_}.json"
            # memory_tool.write(path, items)
    
    def load_cycle(self, cycle_id: int) -> Dict:
        """사이클 컨텍스트 로드"""
        
        path = f"project-enhancement/cycles/{cycle_id}/context.json"
        # context = memory_tool.read(path)
        
        return {}  # 실제 구현에서는 메모리에서 읽음
    
    def load_finding_history(self) -> List[Dict]:
        """모든 발견사항 히스토리 로드"""
        
        # path = "project-enhancement/findings/"
        # all_findings = memory_tool.read(path)
        
        return []
```

---

## 성능 최적화

### 1. 캐싱 전략

```python
class MemoryCache:
    def __init__(self):
        self._cache = {}
        self._ttl = {}  # timestamp
    
    def get(self, key: str) -> Optional[Dict]:
        """캐시에서 읽기"""
        
        # TTL 확인
        if key in self._ttl:
            import time
            if time.time() - self._ttl[key] > 300:  # 5분
                del self._cache[key]
                del self._ttl[key]
                return None
        
        return self._cache.get(key)
    
    def set(self, key: str, value: Dict):
        """캐시에 저장"""
        
        import time
        self._cache[key] = value
        self._ttl[key] = time.time()
```

### 2. 배치 쓰기

```python
class MemoryBatchWriter:
    def __init__(self, api_key: str):
        self.client = Anthropic(api_key=api_key)
        self.batch = {}
    
    def queue(self, path: str, data: Dict):
        """쓰기 요청을 큐에 추가"""
        self.batch[path] = data
    
    def flush(self):
        """모든 변경사항을 한 번에 저장"""
        
        for path, data in self.batch.items():
            # memory_tool.write(path, data)
            pass
        
        self.batch.clear()
        print(f"✅ 배치 저장 완료: {len(self.batch)}개 항목")
```

---

## 에러 처리 및 재시도

```python
import time
from typing import Optional

def save_with_retry(
    memory_tool,
    path: str,
    data: Dict,
    max_retries: int = 3
) -> bool:
    """재시도 로직을 포함한 저장"""
    
    for attempt in range(max_retries):
        try:
            # memory_tool.write(path, data)
            return True
        except Exception as e:
            if attempt < max_retries - 1:
                # Exponential backoff
                wait_time = 2 ** attempt
                print(f"⏳ {wait_time}초 후 재시도...")
                time.sleep(wait_time)
            else:
                print(f"❌ 저장 실패: {e}")
                return False
    
    return False
```

---

## 검증 및 마이그레이션

### 마이그레이션 예제

```python
def migrate_memory_schema(old_version: str, new_version: str):
    """스키마 버전 업그레이드"""
    
    print(f"🔄 스키마 마이그레이션: {old_version} → {new_version}")
    
    # 각 사이클 데이터 마이그레이션
    for cycle_id in range(100):  # 최대 100 사이클
        try:
            # old_cycle = memory_tool.read(f"project-enhancement/cycles/{cycle_id}/context.json")
            
            # 필드 추가/변경
            # old_cycle["schema_version"] = new_version
            # old_cycle["migrated_at"] = datetime.now().isoformat()
            
            # memory_tool.write(f"project-enhancement/cycles/{cycle_id}/context.json", old_cycle)
            
            print(f"✅ 사이클 {cycle_id} 마이그레이션 완료")
        except:
            # 존재하지 않으면 스킵
            break
```

---

## 체크리스트

- [ ] 경로 구조 정의
- [ ] JSON 스키마 검증
- [ ] CRUD 함수 구현
- [ ] 쿼리 함수 구현 (중복 확인, 통계 등)
- [ ] 캐싱 및 성능 최적화
- [ ] 에러 처리 및 재시도
- [ ] 마이그레이션 전략
- [ ] 단위 테스트 작성
- [ ] Memory Tool 통합 테스트

---

**마지막 업데이트**: 2026-06-12
**스키마 상태**: FINAL_DESIGN
