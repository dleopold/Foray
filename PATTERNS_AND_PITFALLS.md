# Patterns and Pitfalls

**Purpose:** Comprehensive guide to Flutter/Dart patterns, common pitfalls, and best practices specific to the Foray tech stack.

**How to Use:** 
- Reference this document when implementing features in unfamiliar areas
- Each spec links to relevant sections here
- AGENTS.md contains a condensed "Critical Gotchas" quick reference

---

## Table of Contents

1. [Flutter/Dart Gotchas](#1-flutterdart-gotchas)
2. [Riverpod 2.x Pitfalls](#2-riverpod-2x-pitfalls)
3. [Drift/SQLite Gotchas](#3-driftsqlite-gotchas)
4. [Supabase Integration](#4-supabase-integration)
5. [Offline-First & Sync Patterns](#5-offline-first--sync-patterns)
6. [GoRouter Pitfalls](#6-gorouter-pitfalls)
7. [flutter_map Gotchas](#7-flutter_map-gotchas)
8. [Cross-Platform Considerations](#8-cross-platform-considerations)
9. [Performance Patterns](#9-performance-patterns)
10. [Testing Patterns](#10-testing-patterns)
11. [Pre-Flight Checklist](#11-pre-flight-checklist)
12. [Escalation Triggers](#12-escalation-triggers)

---

## 1. Flutter/Dart Gotchas

**Referenced by:** `specs/01-foundation.md`, `specs/05-observations.md`

### Lifecycle & Async Safety

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Using `BuildContext` after `await` | Crashes or wrong navigation when widget disposed mid-await | After awaits: `if (!context.mounted) return;` |
| Calling `setState` after dispose | Common in async callbacks (GPS, camera, uploads) | Guard with `if (!mounted) return;` |
| Creating controllers in `build()` | Memory leaks + state resets every rebuild | Create in `initState`, dispose in `dispose()` |
| Heavy work in `build()` | Jank + dropped frames | Precompute in provider, memoize, or use isolate |

**Async UI Safety Pattern:**
```dart
onPressed: () async {
  final result = await doSomething();
  if (!context.mounted) return;  // CRITICAL: Check before any UI operation
  Navigator.of(context).push(...);
  // or setState(() { ... });
}
```

### Build Method Hygiene

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| `const` missing in hot paths | Increased rebuild cost | Aggressively add `const` for static subtrees |
| Unbounded `ListView` children | OOM / jank with photos/observations | Use `ListView.builder` with stable keys |
| `StreamBuilder` with recreated stream | Duplicate subscriptions, leaks | Store stream in state/provider; don't create inline |
| `DateTime.now()` in build | Forces rebuild diffs, weird tests | Compute once, or drive from ticker/provider |

---

## 2. Riverpod 2.x Pitfalls

**Referenced by:** `specs/01-foundation.md`, all feature specs

### Ref Usage

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| `ref.read()` in build to "avoid rebuilds" | UI won't update; creates stale bugs | Use `ref.watch()` in build; `read` only in callbacks |
| Side effects in build via `watch` | Rebuild loops, repeated calls | Use `ref.listen()` for side effects (snackbars, navigation) |
| Using `ref` after `await` in providers | Provider may have been disposed | After await: `if (!ref.mounted) return;` |

### Resource Management

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Leaking streams/timers/controllers | Silent memory leaks over time | Always `ref.onDispose(() => resource.close())` |
| `autoDispose` thrashing | Re-fetching expensive data on navigation | Use `ref.keepAlive()` for expensive providers |
| Over-watching large objects | Unnecessary rebuilds | Use `select` to watch only needed fields |

**Resource-Safe Provider Pattern:**
```dart
final myProvider = FutureProvider.autoDispose((ref) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(timer.cancel);

  final result = await loadStuff();
  if (!ref.mounted) throw StateError('Disposed during async gap');
  return result;
});
```

**Disposal Pattern:**
```dart
final streamProvider = StreamProvider.autoDispose((ref) {
  final controller = StreamController<Data>();
  
  ref.onDispose(() {
    controller.close();  // ALWAYS clean up
  });
  
  return controller.stream;
});
```

---

## 3. Drift/SQLite Gotchas

**Referenced by:** `specs/02-database.md`

### Schema & Migrations

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Forgetting to bump `schemaVersion` | Migrations never run; data breaks | Increment `schemaVersion` on ANY schema change |
| Non-cumulative upgrade logic | Users can upgrade from any old version | Use `if (from < 2) ...; if (from < 3) ...;` pattern |
| Adding non-null columns without defaults | Migration fails on existing rows | Add defaults or make nullable + backfill |
| Editing generated `.g.dart` files | Changes lost, hard-to-debug diffs | Never edit; rerun `build_runner` |

### Data Integrity

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| SQLite foreign keys disabled by default | Orphans + inconsistent data | Enable in `beforeOpen`: `PRAGMA foreign_keys = ON` |
| Multi-step writes without transaction | Partial state, broken sync queue | Wrap in `transaction(() async { ... })` |
| Missing schema validation in tests | Migrations rot unnoticed | Add test with `validateDatabaseSchema()` |

**Migration & FK Hardening:**
```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async {
    await m.createAll();
  },
  onUpgrade: (m, from, to) async {
    // Cumulative migrations - users can upgrade from any version
    if (from < 2) {
      await m.addColumn(observations, observations.specimenId);
    }
    if (from < 3) {
      await m.createTable(comments);
    }
  },
  beforeOpen: (details) async {
    // CRITICAL: Enable foreign key enforcement
    await customStatement('PRAGMA foreign_keys = ON');
    
    // Verify FK integrity after migrations
    if (details.hadUpgrade) {
      final violations = await customSelect('PRAGMA foreign_key_check').get();
      if (violations.isNotEmpty) {
        throw StateError('FK violations after migration: $violations');
      }
    }
  },
);
```

### Stream Performance

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Overusing `watch()` without `distinct` | UI rebuild storms | Prefer narrower queries; apply mapping |
| Watching entire tables | Rebuilds on any row change | Watch specific queries with filters |

---

## 4. Supabase Integration

**Referenced by:** `specs/03-auth.md`, `specs/06-collaboration.md`, `specs/09-sync.md`

### Auth & Session Management

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Insecure session storage | Tokens exposed | Use `flutter_secure_storage` on mobile |
| "Random" auth failures after idle | Token refresh not handled | Listen to `auth.onAuthStateChange`, react to refresh/sign-out |
| Not clearing state on sign-out | Privacy leak (cached data) | On `signedOut`, clear sensitive caches, stop realtime |
| Shipping service role key | Complete security breach | **NEVER** include service key in app; anon key only |

**Auth State Listener Pattern:**
```dart
final authSubscription = supabase.auth.onAuthStateChange.listen((data) {
  final event = data.event;
  
  switch (event) {
    case AuthChangeEvent.signedOut:
      // Clear sensitive local data
      clearUserCaches();
      stopRealtimeSubscriptions();
      break;
    case AuthChangeEvent.tokenRefreshed:
      // Session refreshed, may need to retry failed requests
      retrySyncQueue();
      break;
    // ... handle other events
  }
});

ref.onDispose(() => authSubscription.cancel());
```

### RLS Debugging (Silent Failures)

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Empty results due to RLS | Looks like "no data" not "no access" | Test with `auth.uid()` in SQL editor |
| Missing `WITH CHECK` on INSERT/UPDATE | Users can read but can't write | Define policies per operation |
| Client-side filtering for privacy | Security theater; data already leaked | Enforce privacy in RLS; client filtering is UX only |

**RLS Debugging Steps:**
1. Open Supabase SQL Editor
2. Run: `SELECT auth.uid();` — verify user context
3. Run your query directly — see if RLS blocks it
4. Check `pg_policies` view for policy definitions
5. Test as different users to verify access levels

### Realtime Lifecycle

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Subscribing in `build()` | Duplicate handlers, leaks | Subscribe in provider/init; unsubscribe on dispose |
| Realtime not enabled on table | No events arrive | Enable in Supabase Dashboard → Database → Replication |
| RLS blocks realtime payloads | "Subscribed" but no updates | SELECT policy must allow user access |

**Realtime Cleanup Pattern:**
```dart
final channel = supabase.channel('foray:${forayId}');

channel
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'observations',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'foray_id',
      value: forayId,
    ),
    callback: (payload) {
      // Handle change
    },
  )
  .subscribe();

ref.onDispose(() {
  channel.unsubscribe();  // CRITICAL: Always unsubscribe
});
```

---

## 5. Offline-First & Sync Patterns

**Referenced by:** `specs/09-sync.md`

### Core Principles

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Treating remote as source-of-truth | Offline edits get overwritten | Local DB is primary; sync is replication |
| Non-idempotent creates | Retries create duplicates | Use stable UUIDs; upsert with `onConflict` |
| Privacy + sync mismatch | "Private" content accidentally synced | Gate privacy check before enqueue AND before upload |

### Queue Management

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Queue bloat (update-update-update) | Slow sync, wasted bandwidth | Coalesce queue items per entity (keep latest) |
| Concurrent processors | Duplicate uploads, conflicts | Single-flight lock (one processor at a time) |
| No backoff on failures | Hammers server, drains battery | Exponential backoff + max retries |

### Partial Entity Sync

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Photos vs record out of sync | Orphaned uploads or broken records | Two-phase: upload blobs first, then upsert metadata |
| No per-photo status tracking | Can't resume partial uploads | Track upload status per photo |

**Queue Processing Rules:**
```dart
// 1. Mark item 'processing' atomically before work
await syncDao.markProcessing(item.id);

try {
  // 2. Do the sync work
  await uploadToSupabase(item);
  
  // 3. Mark complete on success
  await syncDao.markComplete(item.id);
} catch (e) {
  // 4. Revert to pending with backoff on failure
  await syncDao.markPendingWithBackoff(item.id, item.retryCount + 1);
  
  // 5. Surface stuck items to UI after max retries
  if (item.retryCount >= maxRetries) {
    await syncDao.markFailed(item.id);
  }
}
```

### Conflict Handling

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Clock skew in last-write-wins | Wrong version "wins" | Prefer server timestamps; store both local + remote `updated_at` |
| Silently overwriting user edits | Data loss, angry users | At minimum, log conflicts; consider conflict UI for important data |

---

## 6. GoRouter Pitfalls

**Referenced by:** `specs/01-foundation.md`, `specs/03-auth.md`

### Redirect Logic

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Redirect loops | App becomes unusable | Check `state.matchedLocation` before returning redirect |
| Async work in `redirect` | Redirect must be fast/sync | Keep redirect sync; use providers + loading screens for async |
| Router not reevaluating on auth changes | Stale redirects | Use `refreshListenable` with Riverpod trigger |

**Safe Redirect Pattern:**
```dart
redirect: (context, state) {
  final isAuthenticated = ref.read(authProvider).isAuthenticated;
  final isAuthRoute = state.matchedLocation.startsWith('/auth');
  
  // Avoid redirect loops
  if (!isAuthenticated && !isAuthRoute) {
    // Preserve destination for post-login redirect
    return '/auth/login?from=${Uri.encodeComponent(state.uri.toString())}';
  }
  
  if (isAuthenticated && isAuthRoute) {
    return '/';  // Already logged in, go home
  }
  
  return null;  // No redirect needed
}
```

### Navigation Behavior

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Losing deep-link destination after login | Bad UX; breaks web demo | Preserve `from` param, redirect after auth |
| Misusing `go()` vs `push()` | Unexpected back button behavior | `go` replaces stack; `push` adds to it |
| Passing non-serializable `extra` | Web refresh/deep link breaks | Keep `extra` optional; encode critical state in path/query |

---

## 7. flutter_map Gotchas

**Referenced by:** `specs/08-maps.md`

### Controller & Lifecycle

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Creating `MapController` in build | Resets map state, leaks | Create once in state/provider, dispose properly |
| Missing `userAgentPackageName` | Tile servers may throttle/deny | Always set `userAgentPackageName` in `TileLayer` |

### Performance

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Too many markers as widgets | Massive jank | Cluster markers; simplify marker widgets |
| Rebuilding entire map on small changes | FPS drops | Separate marker layer from map; use `select` |
| No tile caching | Bad offline UX, repeated downloads | Configure caching provider with sane cache size |
| Web tile request overload | Browser limits connections | Use cancellable tile provider for web |

**Map Controller Pattern:**
```dart
class _ForayMapScreenState extends ConsumerState<ForayMapScreen> {
  late final MapController _mapController;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();  // Create once
  }
  
  @override
  void dispose() {
    _mapController.dispose();  // Clean up
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      // ...
    );
  }
}
```

---

## 8. Cross-Platform Considerations

**Referenced by:** `specs/05-observations.md`, `specs/10-web-demo.md`

### Platform Differences

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Path/file APIs differ on web | Camera/file pickers behave differently | Gate with `kIsWeb`; avoid assuming `File` exists |
| Background execution limits (iOS) | "Background sync" won't run reliably | Sync on foreground/resume + connectivity restore |
| Permission UX differences | App store rejection, poor UX | Handle "denied permanently"; guide user to Settings |
| SQLite/web storage differences | Drift web backend differs | Test migrations on web explicitly |

**Platform-Safe File Handling:**
```dart
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> handleImage(dynamic imageData) async {
  if (kIsWeb) {
    // Web: handle as bytes or blob URL
    final bytes = imageData as Uint8List;
    // ...
  } else {
    // Mobile: handle as File
    final file = imageData as File;
    // ...
  }
}
```

---

## 9. Performance Patterns

**Referenced by:** `specs/05-observations.md`, `specs/07-navigation.md`, `specs/08-maps.md`

### High-Frequency Updates

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Sensor streams (GPS/compass) driving UI directly | Battery drain, jank | Throttle to human rates (4-10 Hz for compass, 1 Hz for GPS) |
| Watching "whole state" in large screens | Rebuild storms | Use smaller providers + `select` |

**Throttled Sensor Pattern:**
```dart
final throttledCompassProvider = StreamProvider.autoDispose((ref) {
  return FlutterCompass.events
      .whereNotNull()
      .throttleTime(const Duration(milliseconds: 100))  // 10 Hz max
      .map((event) => event.heading ?? 0);
});
```

### Image Handling

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Rendering full-res images in lists | OOM on mid-tier devices | Use `cacheWidth`/`cacheHeight` to decode smaller |
| Decoding images in list builders | Jank during scroll | Pre-cache thumbnails; use `precacheImage` |

**Memory-Efficient Image:**
```dart
Image.file(
  file,
  cacheWidth: 200,   // Decode at thumbnail size
  cacheHeight: 200,  // Saves significant memory
  fit: BoxFit.cover,
)
```

---

## 10. Testing Patterns

**Referenced by:** All specs

### Provider Testing

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Provider overrides not used | Flaky tests hitting real services | Use `ProviderContainer(overrides: [...])` |
| Not disposing container | Resource leaks in tests | `addTearDown(container.dispose)` |

**Provider Test Setup:**
```dart
void main() {
  test('foray provider returns data', () async {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(mockDatabase),
        supabaseClientProvider.overrideWithValue(mockSupabase),
      ],
    );
    addTearDown(container.dispose);  // CRITICAL: Clean up
    
    final foray = await container.read(forayProvider('123').future);
    expect(foray, isNotNull);
  });
}
```

### Async & Widget Testing

| Gotcha | Why It Matters | Correct Approach |
|--------|----------------|------------------|
| Async tests not waiting correctly | False positives/negatives | Use `pumpAndSettle` carefully; `fake_async` for timers |
| Drift tests using real file DB | Slow, state leakage | Use in-memory DB; create/tear down per test |
| GoRouter widget tests failing | Router needs MaterialApp.router | Wrap in `MaterialApp.router(routerConfig: ...)` |

**Drift In-Memory Test Setup:**
```dart
AppDatabase createTestDatabase() {
  return AppDatabase(NativeDatabase.memory());  // In-memory for speed
}

void main() {
  late AppDatabase db;
  
  setUp(() {
    db = createTestDatabase();
  });
  
  tearDown(() async {
    await db.close();  // Clean up after each test
  });
  
  test('can insert observation', () async {
    // Test with isolated database
  });
}
```

---

## 11. Pre-Flight Checklist

Before submitting code, verify:

| Check | Why | How to Verify |
|-------|-----|---------------|
| **No async lifecycle bugs** | Prevent crashes | `context.mounted` / `mounted` after all awaits |
| **No resource leaks** | Prevent degradation | Controllers/streams/timers closed in `dispose` / `ref.onDispose` |
| **Offline correctness** | Core requirement | Local write + queue enqueue before any network call |
| **Privacy correctness** | Core requirement | Private data never leaves device without explicit rule |
| **RLS correctness** | Prevent silent failures | If query returns empty, test `auth.uid()` + policies |
| **Navigation correctness** | Prevent loops | Test redirects and deep link return paths |

---

## 12. Escalation Triggers

When to revisit architecture decisions:

| Trigger | Current Approach | Escalation |
|---------|------------------|------------|
| Sync conflicts common (multi-user edits) | Last-write-wins | Add explicit conflict records + resolution UI |
| Realtime unreliable (mobile networks) | Realtime subscriptions | Shift to pull-based periodic sync |
| Map marker count large (thousands) | Simple marker layer | Implement clustering + spatial indexing + viewport queries |
| Queue grows unbounded | Simple queue table | Add queue coalescing + compaction job |

---

*This document should be updated when new patterns or pitfalls are discovered during development.*
