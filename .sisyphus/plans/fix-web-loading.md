# Fix Web App Loading Issue

## Context

### Original Request
The Flutter web app is stuck at the initial loading spinner showing "Loading mycological field collection..."

### Investigation Summary
**Root Cause**: Drift database initialization fails on web due to version mismatches and invalid worker files.

**Key Findings**:
1. `drift_flutter: ^0.1.0` is incompatible with `drift: 2.23.1` (resolved in pubspec.lock)
2. The `sqlite3.wasm` and `drift_worker.js` files in `web/` were downloaded from wrong sources (HTML error pages initially)
3. The drift_worker.js version must match the drift package version

---

## Work Objectives

### Core Objective
Fix the Drift database web initialization so the Flutter web app loads past the spinner.

### Concrete Deliverables
- Updated `pubspec.yaml` with compatible drift/drift_flutter versions
- Correct `web/sqlite3.wasm` file (WebAssembly binary, ~730KB)
- Correct `web/drift_worker.js` file (JavaScript, ~350KB)
- Working Flutter web app that loads the home screen

### Definition of Done
- [x] `flutter run -d chrome` launches app past the loading spinner
- [x] No JavaScript errors related to drift/database in console
- [x] App shows the Foray List screen (home)

### Must NOT Have
- Do not modify database schema or migrations
- Do not change app functionality
- Do not update unrelated dependencies

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: NO (manual verification)
- **User wants tests**: Manual-only
- **QA approach**: Manual verification via browser

### Manual QA Procedure
1. Run `flutter run -d chrome --web-port=8080`
2. Open browser to http://localhost:8080
3. Verify app loads past spinner to home screen
4. Check browser console for errors (F12 > Console)

---

## TODOs

- [x] 1. Update drift dependencies in pubspec.yaml

  **What to do**:
  - Open `pubspec.yaml`
  - Change `drift: ^2.14.0` to `drift: ^2.23.0`
  - Change `drift_flutter: ^0.1.0` to `drift_flutter: ^0.2.0`
  - Run `flutter pub get` to update dependencies

  **Must NOT do**:
  - Do not change any other dependencies
  - Do not modify pubspec.lock directly

  **Parallelizable**: NO (must complete before task 2)

  **References**:
  - `pubspec.yaml` lines 21-23 - Current drift dependencies
  - https://pub.dev/packages/drift_flutter - drift_flutter changelog

  **Acceptance Criteria**:
  - [x] `flutter pub get` completes successfully
  - [x] `pubspec.lock` shows `drift: 2.23.x` and `drift_flutter: 0.2.x`

  **Commit**: YES
  - Message: `fix(deps): update drift and drift_flutter for web compatibility`
  - Files: `pubspec.yaml`, `pubspec.lock`

---

- [x] 2. Download correct sqlite3.wasm file

  **What to do**:
  - Delete existing `web/sqlite3.wasm` (it may be invalid)
  - Download from: `https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.9.4/sqlite3.wasm`
  - Verify file is WebAssembly binary (~730KB)

  **Command**:
  ```bash
  curl -L -o web/sqlite3.wasm \
    "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.9.4/sqlite3.wasm"
  file web/sqlite3.wasm  # Should show: WebAssembly (wasm) binary module
  ls -la web/sqlite3.wasm  # Should be ~730KB
  ```

  **Must NOT do**:
  - Do not download from sqlite3 v3.x releases (incompatible with drift)

  **Parallelizable**: YES (with task 3)

  **References**:
  - `lib/database/database.dart:149` - sqlite3Wasm URI configuration
  - https://github.com/simolus3/sqlite3.dart/releases - sqlite3.dart releases

  **Acceptance Criteria**:
  - [x] `file web/sqlite3.wasm` shows "WebAssembly (wasm) binary module"
  - [x] File size is approximately 730KB

  **Commit**: NO (groups with task 4)

---

- [x] 3. Download correct drift_worker.js file

  **What to do**:
  - Delete existing `web/drift_worker.js` (it may be wrong version)
  - Download from drift release matching pubspec.lock version
  - After task 1, check `pubspec.lock` for exact drift version
  - Download matching worker from: `https://github.com/simolus3/drift/releases/download/drift-{VERSION}/drift_worker.js`

  **Command** (after task 1 completes):
  ```bash
  # Check drift version in pubspec.lock
  grep -A5 "^  drift:" pubspec.lock | grep version
  
  # Download matching worker (example for 2.23.1)
  curl -L -o web/drift_worker.js \
    "https://github.com/simolus3/drift/releases/download/drift-2.23.1/drift_worker.js"
  
  file web/drift_worker.js  # Should show: JavaScript source
  ls -la web/drift_worker.js  # Should be ~350KB
  ```

  **Must NOT do**:
  - Do not use drift_worker.js from a different major version than drift package

  **Parallelizable**: YES (with task 2, but depends on task 1 for version)

  **References**:
  - `lib/database/database.dart:150` - driftWorker URI configuration
  - https://github.com/simolus3/drift/releases - drift releases

  **Acceptance Criteria**:
  - [x] `file web/drift_worker.js` shows "JavaScript source"
  - [x] File size is approximately 350KB
  - [x] Version matches drift package version in pubspec.lock

  **Commit**: NO (groups with task 4)

---

- [x] 4. Commit web worker files

  **What to do**:
  - Stage `web/sqlite3.wasm` and `web/drift_worker.js`
  - Create commit with both files

  **Parallelizable**: NO (depends on tasks 2 and 3)

  **Acceptance Criteria**:
  - [x] Both files are committed

  **Commit**: YES
  - Message: `fix(web): add correct drift worker files for web database support`
  - Files: `web/sqlite3.wasm`, `web/drift_worker.js`

---

- [x] 5. Verify web app loads correctly

  **What to do**:
  - Kill any existing Flutter processes
  - Clean Flutter build cache
  - Run `flutter run -d chrome --web-port=8080`
  - Open browser to http://localhost:8080
  - Verify app loads past spinner

  **Commands**:
  ```bash
  pkill -9 -f "dart" || true
  flutter clean
  flutter pub get
  flutter run -d chrome --web-port=8080
  ```

  **Parallelizable**: NO (final verification)

  **Acceptance Criteria**:
  - [x] App loads past "Loading mycological field collection..." spinner
  - [x] Foray List screen (home) is displayed
  - [x] No JavaScript errors in browser console related to drift/database
  - [x] Console may show plugin warnings (FlutterSecureStorageWeb, ConnectivityPlus) - these are acceptable

  **Commit**: NO

---

## Commit Strategy

| After Task | Message | Files |
|------------|---------|-------|
| 1 | `fix(deps): update drift and drift_flutter for web compatibility` | pubspec.yaml, pubspec.lock |
| 4 | `fix(web): add correct drift worker files for web database support` | web/sqlite3.wasm, web/drift_worker.js |

---

## Success Criteria

### Verification Commands
```bash
# After all tasks complete:
flutter run -d chrome --web-port=8080

# Expected: App loads to home screen within 30 seconds
# Browser console should NOT show: "Cannot read properties of undefined"
```

### Final Checklist
- [x] `pubspec.yaml` has `drift: ^2.23.0` and `drift_flutter: ^0.2.0`
- [x] `web/sqlite3.wasm` is valid WebAssembly (~730KB)
- [x] `web/drift_worker.js` is valid JavaScript (~350KB, matching drift version)
- [x] App loads past spinner to home screen
- [x] No critical JavaScript errors in console
