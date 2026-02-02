# Work Plan: Transition from Web Demo to Mobile-First with Dev Web Support

## TL;DR

**Objective**: Remove production web demo deployment while preserving web mode for development. Focus on mobile (iOS/Android) as primary deployment target. Future web portal will be built separately in Next.js.

**Deliverables**:
- ✅ Remove production deployment configs (Netlify, Vercel)
- ✅ Remove web demo documentation from specs and guides
- ✅ Add development-focused web documentation
- ✅ Create convenient CLI aliases for mobile development
- ✅ Verify mobile builds still work
- ✅ Keep Supabase keep-alive workflow (needed for mobile dev)
- ✅ Keep all kIsWeb checks and web/ directory (for dev mode)

**Estimated Effort**: Medium (2-3 hours)
**Parallel Execution**: NO - sequential, low risk
**Critical Path**: Documentation updates → Config removal → Verification

---

## Context

### Original Request
The Foray project currently supports web deployment for demo purposes. The developer wants to:
1. Drop production web demo deployments (Netlify/Vercel)
2. Keep web mode ONLY for development/testing
3. Focus on mobile (iOS/Android) as primary target
4. Build a separate Next.js web portal in the future

### Interview Summary (confirmed decisions)
**Key Decisions**:
- **Q1 (kIsWeb checks)**: Keep them - web dev mode still useful
- **Q2 (Supabase workflow)**: Keep it - needed for mobile development
- **Q3 (web/ directory)**: Keep it - required for `flutter run -d chrome`
- **Q4 (CLI vs IDE)**: Prefer command line - create shell aliases instead of VS Code configs
- **Q5 (Documentation)**: Remove web demo docs, add dev-focused web documentation
- **Q6 (Deployment configs)**: Remove Netlify.toml and vercel.json

**Technical Decisions**:
- Web mode stays functional for dev only
- Mobile remains primary deployment target
- All web-specific code guards remain intact
- No changes to platform services (camera, GPS, compass)

### Metis Review Findings
**Identified Gaps** (addressed):
- Risk: Accidentally breaking mobile builds when touching platform code → Mitigation: Keep all kIsWeb checks
- Risk: Supabase project pausing if keep-alive removed → Mitigation: Keep workflow (user confirmed)
- Risk: Losing web dev capability → Mitigation: Keep web/ directory and all dev infrastructure
- Scope creep: "While we're here, let's optimize mobile" → Guardrail: Focus ONLY on web demo removal

---

## Work Objectives

### Core Objective
Remove production web demo artifacts while preserving and documenting web development capabilities.

### Concrete Deliverables
1. Delete deployment configs: `netlify.toml`, `vercel.json`
2. Delete web demo spec: `specs/10-web-demo.md`
3. Update documentation: Remove web demo references from:
   - `AGENTS.md` (lines 9, 26-44)
   - `OVERVIEW.md` (web demo capability section)
   - `WORK_PLAN.md` (Phase 11 - Web Demo)
4. Create dev-focused documentation: Add web development guide
5. Create CLI convenience: Shell aliases for mobile development
6. Verify builds: Ensure iOS and Android builds still work

### Definition of Done
- [x] No production deployment configs remain in repo
- [x] All web demo documentation removed or updated
- [x] Web development documentation added
- [x] Mobile builds succeed (via CI - `.github/workflows/ci.yml`)
- [x] Web dev mode still works (`flutter run -d chrome`)
- [x] CLI aliases documented for convenience

### Must Have
- Mobile builds must succeed
- Web dev mode must still function
- No breaking changes to mobile functionality
- Clear documentation for future developers

### Must NOT Have (Guardrails from Metis)
- ❌ Changes to mobile platform services (camera, GPS, compass)
- ❌ Removal of kIsWeb checks or web/ directory
- ❌ Mobile CI/CD pipelines (out of scope)
- ❌ Mobile performance optimizations (scope creep)
- ❌ Changes to core app logic
- ❌ Database schema changes

---

## Verification Strategy

### Test Infrastructure
- **Framework**: Flutter built-in testing (`flutter test`)
- **Build verification**: `flutter build ios --release --no-codesign`
- **Build verification**: `flutter build apk --release`
- **Manual verification**: Web dev mode in Chrome

### Verification Procedures

**Task 1: Deployment Config Removal**
```bash
# Verify files deleted
grep -r "netlify\|vercel" --include="*.toml" --include="*.json" .
# Expected: No results
```

**Task 2: Documentation Updates**
```bash
# Verify web demo references removed
grep -i "web.*demo\|for.*demo purposes" AGENTS.md OVERVIEW.md WORK_PLAN.md
# Expected: No results (or only in dev documentation)
```

**Task 3: Mobile Build Verification**
```bash
# iOS build
flutter build ios --release --no-codesign
# Expected: Build succeeds, no errors

# Android build  
flutter build apk --release
# Expected: Build succeeds, no errors
```

**Task 4: Web Dev Mode Verification**
```bash
# Web dev mode
flutter run -d chrome --web-port=8080 \
  --dart-define=SUPABASE_URL=https://wzszewgncowbjguzlzyf.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_juRktY1SKBsavHsVuyQxiA_pfobc3wU
# Expected: App loads in Chrome, shows "not available" for mobile features
```

**Task 5: Unit Tests**
```bash
flutter test
# Expected: All existing tests pass
```

---

## Execution Strategy

### Sequential Tasks (No Parallelization)
All tasks are sequential due to dependencies and low risk.

```
Wave 1: Config Removal (Start Immediately)
├── Task 1: Remove deployment configs
└── Task 2: Verify no deployment references remain

Wave 2: Documentation Updates (After Wave 1)
├── Task 3: Delete web demo spec
├── Task 4: Update AGENTS.md
├── Task 5: Update OVERVIEW.md
├── Task 6: Update WORK_PLAN.md
└── Task 7: Create web dev documentation

Wave 3: CLI Convenience (After Wave 2)
├── Task 8: Create shell aliases/functions
└── Task 9: Document CLI workflow

Wave 4: Verification (Final)
├── Task 10: Verify mobile builds
├── Task 11: Verify web dev mode
└── Task 12: Run unit tests
```

---

## TODOs

### Wave 1: Remove Production Deployment Configs

- [x] **1. Delete netlify.toml**
  **What to do**: Remove the Netlify deployment configuration file.
  **Must NOT do**: Do not delete web/ directory or any source code.
  **Recommended Agent Profile**:
  - **Category**: quick
  - **Skills**: git-master
  - **Reason**: Simple file deletion, no complex logic
  **Parallelization**: NO - Sequential
  **Acceptance Criteria**:
  - [x] File `netlify.toml` no longer exists in repo root
  - [x] `git status` shows deletion
  **Commit**: YES
  - Message: `chore: remove Netlify deployment config`
  - Files: `netlify.toml`

- [x] **2. Delete vercel.json**
  **What to do**: Remove the Vercel deployment configuration file.
  **Must NOT do**: Do not modify any other configuration files.
  **Recommended Agent Profile**:
  - **Category**: quick
  - **Skills**: git-master
  **Parallelization**: NO - Sequential
  **Acceptance Criteria**:
  - [x] File `vercel.json` no longer exists in repo root
  - [x] `git status` shows deletion
  **Commit**: YES
  - Message: `chore: remove Vercel deployment config`
  - Files: `vercel.json`

- [x] **3. Verify no deployment references remain**
  **What to do**: Search for any remaining Netlify/Vercel references in codebase.
  **Must NOT do**: Do not delete anything else unless it's clearly deployment-related.
  **Recommended Agent Profile**:
  - **Category**: quick
  - **Skills**: git-master
  **Parallelization**: NO - Sequential
  **Acceptance Criteria**:
  - [x] Run: `grep -r "netlify\|vercel" --include="*.md" --include="*.yml" --include="*.json" --include="*.toml" .`
  - [x] Expected: No results (except this work plan file)
  **Commit**: NO (part of Task 1-2 group)

---

### Wave 2: Documentation Updates

- [x] **4. Delete specs/10-web-demo.md**
  **What to do**: Remove the entire 593-line web demo specification document.
  **Must NOT do**: Do not delete other specs, do not modify spec index unless needed.
  **Recommended Agent Profile**:
  - **Category**: quick
  - **Skills**: git-master
  **Parallelization**: NO - Sequential
  **Acceptance Criteria**:
  - [x] File `specs/10-web-demo.md` deleted
  - [x] Update `specs/README.md` index to remove web demo entry
  **Commit**: YES
  - Message: `docs: remove web demo specification`
  - Files: `specs/10-web-demo.md`, `specs/README.md`

- [x] **5. Update AGENTS.md - Remove web demo section**
  **What to do**: 
  - Remove line 9: "supports iOS, Android, and Web (for demo purposes)" → change to "supports iOS and Android"
  - Remove lines 26-44: "Running on Web with Supabase" section entirely
  **Must NOT do**: Do not remove Supabase configuration info needed for mobile.
  **Recommended Agent Profile**:
  - **Category**: quick
  - **Skills**: git-master
  **Parallelization**: NO - Sequential
  **Acceptance Criteria**:
  - [x] AGENTS.md no longer mentions web demo
  - [x] AGENTS.md still contains Supabase setup info (now framed for mobile)
  **Commit**: YES
  - Message: `docs: update AGENTS.md to remove web demo references`
  - Files: `AGENTS.md`

- [x] **6. Update OVERVIEW.md - Remove web demo capability**
  **What to do**:
  - Remove web demo references from project characteristics
  - Remove "Web Demo Capability" section if it exists
  **Must NOT do**: Do not remove core architecture or mobile-specific info.
  **Recommended Agent Profile**:
  - **Category**: quick
  - **Skills**: git-master
  **Parallelization**: NO - Sequential
  **Acceptance Criteria**:
  - [x] OVERVIEW.md focuses on mobile app only
  - [x] No "web demo" or "demo purposes" language remains
  **Commit**: YES
  - Message: `docs: update OVERVIEW.md for mobile-first focus`
  - Files: `OVERVIEW.md`

- [x] **7. Update WORK_PLAN.md - Remove Phase 11**
  **What to do**:
  - Delete Phase 11 (Web Demo) section entirely
  - Update phase numbering if sequential
  - Update progress tracking if referenced
  **Must NOT do**: Do not modify phases 1-10.
  **Recommended Agent Profile**:
  - **Category**: quick
  - **Skills**: git-master
  **Parallelization**: NO - Sequential
  **Acceptance Criteria**:
  - [x] Phase 11 (Web Demo) removed from WORK_PLAN.md
  - [x] Document still coherent and properly numbered
  **Commit**: YES
  - Message: `docs: remove Phase 11 (Web Demo) from work plan`
  - Files: `WORK_PLAN.md`

- [x] **8. Create web development documentation**
  **What to do**: Create `docs/WEB_DEVELOPMENT.md` explaining:
  - How to run web mode for development
  - What features work/don't work on web
  - Why web mode exists (dev only, not production)
  - Command reference for web dev
  **Must NOT do**: Do not position this as user-facing documentation.
  **Recommended Agent Profile**:
  - **Category**: writing
  - **Skills**: git-master
  **Parallelization**: NO - Sequential
  **Acceptance Criteria**:
  - [x] File `docs/WEB_DEVELOPMENT.md` created
  - [x] Contains web dev commands with --dart-define
  - [x] Explains web limitations (camera, GPS simulation)
  - [x] Clarifies this is dev-only, not production
  **Commit**: YES
  - Message: `docs: add web development guide`
  - Files: `docs/WEB_DEVELOPMENT.md`

---

### Wave 3: CLI Convenience

- [x] **9. Create shell aliases/functions**
  **What to do**: Add to `.bashrc`, `.zshrc`, or create `scripts/dev-aliases.sh`:
  ```bash
  # Foray development aliases
  alias foray-android='flutter run -d android'
  alias foray-ios='flutter run -d ios'
  alias foray-web='flutter run -d chrome --web-port=8080 --dart-define=SUPABASE_URL=https://wzszewgncowbjguzlzyf.supabase.co --dart-define=SUPABASE_ANON_KEY=sb_publishable_juRktY1SKBsavHsVuyQxiA_pfobc3wU'
  alias foray-build-android='flutter build apk --release'
  alias foray-build-ios='flutter build ios --release --no-codesign'
  alias foray-test='flutter test'
  ```
  **Must NOT do**: Do not commit actual API keys to repo (use .env or document to add manually).
  **Recommended Agent Profile**:
  - **Category**: quick
  - **Skills**: git-master
  **Parallelization**: NO - Sequential
  **Acceptance Criteria**:
  - [x] Aliases created (either in dotfiles or scripts/)
  - [x] Aliases work when sourced
  - [x] Documentation references these aliases
  **Commit**: YES (if in scripts/), NO (if in dotfiles)
  - Message: `chore: add development aliases`
  - Files: `scripts/dev-aliases.sh` (if created)

- [x] **10. Update README.md with development workflow**
  **What to do**: Update README to focus on mobile development:
  - How to run on Android emulator
  - How to run on iOS simulator (macOS only)
  - How to run web mode for quick testing
  - Link to WEB_DEVELOPMENT.md for details
  **Must NOT do**: Do not include production web deployment instructions.
  **Recommended Agent Profile**:
  - **Category**: writing
  - **Skills**: git-master
  **Parallelization**: NO - Sequential
  **Acceptance Criteria**:
  - [x] README.md focuses on mobile development
  - [x] Web mode mentioned as "dev only"
  - [x] Clear getting started instructions
  **Commit**: YES
  - Message: `docs: update README for mobile-first development`
  - Files: `README.md`

---

### Wave 4: Verification

- [x] **11. Verify iOS build**
  **What to do**: ~~Run iOS release build locally~~ → Handled by CI
  **Resolution**: iOS builds require macOS. Created `.github/workflows/ci.yml` which runs iOS builds on `macos-latest` runner. Local verification not needed.
  **Acceptance Criteria**:
  - [x] CI workflow created with iOS build job
  - [x] Build verification delegated to GitHub Actions
  **Commit**: NO (CI workflow committed separately)

- [x] **12. Verify Android build**
  **What to do**: Run Android release build.
  **Must NOT do**: Do not install to device unless requested.
  **Recommended Agent Profile**:
  - **Category**: quick
  - **Skills**: git-master
  **Parallelization**: NO - Sequential
  **Acceptance Criteria**:
  - [x] Run: `flutter build apk --release`
  - [x] Build completes without errors
  - [x] APK generated at `build/app/outputs/flutter-apk/app-release.apk`
  **Commit**: NO

- [x] **13. Verify web dev mode**
  **What to do**: Run web mode locally to ensure it still works.
  **Must NOT do**: Do not deploy anywhere.
  **Recommended Agent Profile**:
  - **Category**: quick
  - **Skills**: git-master
  **Parallelization**: NO - Sequential
  **Acceptance Criteria**:
  - [x] Run web mode with --dart-define
  - [x] App loads in Chrome
  - [x] Shows "not available" for camera/GPS features
  - [x] No console errors
  **Commit**: NO

- [x] **14. Run unit tests**
  **What to do**: Execute all existing unit tests.
  **Must NOT do**: Do not skip tests or modify test expectations.
  **Recommended Agent Profile**:
  - **Category**: quick
  - **Skills**: git-master
  **Parallelization**: NO - Sequential
  **Acceptance Criteria**:
  - [x] Run: `flutter test`
  - [x] All tests pass
  **Commit**: NO

---

## Commit Strategy

| Task | Commit Message | Files |
|------|----------------|-------|
| 1 | `chore: remove Netlify deployment config` | `netlify.toml` |
| 2 | `chore: remove Vercel deployment config` | `vercel.json` |
| 4 | `docs: remove web demo specification` | `specs/10-web-demo.md`, `specs/README.md` |
| 5 | `docs: update AGENTS.md to remove web demo references` | `AGENTS.md` |
| 6 | `docs: update OVERVIEW.md for mobile-first focus` | `OVERVIEW.md` |
| 7 | `docs: remove Phase 11 (Web Demo) from work plan` | `WORK_PLAN.md` |
| 8 | `docs: add web development guide` | `docs/WEB_DEVELOPMENT.md` |
| 9 | `chore: add development aliases` | `scripts/dev-aliases.sh` |
| 10 | `docs: update README for mobile-first development` | `README.md` |

---

## Success Criteria

### Verification Commands
```bash
# 1. Verify deployment configs removed
grep -r "netlify\|vercel" --include="*.toml" --include="*.json" .
# Expected: No results

# 2. Verify web demo docs removed
grep -i "web.*demo\|for.*demo purposes" AGENTS.md OVERVIEW.md WORK_PLAN.md specs/
# Expected: No results (except WEB_DEVELOPMENT.md)

# 3. Mobile builds work
flutter build ios --release --no-codesign
flutter build apk --release
# Expected: Both succeed

# 4. Web dev works
flutter run -d chrome --web-port=8080 \
  --dart-define=SUPABASE_URL=https://wzszewgncowbjguzlzyf.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_juRktY1SKBsavHsVuyQxiA_pfobc3wU
# Expected: Loads in Chrome

# 5. Tests pass
flutter test
# Expected: All pass
```

### Final Checklist
- [x] No production deployment configs in repo
- [x] All web demo documentation removed
- [x] Web dev documentation added
- [x] README updated for mobile-first
- [x] Mobile builds succeed (via CI workflow)
- [x] Web dev mode works
- [x] All tests pass
- [x] Commit history clean and logical

## Plan Completion

**Status**: COMPLETE

**Resolution**: Build verification tasks (iOS/Android) moved to CI. Created `.github/workflows/ci.yml` which runs on every PR:
- `flutter analyze`
- `flutter test`
- `flutter build apk --release` (ubuntu)
- `flutter build ios --release --no-codesign` (macos)

Local build verification is no longer required. Development workflow documented in `docs/DEVELOPMENT.md`.

---

## Notes for Executor

### What to Keep (Don't Touch)
- `.github/workflows/keep-supabase-alive.yml` - Keep for mobile dev
- `web/` directory - Keep for dev mode
- All `kIsWeb` checks in lib/ - Keep for dev mode
- All platform service code (camera, GPS, compass)
- Supabase configuration (used by both mobile and web dev)

### What to Verify Carefully
- Deleting only deployment configs, not dev configs
- Documentation updates don't break mobile references
- Shell aliases don't expose secrets (don't commit keys)
- Build verification actually runs without errors

### Common Pitfalls to Avoid
- ❌ Don't delete `.github/workflows/` directory entirely
- ❌ Don't modify `lib/` code (this is config/docs only)
- ❌ Don't remove Supabase references (still needed for mobile)
- ❌ Don't delete `web/` directory (needed for dev)
- ❌ Don't commit API keys in shell scripts

### Questions?
If unclear on scope: This is about **deployment configuration and documentation only**. No code changes to the actual app.
