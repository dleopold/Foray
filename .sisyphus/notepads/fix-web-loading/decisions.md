# Decisions - Fix Web Loading Issue


## 2026-01-25T01:40:00Z - Dependency Versions

### Decision: Use drift 2.23.x with drift_flutter 0.2.x
**Rationale**: These versions are compatible and provide proper web support
- drift: ^2.23.0 (resolved to 2.23.1)
- drift_flutter: ^0.2.0 (resolved to 0.2.7)
- drift_dev: ^2.23.0 (resolved to 2.23.1)

### Decision: Use sqlite3 v2.9.4 artifacts
**Rationale**: drift currently depends on sqlite3 v2.x, not v3.x
- sqlite3.wasm from: https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.9.4/
- v3.x releases are incompatible

### Decision: Match drift_worker.js to drift version
**Rationale**: Worker must match package version for proper initialization
- Used drift-2.23.1 worker release
- Downloaded from: https://github.com/simolus3/drift/releases/download/drift-2.23.1/
