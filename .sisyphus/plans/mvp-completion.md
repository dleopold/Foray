# MVP Completion: Activate Sync, Wire Features, Add Real-Time

## TL;DR

> **Quick Summary**: Activate the dormant sync infrastructure (5 commented-out enqueue calls + processor start), wire 6 stubbed features (QR scanning, observation editing, gallery, participant management, native share), add Supabase Realtime subscriptions for live collaboration, and fix hardcoded state (lock, useMetric). TDD for all new work.
> 
> **Deliverables**:
> - Working end-to-end sync (observations, forays, IDs, comments, votes)
> - QR/barcode scanning in 3 locations (join foray, specimen lookup, specimen ID)
> - Full observation editing flow
> - Full-screen photo gallery viewer
> - Participant removal and leave foray actions
> - Native share sheet for foray sharing
> - Supabase Realtime subscriptions for live collaboration data changes
> - Lock state enforcement on observation detail
> - Compass reads user's metric/imperial preference
> - Foray card shows observation count
> 
> **Estimated Effort**: Large
> **Parallel Execution**: YES - 4 waves
> **Critical Path**: Task 1 (Supabase verify) → Task 2 (Sync activate) → Task 3 (Vote sync) → Task 10 (Real-time)

---

## Context

### Original Request
User wants to ship a working MVP. Comprehensive audit revealed sync infrastructure is 100% built but dead (commented out), 26+ TODOs for stubbed features, and several hardcoded values. Supabase project exists with .env configured and 5 migration files present.

### Interview Summary
**Key Discussions**:
- **Goal**: Ship working MVP — focus on activating sync, wiring stubs, real-time data changes
- **Test strategy**: TDD for new work only (existing untested code stays as-is)
- **Supabase**: Project configured, migrations may or may not be applied to remote
- **Real-time scope**: Data changes only (observations, IDs, votes, comments), no presence

**Research Findings**:
- 5 `enqueue()` calls are commented out across: `create_foray_screen.dart`, `join_foray_screen.dart`, `observation_entry_screen.dart`, `add_identification_sheet.dart`, `comments_list.dart`
- `SyncQueueProcessor.start()` is never called anywhere — processor exists as dead Riverpod provider
- `_loadExistingObservation()` in `observation_entry_screen.dart:120` is completely empty
- Lock state hardcoded at `observation_detail_screen.dart:156-165` (isLocked=false, canDelete=true, isOrganizer=false)
- Vote syncing (`pushVote`/`pullVote`) is missing from `SyncService` and processor switch
- `share_plus` is NOT in `pubspec.yaml` — needs to be added
- `mobile_scanner` IS in pubspec, `qr_flutter` IS in pubspec (but QR generation is out of scope)
- `mocktail` dependency present but unused — available for TDD
- Supabase CLI has been used (`.temp/` directory exists with project-ref)
- `useMetricProvider` already exists at `settings_controller.dart` — just needs to be wired to compass

### Metis Review
**Identified Gaps** (addressed):
- **Supabase schema status unknown**: Added Task 1 to verify/apply migrations before any sync work
- **Sync processor needs auth guard**: Task 2 includes gating `start()` behind authenticated state
- **No vote syncing**: Added Task 3 specifically for vote push/pull
- **Edit route has `forayId: ''`**: Task 5 addresses by loading observation data first
- **No sync for updates/deletes**: Task 2 adds update enqueuing for edits; delete sync excluded from MVP
- **Real-time subscription disposal**: Task 10 mandates Riverpod provider pattern with `ref.onDispose()`
- **`share_plus` not in pubspec**: Task 8 includes adding the dependency

---

## Work Objectives

### Core Objective
Transform Foray from a locally-functional prototype into a working MVP with end-to-end cloud sync, live collaboration updates, and all core user flows operational.

### Concrete Deliverables
- Sync queue actively processing: observations, forays, IDs, comments, votes push to Supabase
- Pull sync retrieves remote data on reconnect and periodic intervals
- Real-time: Supabase Realtime pushes new observations/IDs/votes/comments to all foray participants
- QR scanner functional in: join foray, specimen lookup, specimen ID entry
- Observation editing: load existing data, modify fields, save with sync enqueue
- Full-screen swipeable photo gallery on observation detail
- Participant removal (organizer action) and leave foray (participant action) both functional
- Native share sheet for foray join links
- Lock state properly enforced on observation detail and collaboration widgets
- Compass reads user's unit preference from settings

### Definition of Done
- [ ] `flutter analyze` passes with zero errors
- [ ] All new code has corresponding test files that pass
- [ ] Creating an observation when authenticated queues it for sync
- [ ] Sync processor runs automatically for authenticated users
- [ ] Editing an observation updates it locally and queues sync update
- [ ] QR scanner opens camera on mobile platforms
- [ ] Lock state prevents adding IDs/comments when foray is locked
- [ ] Real-time subscription delivers remote changes to local UI

### Must Have
- Sync queue activation (uncomment + processor start with auth guard)
- Vote sync implementation (pushVote/pullVote)
- Observation editing (load + save + sync)
- Lock state enforcement
- QR scanning (3 locations)
- Real-time data subscriptions

### Must NOT Have (Guardrails)
- ❌ QR code generation (out of scope — leave placeholder even though `qr_flutter` is in pubspec)
- ❌ PDF export (out of scope)
- ❌ Deep linking (out of scope)
- ❌ Conflict resolution UI (last-write-wins is sufficient for MVP)
- ❌ Delete sync (local delete only for MVP — remote copies persist)
- ❌ Species database integration (keep mock data)
- ❌ Presence/typing indicators (out of scope)
- ❌ Error reporting infrastructure (Sentry/Crashlytics — out of scope)
- ❌ Map date/collector filters on foray map (out of scope)
- ❌ Cluster animations, map compass indicator, mini-map (out of scope)
- ❌ Privacy policy/terms of service links (out of scope)
- ❌ Tests for existing untested code (TDD for new work only)
- ❌ Observation delete sync (deletes stay local-only for MVP)
- ❌ Photo add/remove during editing (text fields only for MVP edit)

---

## Verification Strategy

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
>
> ALL tasks in this plan MUST be verifiable WITHOUT any human action.

### Test Decision
- **Infrastructure exists**: YES (flutter_test, mocktail in pubspec)
- **Automated tests**: TDD for new work
- **Framework**: flutter_test + mocktail

### Agent-Executed QA Scenarios (MANDATORY — ALL tasks)

**Verification Tool by Deliverable Type:**

| Type | Tool | How Agent Verifies |
|------|------|-------------------|
| Dart logic/services | Bash (flutter test) | Run targeted test files, assert pass |
| Static analysis | Bash (flutter analyze) | Zero errors/warnings on changed files |
| Database operations | flutter_test with in-memory Drift | Test DAO operations with mock DB |
| UI widgets | flutter_test (widget tests) | Pump widget, find elements, tap, assert |
| Build verification | Bash (flutter build) | Verify compilation succeeds |

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately):
├── Task 1: Verify/apply Supabase migrations
├── Task 4: Add share_plus dependency + wire native share
├── Task 6: Full-screen photo gallery viewer
├── Task 7: Participant removal + Leave foray
├── Task 9: Fix hardcoded values (useMetric, observation count)
└── Task 11: Update PROGRESS.md to reflect actual state

Wave 2 (After Task 1):
├── Task 2: Activate sync queue (uncomment + start processor)
├── Task 5: Observation editing flow
└── Task 8: QR/Barcode scanning (3 locations)

Wave 3 (After Task 2):
├── Task 3: Vote sync implementation
└── Task 10: Lock state enforcement

Wave 4 (After Tasks 2, 3):
└── Task 12: Supabase Realtime subscriptions

Critical Path: Task 1 → Task 2 → Task 3 → Task 12
Parallel Speedup: ~45% faster than sequential
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 1 | None | 2, 12 | 4, 5, 6, 7, 8, 9, 11 |
| 2 | 1 | 3, 10, 12 | 5, 8 |
| 3 | 2 | 12 | 10 |
| 4 | None | None | 1, 5, 6, 7, 8, 9, 11 |
| 5 | None | None | 1, 4, 6, 7, 8, 9, 11 |
| 6 | None | None | 1, 4, 5, 7, 8, 9, 11 |
| 7 | None | None | 1, 4, 5, 6, 8, 9, 11 |
| 8 | None | None | 1, 4, 5, 6, 7, 9, 11 |
| 9 | None | None | 1, 4, 5, 6, 7, 8, 11 |
| 10 | 2 | None | 3 |
| 11 | None | None | All |
| 12 | 2, 3 | None | None (final) |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Agents |
|------|-------|-------------------|
| 1 | 1, 4, 6, 7, 9, 11 | Parallel: 1=quick, 4=quick, 6=unspecified-low, 7=quick, 9=quick, 11=writing |
| 2 | 2, 5, 8 | Parallel: 2=unspecified-high, 5=unspecified-high, 8=unspecified-high |
| 3 | 3, 10 | Parallel: 3=unspecified-high, 10=quick |
| 4 | 12 | Sequential: 12=deep |

---

## TODOs

- [ ] 1. Verify and Apply Supabase Migrations

  **What to do**:
  - Check if the Supabase project has the expected tables by running: `supabase db push` or `supabase migration list`
  - If `.temp/project-ref` exists, the CLI is already linked. Verify with `supabase projects list`
  - Apply all 5 migration files if not already applied:
    - `20260122000001_create_tables.sql` — Main schema (users, forays, foray_participants, observations, photos, identifications, identification_votes, comments)
    - `20260122000002_enable_rls.sql` — Row Level Security policies
    - `20260122000003_create_indexes.sql` — Performance indexes
    - `20260122000004_create_functions.sql` — Database functions
    - `20260122000005_create_storage.sql` — Storage buckets for photos
  - Verify tables exist after migration by querying: `supabase db query "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';"`
  - Verify RLS is enabled on all tables
  - Verify storage bucket `observations` exists

  **Must NOT do**:
  - Do NOT modify any migration files
  - Do NOT create new tables beyond what's in the migrations
  - Do NOT disable RLS

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Verification/setup task — running CLI commands against existing infrastructure
  - **Skills**: [`git-master`]
    - `git-master`: May need to check if supabase CLI is available, run shell commands
  - **Skills Evaluated but Omitted**:
    - `playwright`: No browser interaction needed
    - `frontend-ui-ux`: No UI work

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 4, 6, 7, 9, 11)
  - **Blocks**: Tasks 2, 12
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `supabase/config.toml` — Supabase CLI configuration with project settings
  - `supabase/.temp/project-ref` — Contains linked project reference ID

  **Documentation References**:
  - `supabase/migrations/20260122000001_create_tables.sql` — Full schema definition
  - `supabase/migrations/20260122000002_enable_rls.sql` — RLS policies
  - `supabase/migrations/20260122000005_create_storage.sql` — Storage bucket config

  **Acceptance Criteria**:

  - [ ] `supabase migration list` shows all 5 migrations as applied (or `supabase db push` succeeds)
  - [ ] Query `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';` returns: users, forays, foray_participants, observations, photos, identifications, identification_votes, comments, sync_queue (or equivalent)
  - [ ] `SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';` shows `rowsecurity=true` for all tables
  - [ ] Storage bucket exists: `supabase storage ls` shows `observations` bucket

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Verify Supabase migrations are applied
    Tool: Bash (supabase CLI)
    Preconditions: supabase CLI installed, project linked via .temp/project-ref
    Steps:
      1. Run: supabase migration list
      2. Assert: All 5 migrations show as "applied" or "remote"
      3. If not applied, run: supabase db push
      4. Re-verify with: supabase migration list
    Expected Result: All 5 migrations applied
    Evidence: Terminal output captured

  Scenario: Verify storage bucket exists
    Tool: Bash (supabase CLI)
    Preconditions: Migrations applied
    Steps:
      1. Run: supabase storage ls
      2. Assert: "observations" bucket listed
    Expected Result: Storage bucket present
    Evidence: Terminal output captured
  ```

  **Commit**: YES
  - Message: `chore(supabase): verify and apply database migrations`
  - Files: Any config changes if needed
  - Pre-commit: `supabase migration list`

---

- [ ] 2. Activate Sync Queue and Start Processor

  **What to do**:
  - **Uncomment all 5 `enqueue()` calls** in their respective files. For each, add an auth guard using `FeatureGate.canSync`:
    - `lib/features/forays/presentation/screens/create_foray_screen.dart:201` — Enqueue foray creation
    - `lib/features/forays/presentation/screens/join_foray_screen.dart:247` — Enqueue participant join
    - `lib/features/observations/presentation/screens/observation_entry_screen.dart:618` — Enqueue observation creation
    - `lib/features/collaboration/presentation/widgets/add_identification_sheet.dart:150` — Enqueue identification
    - `lib/features/collaboration/presentation/widgets/comments_list.dart:148` — Enqueue comment
  - **Start `SyncQueueProcessor`** — Add initialization in `lib/app.dart` or `lib/main.dart`:
    - Watch `authControllerProvider` state
    - When state transitions to `authenticated`, call `ref.read(syncQueueProcessorProvider).start()`
    - When state transitions to `anonymous` or `unauthenticated`, call `processor.stop()`
    - This ensures sync only runs for authenticated users
  - **Add `SyncOperation.update` enqueue** where observations are modified (this wires into Task 5)
  - **Write tests** (TDD):
    - Test that `enqueue()` is called after saving an observation (mock DAO)
    - Test that processor `start()` is called when auth state becomes authenticated
    - Test that processor `stop()` is called when auth state becomes unauthenticated
    - Test that anonymous users do NOT trigger sync

  **Must NOT do**:
  - Do NOT start processor for anonymous users
  - Do NOT enqueue without checking auth state (`FeatureGate.canSync`)
  - Do NOT modify the SyncService push/pull implementations (they work)
  - Do NOT add delete sync operations
  - Do NOT add conflict resolution UI

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Touches multiple files across features, requires understanding sync architecture and auth state management
  - **Skills**: [`git-master`]
    - `git-master`: Multiple files changed, need clean commit
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: No UI changes
    - `playwright`: No browser testing

  **Parallelization**:
  - **Can Run In Parallel**: NO (depends on Task 1)
  - **Parallel Group**: Wave 2 (with Tasks 5, 8)
  - **Blocks**: Tasks 3, 10, 12
  - **Blocked By**: Task 1

  **References**:

  **Pattern References**:
  - `lib/services/sync/sync_queue_processor.dart:11-18` — Existing provider pattern for processor (uses `ref.onDispose`)
  - `lib/services/sync/sync_queue_processor.dart:39-55` — `start()` method with timer and connectivity listener
  - `lib/features/auth/presentation/controllers/auth_controller.dart` — Auth state management pattern (StateNotifier)
  - `lib/database/daos/sync_dao.dart` — `enqueue()` method signature and usage

  **API/Type References**:
  - `lib/database/tables/sync_queue_table.dart` — SyncOperation enum (create, update, delete)
  - `lib/features/auth/data/models/auth_state.dart` — `AppAuthState`/`AppAuthStatus` definitions
  - `lib/core/constants/feature_gate.dart` — `FeatureGate.canSync` check

  **Acceptance Criteria**:

  **TDD Tests:**
  - [ ] Test file created: `test/unit/sync_activation_test.dart`
  - [ ] Test: Saving observation when authenticated enqueues sync item → PASS
  - [ ] Test: Saving observation when anonymous does NOT enqueue → PASS
  - [ ] Test: Auth state → authenticated starts processor → PASS
  - [ ] Test: Auth state → unauthenticated stops processor → PASS
  - [ ] `flutter test test/unit/sync_activation_test.dart` → PASS

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Verify enqueue calls are uncommented and guarded
    Tool: Bash (grep)
    Preconditions: Code changes applied
    Steps:
      1. grep -rn "syncDao.enqueue" lib/ --include="*.dart"
      2. Assert: At least 5 matches (not commented out)
      3. grep -rn "FeatureGate.canSync\|isAuthenticated" near each enqueue call
      4. Assert: Each enqueue is wrapped in auth check
    Expected Result: 5+ active enqueue calls, all auth-guarded
    Evidence: grep output captured

  Scenario: Verify flutter analyze passes
    Tool: Bash
    Preconditions: All code changes applied
    Steps:
      1. Run: flutter analyze lib/features/forays/ lib/features/observations/ lib/features/collaboration/ lib/services/sync/
      2. Assert: "No issues found!" or only info-level messages
    Expected Result: Zero errors or warnings
    Evidence: analyze output captured
  ```

  **Commit**: YES
  - Message: `feat(sync): activate sync queue with auth-gated processor startup`
  - Files: `create_foray_screen.dart`, `join_foray_screen.dart`, `observation_entry_screen.dart`, `add_identification_sheet.dart`, `comments_list.dart`, `app.dart` or `main.dart`, `test/unit/sync_activation_test.dart`
  - Pre-commit: `flutter analyze && flutter test test/unit/sync_activation_test.dart`

---

- [ ] 3. Implement Vote Sync

  **What to do**:
  - **Add `pushVote()` method** to `lib/services/sync/sync_service.dart`:
    - Push vote data to Supabase `identification_votes` table
    - Handle upsert (user can change their vote)
    - Follow existing pattern from `pushIdentification()` for structure
  - **Add `pullVotes()` method** to `SyncService`:
    - Fetch votes for a foray's observations from Supabase
    - Merge with local votes using last-write-wins
    - Follow pattern from existing pull methods
  - **Add `'vote'` case** to `SyncQueueProcessor._processItem()` switch statement at `sync_queue_processor.dart`
  - **Add vote enqueue** in the voting UI:
    - Find where votes are cast (likely in `identifications_list.dart` or the vote button handler)
    - Add `syncDao.enqueue(entityType: 'vote', entityId: voteId, operation: SyncOperation.create)` with auth guard
  - **Write tests** (TDD):
    - Test `pushVote()` constructs correct Supabase payload
    - Test `pullVotes()` merges correctly with local data
    - Test vote enqueue happens on vote action

  **Must NOT do**:
  - Do NOT modify existing push/pull methods for observations, IDs, or comments
  - Do NOT add real-time subscriptions for votes here (that's Task 12)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Requires understanding sync service patterns and Supabase API conventions used in the project
  - **Skills**: [`git-master`]
    - `git-master`: Clean atomic commit
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: No UI work
    - `playwright`: No browser testing

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Task 10)
  - **Blocks**: Task 12
  - **Blocked By**: Task 2

  **References**:

  **Pattern References**:
  - `lib/services/sync/sync_service.dart` — `pushIdentification()` method — follow this exact pattern for `pushVote()`
  - `lib/services/sync/sync_service.dart` — `pullForayObservations()` — follow this pattern for `pullVotes()`
  - `lib/services/sync/sync_queue_processor.dart:70-95` — `_processItem()` switch statement — add `'vote'` case here

  **API/Type References**:
  - `lib/database/tables/identification_votes_table.dart` — Vote table schema (identificationId, userId, createdAt)
  - `lib/database/daos/collaboration_dao.dart` — `addVote()`, `removeVote()`, `getVotesForIdentification()` methods
  - `supabase/migrations/20260122000001_create_tables.sql` — Remote `identification_votes` table schema

  **Test References**:
  - `test/unit/sync_activation_test.dart` — Sync testing patterns (from Task 2)

  **Acceptance Criteria**:

  **TDD Tests:**
  - [ ] Test file created: `test/unit/vote_sync_test.dart`
  - [ ] Test: `pushVote()` sends correct payload to Supabase → PASS
  - [ ] Test: `pullVotes()` merges remote votes into local DB → PASS
  - [ ] Test: Processor handles `'vote'` entity type → PASS
  - [ ] `flutter test test/unit/vote_sync_test.dart` → PASS

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Verify vote case added to processor
    Tool: Bash (grep)
    Preconditions: Code changes applied
    Steps:
      1. grep -n "'vote'" lib/services/sync/sync_queue_processor.dart
      2. Assert: Match found in _processItem switch
      3. grep -n "pushVote" lib/services/sync/sync_service.dart
      4. Assert: Method exists
    Expected Result: Vote sync fully wired
    Evidence: grep output captured

  Scenario: Verify flutter analyze passes
    Tool: Bash
    Steps:
      1. Run: flutter analyze lib/services/sync/
      2. Assert: Zero errors
    Expected Result: Clean analysis
    Evidence: analyze output
  ```

  **Commit**: YES
  - Message: `feat(sync): add vote push/pull sync with queue processing`
  - Files: `sync_service.dart`, `sync_queue_processor.dart`, `identifications_list.dart` (or vote UI), `test/unit/vote_sync_test.dart`
  - Pre-commit: `flutter analyze && flutter test test/unit/vote_sync_test.dart`

---

- [ ] 4. Add Native Share Sheet for Foray Sharing

  **What to do**:
  - **Add `share_plus` dependency** to `pubspec.yaml`
  - **Wire share functionality** in `lib/features/forays/presentation/widgets/share_foray_sheet.dart`:
    - Replace the clipboard-only fallback (around line 140) with `Share.share()` from `share_plus`
    - Share text should include foray name and join link/code
    - Keep clipboard copy as secondary option
  - **Write tests** (TDD):
    - Test that share is invoked with correct text content
    - Test fallback to clipboard when share_plus fails

  **Must NOT do**:
  - Do NOT implement QR code generation (leave that placeholder)
  - Do NOT implement PDF export (leave that placeholder)
  - Do NOT add sharing for individual observations

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Single file change + dependency addition. Straightforward integration.
  - **Skills**: [`git-master`]
    - `git-master`: Clean commit with pubspec change
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: Minimal UI change
    - `playwright`: No browser testing

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 6, 7, 9, 11)
  - **Blocks**: None
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `lib/features/forays/presentation/widgets/share_foray_sheet.dart:130-145` — Current clipboard fallback implementation — replace with share_plus
  - `lib/features/forays/presentation/widgets/share_foray_sheet.dart:100-120` — Share text construction pattern

  **External References**:
  - share_plus official docs: https://pub.dev/packages/share_plus — API reference for `Share.share()`

  **Acceptance Criteria**:

  **TDD Tests:**
  - [ ] Test file created: `test/unit/share_foray_test.dart`
  - [ ] Test: Share invoked with foray name and join code → PASS
  - [ ] `flutter test test/unit/share_foray_test.dart` → PASS

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Verify share_plus is in pubspec
    Tool: Bash (grep)
    Steps:
      1. grep "share_plus" pubspec.yaml
      2. Assert: Dependency present
    Expected Result: share_plus listed
    Evidence: grep output

  Scenario: Verify flutter analyze passes
    Tool: Bash
    Steps:
      1. Run: flutter analyze lib/features/forays/presentation/widgets/share_foray_sheet.dart
      2. Assert: Zero errors
    Expected Result: Clean analysis
    Evidence: analyze output
  ```

  **Commit**: YES
  - Message: `feat(forays): add native share sheet using share_plus`
  - Files: `pubspec.yaml`, `share_foray_sheet.dart`, `test/unit/share_foray_test.dart`
  - Pre-commit: `flutter analyze && flutter test test/unit/share_foray_test.dart`

---

- [ ] 5. Implement Observation Editing Flow

  **What to do**:
  - **Implement `_loadExistingObservation()`** in `lib/features/observations/presentation/screens/observation_entry_screen.dart:120`:
    - Load observation by ID from `observationsDao.getObservationById()`
    - Extract `forayId` from the observation (fixes the `forayId: ''` router issue)
    - Populate all form controllers: species, substrate, habitat, field notes, spore print, collection number, privacy
    - Load associated photos from `observationsDao.getPhotosForObservation()`
    - Display existing photos in the thumbnail strip
  - **Wire the edit button** in `observation_detail_screen.dart:93-97`:
    - Replace "Edit coming soon" snackbar with actual navigation to edit route
    - Pass `observationId` to the route
  - **Implement save-as-update logic**:
    - When `widget.isEditing` is true, use `observationsDao.updateObservation()` instead of `insertObservation()`
    - Enqueue `SyncOperation.update` (not `.create`) when saving edits
    - Guard enqueue with auth check (same pattern as Task 2)
  - **Write tests** (TDD):
    - Test that `_loadExistingObservation()` populates form fields correctly
    - Test that saving in edit mode calls update (not insert)
    - Test that edit enqueues `SyncOperation.update`

  **Must NOT do**:
  - Do NOT implement photo add/remove during editing (text fields only for MVP)
  - Do NOT implement change tracking/diffing
  - Do NOT implement conflict handling for edits
  - Do NOT allow editing locked observations (check lock state — connects to Task 10)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Complex form state management, multiple files, needs understanding of entry screen architecture
  - **Skills**: [`git-master`]
    - `git-master`: Multiple files, clean commit
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: Existing UI, just wiring data
    - `playwright`: Not a browser feature

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2, 8)
  - **Blocks**: None
  - **Blocked By**: None (can start before sync but sync enqueue depends on Task 2 pattern)

  **References**:

  **Pattern References**:
  - `lib/features/observations/presentation/screens/observation_entry_screen.dart:30-120` — Full init flow, form controllers, foray defaults loading
  - `lib/features/observations/presentation/screens/observation_entry_screen.dart:570-630` — Save logic (shows insert pattern — adapt for update)
  - `lib/database/daos/observations_dao.dart` — `getObservationById()`, `updateObservation()`, `getPhotosForObservation()` methods

  **API/Type References**:
  - `lib/database/tables/observations_table.dart` — Observation fields to populate
  - `lib/database/tables/photos_table.dart` — Photo table structure
  - `lib/routing/router.dart:107` — Edit route definition (passes `forayId: ''`, `observationId`)

  **Acceptance Criteria**:

  **TDD Tests:**
  - [ ] Test file created: `test/unit/observation_editing_test.dart`
  - [ ] Test: Loading existing observation populates all form controllers → PASS
  - [ ] Test: Saving in edit mode calls update DAO method → PASS
  - [ ] Test: Edit save enqueues SyncOperation.update → PASS
  - [ ] `flutter test test/unit/observation_editing_test.dart` → PASS

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Verify edit route navigates correctly
    Tool: Bash (grep)
    Steps:
      1. grep -n "Edit coming soon" lib/features/observations/
      2. Assert: Zero matches (snackbar removed)
      3. grep -n "context.push.*edit" lib/features/observations/presentation/screens/observation_detail_screen.dart
      4. Assert: Navigation to edit route present
    Expected Result: Edit button navigates to edit screen
    Evidence: grep output

  Scenario: Verify _loadExistingObservation is implemented
    Tool: Bash (grep)
    Steps:
      1. grep -A5 "_loadExistingObservation" lib/features/observations/presentation/screens/observation_entry_screen.dart
      2. Assert: Method body is NOT empty (no lone "// TODO" line)
    Expected Result: Method has implementation
    Evidence: grep output

  Scenario: Verify flutter analyze passes
    Tool: Bash
    Steps:
      1. flutter analyze lib/features/observations/
      2. Assert: Zero errors
    Expected Result: Clean analysis
    Evidence: analyze output
  ```

  **Commit**: YES
  - Message: `feat(observations): implement observation editing with form pre-population`
  - Files: `observation_entry_screen.dart`, `observation_detail_screen.dart`, `test/unit/observation_editing_test.dart`
  - Pre-commit: `flutter analyze && flutter test test/unit/observation_editing_test.dart`

---

- [ ] 6. Full-Screen Photo Gallery Viewer

  **What to do**:
  - **Create `FullScreenGalleryViewer` widget** in `lib/features/observations/presentation/widgets/`:
    - PageView-based swipeable gallery
    - Shows photo full-screen with black background
    - Page indicator (dots or "1/5" counter)
    - Tap to dismiss (or swipe down)
    - AppBar with close button and current index
  - **Wire to observation detail screen**:
    - Replace the TODO at `observation_detail_screen.dart:239` with navigation to gallery
    - Open gallery at tapped photo's index
  - **Write tests** (TDD):
    - Test gallery renders with correct photo count
    - Test page indicator shows correct index
    - Test dismiss action

  **Must NOT do**:
  - Do NOT add pinch-to-zoom (MVP — simple full-screen view)
  - Do NOT add sharing from gallery
  - Do NOT add photo editing/cropping

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`
    - Reason: Self-contained UI widget, no complex state or service integration
  - **Skills**: [`frontend-ui-ux`]
    - `frontend-ui-ux`: New widget with animations and visual polish needed
  - **Skills Evaluated but Omitted**:
    - `playwright`: Not testable in browser (photo rendering)
    - `git-master`: Simple single-widget addition

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 4, 7, 9, 11)
  - **Blocks**: None
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `lib/features/observations/presentation/screens/observation_detail_screen.dart:220-250` — Current photo gallery implementation (horizontal ListView) — shows photo loading pattern
  - `lib/core/widgets/` — Existing widget patterns for consistent styling

  **External References**:
  - Flutter `PageView` docs — for swipeable page implementation

  **Acceptance Criteria**:

  **TDD Tests:**
  - [ ] Test file created: `test/widget/full_screen_gallery_test.dart`
  - [ ] Test: Gallery renders N pages for N photos → PASS
  - [ ] Test: Page indicator updates on swipe → PASS
  - [ ] `flutter test test/widget/full_screen_gallery_test.dart` → PASS

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Verify gallery widget exists and is wired
    Tool: Bash (grep)
    Steps:
      1. find lib/ -name "*gallery*" -o -name "*full_screen*"
      2. Assert: Gallery file exists
      3. grep -n "FullScreenGallery\|fullScreenGallery\|gallery_viewer" lib/features/observations/presentation/screens/observation_detail_screen.dart
      4. Assert: Gallery is referenced from detail screen
    Expected Result: Gallery widget created and wired
    Evidence: file listing + grep output

  Scenario: Verify flutter analyze passes
    Tool: Bash
    Steps:
      1. flutter analyze lib/features/observations/
      2. Assert: Zero errors
    Expected Result: Clean analysis
    Evidence: analyze output
  ```

  **Commit**: YES
  - Message: `feat(observations): add full-screen swipeable photo gallery viewer`
  - Files: `lib/features/observations/presentation/widgets/full_screen_gallery_viewer.dart`, `observation_detail_screen.dart`, `test/widget/full_screen_gallery_test.dart`
  - Pre-commit: `flutter analyze && flutter test test/widget/full_screen_gallery_test.dart`

---

- [ ] 7. Participant Removal and Leave Foray

  **What to do**:
  - **Wire participant removal** in `lib/features/forays/presentation/widgets/foray_participants_tab.dart:78-85`:
    - Replace "Participant removal coming soon" snackbar with actual `foraysDao.removeParticipant()` call
    - The DAO method already exists at `forays_dao.dart:138-141`
    - Add sync enqueue for participant removal (auth-guarded)
    - Show success snackbar after removal
    - Refresh participant list via Riverpod invalidation
  - **Implement leave foray action**:
    - Add "Leave Foray" button to the foray detail settings tab (or foray detail AppBar overflow menu)
    - Show confirmation dialog: "Leave this foray? Your observations will remain."
    - Call `foraysDao.removeParticipant()` with current user's ID
    - Navigate back to foray list after leaving
    - Add sync enqueue for the leave action (auth-guarded)
  - **Write tests** (TDD):
    - Test participant removal calls DAO and refreshes list
    - Test leave foray calls DAO, navigates, and enqueues sync

  **Must NOT do**:
  - Do NOT add notifications when participants are removed
  - Do NOT remove the leaving participant's observations
  - Do NOT add data retention options

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: DAO layer exists, just wiring UI to it. Small scope.
  - **Skills**: [`git-master`]
    - `git-master`: Clean commit
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: Minimal UI changes (button + dialog)
    - `playwright`: Not browser testable

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 4, 6, 9, 11)
  - **Blocks**: None
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `lib/features/forays/presentation/widgets/foray_participants_tab.dart:50-86` — Current removal UI with confirmation dialog (just needs DAO call wired)
  - `lib/database/daos/forays_dao.dart:138-141` — `removeParticipant(forayId, userId)` method
  - `lib/features/forays/presentation/widgets/foray_settings_tab.dart:140-170` — Existing foray action pattern (complete/reopen/lock) — follow for leave action

  **API/Type References**:
  - `lib/database/tables/foray_participants_table.dart` — Participant table schema
  - `lib/features/auth/presentation/controllers/auth_controller.dart` — Get current user ID

  **Acceptance Criteria**:

  **TDD Tests:**
  - [ ] Test file created: `test/unit/participant_management_test.dart`
  - [ ] Test: Remove participant calls DAO.removeParticipant() → PASS
  - [ ] Test: Leave foray removes current user and navigates to list → PASS
  - [ ] `flutter test test/unit/participant_management_test.dart` → PASS

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Verify removal snackbar is gone
    Tool: Bash (grep)
    Steps:
      1. grep -n "coming soon" lib/features/forays/presentation/widgets/foray_participants_tab.dart
      2. Assert: Zero matches
    Expected Result: Placeholder removed
    Evidence: grep output

  Scenario: Verify leave foray action exists
    Tool: Bash (grep)
    Steps:
      1. grep -rn "Leave\|leave.*foray\|leaveForay" lib/features/forays/
      2. Assert: At least one match showing leave action implementation
    Expected Result: Leave foray action implemented
    Evidence: grep output

  Scenario: Verify flutter analyze passes
    Tool: Bash
    Steps:
      1. flutter analyze lib/features/forays/
      2. Assert: Zero errors
    Expected Result: Clean analysis
    Evidence: analyze output
  ```

  **Commit**: YES
  - Message: `feat(forays): wire participant removal and add leave foray action`
  - Files: `foray_participants_tab.dart`, `foray_settings_tab.dart` or `foray_detail_screen.dart`, `test/unit/participant_management_test.dart`
  - Pre-commit: `flutter analyze && flutter test test/unit/participant_management_test.dart`

---

- [ ] 8. QR/Barcode Scanning in 3 Locations

  **What to do**:
  - **Create reusable `QRScannerSheet` widget** in `lib/core/widgets/`:
    - Uses `MobileScanner` from `mobile_scanner` package (already in pubspec)
    - Bottom sheet or full-screen overlay with camera preview
    - Callback `onScanned(String value)` when code detected
    - Cancel button
    - Permission handling (request camera, explain if denied)
    - **Web platform fallback**: Show text input field instead of camera (web can't scan)
  - **Wire scanner in 3 locations**:
    1. `lib/features/forays/presentation/screens/join_foray_screen.dart:112` — Scan QR → populate join code field
    2. `lib/features/collaboration/presentation/widgets/specimen_lookup_sheet.dart:123` — Scan barcode → trigger specimen search
    3. `lib/features/observations/presentation/screens/observation_entry_screen.dart:522` — Scan barcode → populate specimen ID field
  - **Write tests** (TDD):
    - Test QRScannerSheet renders camera on mobile (mock MobileScanner)
    - Test QRScannerSheet renders text input on web
    - Test onScanned callback fires with scanned value
    - Test each of the 3 integration points passes scanned value correctly

  **Must NOT do**:
  - Do NOT add QR generation (out of scope)
  - Do NOT add barcode scanning for species identification
  - Do NOT add any scanning to observation list

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: New reusable widget + 3 integration points + platform-specific behavior (web fallback)
  - **Skills**: [`frontend-ui-ux`]
    - `frontend-ui-ux`: New widget with camera integration, permission UX, platform-adaptive behavior
  - **Skills Evaluated but Omitted**:
    - `playwright`: Camera can't be tested in headless browser
    - `dev-browser`: Same limitation

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2, 5)
  - **Blocks**: None
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `lib/features/collaboration/presentation/widgets/specimen_lookup_sheet.dart:100-140` — Current sheet structure with search + placeholder scan button
  - `lib/features/observations/presentation/screens/observation_entry_screen.dart:510-530` — Specimen ID section with scan button placeholder
  - `lib/core/config/platform_config.dart:11` — `PlatformConfig.supportsCamera` — use for web detection

  **External References**:
  - mobile_scanner official docs: https://pub.dev/packages/mobile_scanner — API reference for `MobileScanner` widget

  **Acceptance Criteria**:

  **TDD Tests:**
  - [ ] Test file created: `test/widget/qr_scanner_sheet_test.dart`
  - [ ] Test: Scanner sheet renders on mobile (mocked) → PASS
  - [ ] Test: Web fallback shows text input → PASS
  - [ ] Test: onScanned callback fires with value → PASS
  - [ ] `flutter test test/widget/qr_scanner_sheet_test.dart` → PASS

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Verify scanner widget exists
    Tool: Bash (find)
    Steps:
      1. find lib/ -name "*scanner*" -o -name "*qr_scanner*"
      2. Assert: QRScannerSheet file exists in lib/core/widgets/
    Expected Result: Reusable scanner widget created
    Evidence: file listing

  Scenario: Verify all 3 integration points wired
    Tool: Bash (grep)
    Steps:
      1. grep -n "QRScannerSheet\|qr_scanner_sheet" lib/features/forays/presentation/screens/join_foray_screen.dart
      2. Assert: At least 1 match
      3. grep -n "QRScannerSheet\|qr_scanner_sheet" lib/features/collaboration/presentation/widgets/specimen_lookup_sheet.dart
      4. Assert: At least 1 match
      5. grep -n "QRScannerSheet\|qr_scanner_sheet" lib/features/observations/presentation/screens/observation_entry_screen.dart
      6. Assert: At least 1 match
    Expected Result: Scanner used in all 3 locations
    Evidence: grep output

  Scenario: Verify flutter analyze passes
    Tool: Bash
    Steps:
      1. flutter analyze lib/core/widgets/ lib/features/forays/ lib/features/collaboration/ lib/features/observations/
      2. Assert: Zero errors
    Expected Result: Clean analysis
    Evidence: analyze output
  ```

  **Commit**: YES
  - Message: `feat(scanner): add QR/barcode scanning with web fallback in 3 locations`
  - Files: `lib/core/widgets/qr_scanner_sheet.dart`, `join_foray_screen.dart`, `specimen_lookup_sheet.dart`, `observation_entry_screen.dart`, `test/widget/qr_scanner_sheet_test.dart`
  - Pre-commit: `flutter analyze && flutter test test/widget/qr_scanner_sheet_test.dart`

---

- [ ] 9. Fix Hardcoded Values (useMetric, Observation Count)

  **What to do**:
  - **Fix compass useMetric**:
    - In `lib/features/navigation/presentation/screens/compass_navigation_screen.dart:305`:
    - Replace `useMetric: true` with reading from `useMetricProvider` (already exists in `settings_controller.dart`)
    - Use `ref.watch(useMetricProvider)` or equivalent Riverpod access
  - **Fix foray card observation count**:
    - In `lib/features/forays/presentation/widgets/foray_card.dart:123`:
    - Add observation count display
    - Query from `observationsDao.getObservationCountForForay()` (or similar method — check if it exists, create if needed)
    - Display as "N observations" on the card
  - **Write tests** (TDD):
    - Test compass screen reads metric preference
    - Test foray card displays observation count

  **Must NOT do**:
  - Do NOT refactor the entire settings system
  - Do NOT add new settings options
  - Do NOT modify the compass widget itself (just the screen that uses it)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Two small, isolated fixes. Each is a few lines of code.
  - **Skills**: [`git-master`]
    - `git-master`: Clean commit
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: Trivial UI changes
    - `playwright`: Not browser testable

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 4, 6, 7, 11)
  - **Blocks**: None
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `lib/features/settings/presentation/controllers/settings_controller.dart` — `useMetricProvider` definition
  - `lib/features/navigation/presentation/screens/compass_navigation_screen.dart:305` — Hardcoded `useMetric: true`
  - `lib/features/forays/presentation/widgets/foray_card.dart:120-130` — TODO for observation count

  **API/Type References**:
  - `lib/database/daos/observations_dao.dart` — Check for count method (may need to add `getObservationCountForForay(forayId)`)

  **Acceptance Criteria**:

  **TDD Tests:**
  - [ ] Test: Compass screen passes metric preference from provider → PASS
  - [ ] Test: Foray card displays observation count → PASS
  - [ ] Tests added to existing or new test file → PASS

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Verify hardcoded useMetric removed
    Tool: Bash (grep)
    Steps:
      1. grep -n "useMetric: true" lib/features/navigation/
      2. Assert: Zero matches with hardcoded "true"
    Expected Result: useMetric reads from provider
    Evidence: grep output

  Scenario: Verify flutter analyze passes
    Tool: Bash
    Steps:
      1. flutter analyze lib/features/navigation/ lib/features/forays/
      2. Assert: Zero errors
    Expected Result: Clean analysis
    Evidence: analyze output
  ```

  **Commit**: YES
  - Message: `fix(ui): read useMetric from settings and show observation count on foray card`
  - Files: `compass_navigation_screen.dart`, `foray_card.dart`, possibly `observations_dao.dart`
  - Pre-commit: `flutter analyze`

---

- [ ] 10. Enforce Lock State on Observation Detail

  **What to do**:
  - **Replace hardcoded values** in `lib/features/observations/presentation/screens/observation_detail_screen.dart:155-166`:
    - `isLocked: false` → Read from foray's `observationsLocked` field
    - `canDelete: true` → Check if current user is the observation collector or foray organizer
    - `isOrganizer: false` → Check if current user is foray organizer
  - **Implementation approach**:
    - Load the parent foray data (the observation has `forayId`)
    - Check foray's `observationsLocked` boolean field
    - Get current user ID from auth controller
    - Compare with observation's `collectorId` and foray's organizer (from `foray_participants` with `organizer` role)
    - May need a new provider: `forayLockStateProvider(forayId)` that returns `{isLocked, isOrganizer, isCollector}`
  - **Disable edit button** when foray is locked (from Task 5's edit button)
  - **Write tests** (TDD):
    - Test: Locked foray → isLocked=true, add ID/comment buttons disabled
    - Test: Unlocked foray → isLocked=false, all actions enabled
    - Test: Collector can delete own observations
    - Test: Organizer can delete any observation
    - Test: Regular participant cannot delete others' observations

  **Must NOT do**:
  - Do NOT add a lock/unlock UI here (that already exists in foray settings tab)
  - Do NOT add locking to the observation list view (detail only)
  - Do NOT add toast/notification when lock state changes

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Replace hardcoded booleans with provider queries. Clear pattern, limited scope.
  - **Skills**: [`git-master`]
    - `git-master`: Clean commit
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: No new UI, just wiring data
    - `playwright`: Not browser testable

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Task 3)
  - **Blocks**: None
  - **Blocked By**: Task 2 (needs sync context to understand auth state)

  **References**:

  **Pattern References**:
  - `lib/features/observations/presentation/screens/observation_detail_screen.dart:152-166` — Hardcoded values to replace
  - `lib/features/forays/presentation/widgets/foray_settings_tab.dart:158-170` — How lock state is set (shows the field name)
  - `lib/features/collaboration/presentation/widgets/identifications_list.dart` — Uses `isLocked` parameter to control UI
  - `lib/features/collaboration/presentation/widgets/comments_list.dart` — Uses `isLocked` parameter to control UI

  **API/Type References**:
  - `lib/database/tables/forays_table.dart` — `observationsLocked` field
  - `lib/database/tables/foray_participants_table.dart` — `role` field (organizer vs participant)
  - `lib/database/daos/forays_dao.dart` — Methods to get foray and participants

  **Acceptance Criteria**:

  **TDD Tests:**
  - [ ] Test file created: `test/unit/lock_state_test.dart`
  - [ ] Test: Locked foray passes isLocked=true to IdentificationsList and CommentsList → PASS
  - [ ] Test: Collector gets canDelete=true for own observations → PASS
  - [ ] Test: Non-collector non-organizer gets canDelete=false → PASS
  - [ ] Test: Organizer gets isOrganizer=true → PASS
  - [ ] `flutter test test/unit/lock_state_test.dart` → PASS

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Verify hardcoded lock values removed
    Tool: Bash (grep)
    Steps:
      1. grep -n "isLocked: false.*TODO\|canDelete: true.*TODO\|isOrganizer: false.*TODO" lib/features/observations/
      2. Assert: Zero matches
    Expected Result: All hardcoded values replaced with dynamic lookups
    Evidence: grep output

  Scenario: Verify flutter analyze passes
    Tool: Bash
    Steps:
      1. flutter analyze lib/features/observations/
      2. Assert: Zero errors
    Expected Result: Clean analysis
    Evidence: analyze output
  ```

  **Commit**: YES
  - Message: `fix(observations): enforce foray lock state and role-based permissions on detail screen`
  - Files: `observation_detail_screen.dart`, possibly new provider file, `test/unit/lock_state_test.dart`
  - Pre-commit: `flutter analyze && flutter test test/unit/lock_state_test.dart`

---

- [ ] 11. Update PROGRESS.md to Reflect Actual State

  **What to do**:
  - Update PROGRESS.md with corrections identified during audit:
    - Mark developer toggle (Step 2.7) as ✅ DONE (DemoConfig.preSeedData exists)
    - Update Phase 9 status notes to reflect sync queue is infrastructure-complete but was not activated
    - Add notes about what this MVP work plan addresses
    - Update "Last Updated" date
    - Fix the completion summary table to accurately reflect current state
  - Add technical debt items discovered during audit:
    - Observation editing was empty (not just "route exists")
    - Lock state was hardcoded (not just "TODO")
    - Sync queue was dead code (all enqueues commented out)

  **Must NOT do**:
  - Do NOT mark items as complete that haven't been implemented yet
  - Do NOT remove any existing content
  - Do NOT change the file structure

  **Recommended Agent Profile**:
  - **Category**: `writing`
    - Reason: Documentation update, accuracy and clarity matter
  - **Skills**: [`git-master`]
    - `git-master`: Clean commit for docs
  - **Skills Evaluated but Omitted**:
    - All technical skills: This is purely documentation

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 4, 6, 7, 9)
  - **Blocks**: None
  - **Blocked By**: None

  **References**:

  **Documentation References**:
  - `PROGRESS.md` — Current progress tracker to be updated

  **Acceptance Criteria**:

  - [ ] Developer toggle marked as done
  - [ ] Phase 9 notes accurately describe sync queue state
  - [ ] Last Updated date reflects current date
  - [ ] No false claims about implementation status

  **Commit**: YES (groups with any other task)
  - Message: `docs(progress): update PROGRESS.md to reflect actual implementation state`
  - Files: `PROGRESS.md`
  - Pre-commit: N/A

---

- [ ] 12. Supabase Realtime Subscriptions for Live Collaboration

  **What to do**:
  - **Create a `RealtimeService`** in `lib/services/sync/realtime_service.dart`:
    - Subscribe to Supabase Realtime channels for a foray's data:
      - `observations` table filtered by `foray_id` — INSERT, UPDATE
      - `identifications` table filtered by observation IDs in the foray — INSERT, UPDATE, DELETE
      - `identification_votes` table — INSERT, UPDATE, DELETE
      - `comments` table — INSERT, UPDATE, DELETE
    - On receiving a change: write to local Drift database first, then let existing Riverpod watch streams propagate to UI
    - Handle subscription lifecycle: subscribe when entering foray detail, unsubscribe when leaving
    - Handle connectivity: resubscribe on reconnect, pull missed changes
  - **Create Riverpod provider** for realtime:
    - `forayRealtimeProvider(forayId)` — AutoDispose family provider
    - Subscribe in provider body, unsubscribe in `ref.onDispose()`
    - Follows AGENTS.md pattern: "Subscribe in provider/init; unsubscribe on dispose"
  - **Wire to foray detail screen**:
    - Watch `forayRealtimeProvider(forayId)` in `ForayDetailScreen`
    - This triggers subscription when screen is active, cleanup when left
  - **Handle reconnection**:
    - On connectivity restore, trigger pull sync for the foray's data
    - This fills any gaps from while offline
  - **Write tests** (TDD):
    - Test: Realtime provider subscribes on creation
    - Test: Realtime provider unsubscribes on dispose
    - Test: Incoming observation INSERT writes to local DB
    - Test: Incoming comment INSERT writes to local DB
    - Test: Reconnection triggers pull sync

  **Must NOT do**:
  - Do NOT add presence (who's online)
  - Do NOT add typing indicators
  - Do NOT subscribe in `build()` methods (use providers)
  - Do NOT bypass local-first pattern (always write to Drift first)
  - Do NOT add notification/toast on each incoming change (UI updates naturally via Drift streams)

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Most complex task — Supabase Realtime integration, provider lifecycle, offline handling, merging remote data into local DB. Requires deep understanding of both Supabase and Riverpod patterns.
  - **Skills**: [`git-master`]
    - `git-master`: Important feature, clean commit
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: No visual UI changes
    - `playwright`: Can't test realtime in headless browser

  **Parallelization**:
  - **Can Run In Parallel**: NO (depends on sync being activated)
  - **Parallel Group**: Wave 4 (sequential, final task)
  - **Blocks**: None (final task)
  - **Blocked By**: Tasks 2 (sync active), 3 (votes sync — needed for vote realtime)

  **References**:

  **Pattern References**:
  - `lib/services/sync/sync_service.dart` — Existing sync patterns for writing to local DB from remote data
  - `lib/services/sync/sync_queue_processor.dart:11-18` — Provider pattern with `ref.onDispose()` cleanup — follow this exactly
  - `lib/services/supabase_service.dart` — Supabase client provider access

  **API/Type References**:
  - `lib/database/daos/observations_dao.dart` — Methods for inserting/updating observations locally
  - `lib/database/daos/collaboration_dao.dart` — Methods for inserting IDs, votes, comments locally
  - `supabase/migrations/20260122000001_create_tables.sql` — Remote table schemas for channel filters

  **External References**:
  - Supabase Realtime Dart docs: Supabase Flutter `channel().onPostgresChanges()` API — use Context7 or librarian to look up exact API

  **Acceptance Criteria**:

  **TDD Tests:**
  - [ ] Test file created: `test/unit/realtime_service_test.dart`
  - [ ] Test: Provider subscribes to correct channel on creation → PASS
  - [ ] Test: Provider unsubscribes on dispose → PASS
  - [ ] Test: Incoming observation INSERT persists to local DB → PASS
  - [ ] Test: Incoming comment INSERT persists to local DB → PASS
  - [ ] Test: Reconnection triggers pull sync → PASS
  - [ ] `flutter test test/unit/realtime_service_test.dart` → PASS

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Verify realtime service exists with correct structure
    Tool: Bash (grep)
    Steps:
      1. find lib/ -name "*realtime*"
      2. Assert: realtime_service.dart exists in lib/services/sync/
      3. grep -n "ref.onDispose" lib/services/sync/realtime_service.dart
      4. Assert: Disposal cleanup present
      5. grep -n "onPostgresChanges\|channel\|subscribe" lib/services/sync/realtime_service.dart
      6. Assert: Supabase Realtime subscription code present
    Expected Result: Realtime service properly structured with lifecycle management
    Evidence: grep output

  Scenario: Verify foray detail wires realtime provider
    Tool: Bash (grep)
    Steps:
      1. grep -n "forayRealtimeProvider\|realtimeProvider" lib/features/forays/presentation/screens/foray_detail_screen.dart
      2. Assert: At least 1 match (provider is watched)
    Expected Result: Foray detail triggers realtime subscription
    Evidence: grep output

  Scenario: Verify flutter analyze passes
    Tool: Bash
    Steps:
      1. flutter analyze lib/services/sync/ lib/features/forays/
      2. Assert: Zero errors
    Expected Result: Clean analysis
    Evidence: analyze output
  ```

  **Commit**: YES
  - Message: `feat(realtime): add Supabase Realtime subscriptions for live foray collaboration`
  - Files: `lib/services/sync/realtime_service.dart`, `foray_detail_screen.dart`, `test/unit/realtime_service_test.dart`
  - Pre-commit: `flutter analyze && flutter test test/unit/realtime_service_test.dart`

---

## Commit Strategy

| After Task | Message | Key Files | Verification |
|------------|---------|-----------|--------------|
| 1 | `chore(supabase): verify and apply database migrations` | supabase config | `supabase migration list` |
| 2 | `feat(sync): activate sync queue with auth-gated processor startup` | 5 feature files + app init | `flutter analyze && flutter test` |
| 3 | `feat(sync): add vote push/pull sync with queue processing` | sync_service, processor | `flutter analyze && flutter test` |
| 4 | `feat(forays): add native share sheet using share_plus` | pubspec, share_foray_sheet | `flutter analyze && flutter test` |
| 5 | `feat(observations): implement observation editing with form pre-population` | observation screens | `flutter analyze && flutter test` |
| 6 | `feat(observations): add full-screen swipeable photo gallery viewer` | new gallery widget, detail screen | `flutter analyze && flutter test` |
| 7 | `feat(forays): wire participant removal and add leave foray action` | participants tab, settings tab | `flutter analyze && flutter test` |
| 8 | `feat(scanner): add QR/barcode scanning with web fallback in 3 locations` | new scanner widget, 3 screens | `flutter analyze && flutter test` |
| 9 | `fix(ui): read useMetric from settings and show observation count on foray card` | compass screen, foray card | `flutter analyze` |
| 10 | `fix(observations): enforce foray lock state and role-based permissions` | observation_detail_screen | `flutter analyze && flutter test` |
| 11 | `docs(progress): update PROGRESS.md to reflect actual implementation state` | PROGRESS.md | N/A |
| 12 | `feat(realtime): add Supabase Realtime subscriptions for live foray collaboration` | realtime_service, foray_detail | `flutter analyze && flutter test` |

---

## Success Criteria

### Verification Commands
```bash
flutter analyze                    # Expected: No issues found
flutter test                       # Expected: All tests pass
flutter build apk --debug          # Expected: BUILD SUCCESSFUL
```

### Final Checklist
- [ ] All 5 sync enqueue calls are active and auth-guarded
- [ ] Sync processor starts automatically for authenticated users
- [ ] Vote sync (push/pull) is implemented
- [ ] QR scanner works in 3 locations (mobile) with web fallback
- [ ] Native share sheet opens for foray sharing
- [ ] Observation editing loads, modifies, and saves
- [ ] Full-screen photo gallery is swipeable
- [ ] Participant removal works (organizer action)
- [ ] Leave foray works (participant action)
- [ ] Lock state is enforced on observation detail
- [ ] Compass reads metric preference from settings
- [ ] Foray card shows observation count
- [ ] Supabase Realtime delivers live updates within forays
- [ ] PROGRESS.md is accurate
- [ ] `flutter analyze` reports zero errors
- [ ] All new test files pass
- [ ] No "coming soon" snackbars remain for in-scope features
