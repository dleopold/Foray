# AI Agent Instructions for Foray

This document provides context and guidelines for AI coding agents working on the Foray project.

---

## Project Overview

**Foray** is a cross-platform mobile application for documenting fungal collections in the field. Built with Flutter/Dart, it supports iOS, Android, and Web (for demo purposes).

### Key Characteristics
- **Offline-first**: All features must work without network connectivity
- **Privacy-first**: Location data is sensitive; default to private
- **Portfolio piece**: UI/UX quality is critical; polish matters

### Tech Stack
| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod 2.x |
| Local Database | Drift (SQLite) |
| Cloud Backend | Supabase (PostgreSQL, Auth, Storage, Realtime) |
| Navigation | GoRouter |
| Maps | flutter_map |

---

## MCP Tools for Documentation & Research

When working on this project, **always use MCP tools** to look up documentation before implementing unfamiliar APIs or patterns. Do not guess or rely on potentially outdated training data.

### Available MCP Tools

| Tool | Purpose | When to Use |
|------|---------|-------------|
| **Context7** | Official library documentation | API signatures, usage patterns, configuration options, method parameters |
| **grep.app** | Real code from GitHub repos | Production patterns, how others solved similar problems, real-world examples |
| **Exa** | Web search | Articles, tutorials, discussions, troubleshooting, recent updates |

### Usage Guidelines

#### Context7 (Primary Documentation Source)
**ALWAYS use Context7 first** for library documentation. It provides accurate, up-to-date API information.

```
// Example: Looking up Riverpod documentation
1. resolve-library-id: "riverpod" 
2. query-docs: "/riverpod/riverpod" with query "StateNotifier vs AsyncNotifier"
```

Key libraries to query via Context7:
- `flutter` - Flutter framework APIs
- `riverpod` - State management
- `drift` - Local SQLite database  
- `supabase` - Backend services (auth, database, storage)
- `go_router` - Navigation
- `flutter_map` - Map widgets

#### grep.app (Real-World Examples)
Use grep.app to find how production apps implement specific patterns:
- Search for `Riverpod AsyncNotifier` to see real implementations
- Search for `Drift DAO` to see database patterns
- Search for `Supabase RLS` to see Row Level Security examples

#### Exa (Web Search)
Use for:
- Recent blog posts about new features
- Troubleshooting specific error messages
- Community discussions and best practices
- Package changelogs and migration guides

### Supabase MCP Server (Optional)

An official Supabase MCP server is available for direct project management:

```json
{
  "mcpServers": {
    "supabase": {
      "url": "https://mcp.supabase.com/mcp"
    }
  }
}
```

**Capabilities:**
- Design tables and generate migrations
- Run SQL queries directly
- Fetch project configuration
- Manage storage buckets
- View and debug RLS policies
- Generate TypeScript types from schema

**Recommendation for this project:**
- ✅ Use for **debugging** RLS policies and running ad-hoc queries
- ✅ Use for **exploring** schema during development
- ⚠️ Prefer **explicit SQL migration files** in `supabase/migrations/` for reproducibility
- ⚠️ Document any schema changes made via MCP in migration files

---

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp configuration
├── core/                        # Shared utilities & components
│   ├── constants/               # App-wide constants
│   ├── errors/                  # Failure/exception classes
│   ├── extensions/              # Dart extension methods
│   ├── theme/                   # Colors, typography, spacing
│   ├── utils/                   # GPS, validators, formatters
│   └── widgets/                 # Reusable component library
├── features/                    # Feature modules (vertical slices)
│   ├── auth/
│   ├── forays/
│   ├── observations/
│   ├── navigation/              # Compass navigation
│   ├── maps/
│   ├── sync/
│   └── settings/
├── database/                    # Drift database
│   ├── database.dart            # Main database class
│   ├── tables/                  # Table definitions
│   ├── daos/                    # Data access objects
│   └── migrations/
├── services/                    # Platform services
│   ├── api/
│   ├── location/
│   ├── compass/
│   ├── camera/
│   ├── connectivity/
│   └── storage/
└── routing/                     # GoRouter configuration
```

---

## Development Guidelines

### Code Style

1. **Use `const` constructors** wherever possible
2. **Prefer immutable data** - use `copyWith` patterns
3. **Follow existing patterns** - check similar files before creating new ones
4. **Riverpod for state** - use providers, not StatefulWidgets for complex state
5. **Feature folders** - keep related code together (data, domain, presentation)

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | snake_case | `foray_list_screen.dart` |
| Classes | PascalCase | `ForayListScreen` |
| Variables | camelCase | `currentUser` |
| Constants | camelCase | `maxPhotosPerObservation` |
| Providers | camelCase + Provider suffix | `forayListProvider` |
| Private members | _prefixed | `_isLoading` |

### Widget Guidelines

1. **Prefer composition** over inheritance
2. **Extract widgets** when they exceed ~100 lines
3. **Use `const` widgets** wherever possible
4. **Handle all states**: loading, error, empty, success
5. **Support dark mode** - test both themes

### Database Guidelines

1. **Always use DAOs** - never write raw queries outside DAOs
2. **Use transactions** for multi-table operations
3. **Add to sync queue** when creating/updating synced entities
4. **Use `Value()` wrapper** for nullable fields in Drift

### Testing Requirements

1. **Unit tests** for utilities, DAOs, and business logic
2. **Widget tests** for reusable components
3. **Integration tests** for critical flows (observation entry)
4. **Test offline behavior** - mock network failures

---

## Key Patterns

### Riverpod Provider Pattern

```dart
// Simple data provider
final forayProvider = FutureProvider.family<Foray?, String>((ref, id) async {
  final db = ref.watch(databaseProvider);
  return db.foraysDao.getForayById(id);
});

// Stream provider for reactive data
final foraysListProvider = StreamProvider<List<ForayWithRole>>((ref) {
  final db = ref.watch(databaseProvider);
  final user = ref.watch(authControllerProvider).user;
  if (user == null) return Stream.value([]);
  return db.foraysDao.watchForaysForUser(user.id);
});

// State notifier for complex state
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(supabaseAuthProvider), ref.watch(databaseProvider));
});
```

### Error Handling Pattern

```dart
// Use Result type pattern
Future<Result<Observation>> createObservation(ObservationData data) async {
  try {
    final observation = await _db.observationsDao.create(data);
    await _syncQueue.enqueue(observation.id);
    return Result.success(observation);
  } on DatabaseException catch (e) {
    return Result.failure(DatabaseFailure(e.message));
  } catch (e) {
    return Result.failure(UnexpectedFailure(e.toString()));
  }
}
```

### Offline-First Pattern

```dart
// Always save locally first
Future<void> saveObservation(Observation obs) async {
  // 1. Save to local database
  await _db.observationsDao.upsert(obs);
  
  // 2. Queue for sync (if authenticated)
  if (_auth.isAuthenticated) {
    await _db.syncDao.enqueue(
      entityType: 'observation',
      entityId: obs.id,
      operation: SyncOperation.create,
    );
  }
  
  // 3. Trigger background sync (if online)
  _syncProcessor.processQueueIfOnline();
}
```

---

## Important Files Reference

| Purpose | File |
|---------|------|
| App entry | `lib/main.dart` |
| Theme | `lib/core/theme/app_theme.dart` |
| Colors | `lib/core/theme/app_colors.dart` |
| Routes | `lib/routing/routes.dart` |
| Database | `lib/database/database.dart` |
| Auth controller | `lib/features/auth/presentation/controllers/auth_controller.dart` |
| Privacy levels | `lib/core/constants/privacy_levels.dart` |
| GPS utils | `lib/core/utils/gps_utils.dart` |

---

## Critical Constraints

### DO NOT:
- ❌ Suppress type errors with `as any` or `@ts-ignore` equivalents
- ❌ Commit sensitive data (API keys, credentials)
- ❌ Skip offline functionality - EVERYTHING must work offline
- ❌ Default to public privacy - always default to private
- ❌ Make network calls without handling failures
- ❌ Block the UI during sync operations

### ALWAYS:
- ✅ Test both light and dark themes
- ✅ Handle loading, error, and empty states
- ✅ Use `const` constructors where possible
- ✅ Add items to sync queue when modifying synced entities
- ✅ Respect foray lock state when adding IDs/comments
- ✅ Use proper Riverpod disposal

---

## Privacy Model

This is **critical** to understand:

| Level | Who Can See | When to Use |
|-------|-------------|-------------|
| `private` | Only creator | Personal secret spots, default |
| `foray` | Foray participants | Sharing within group event |
| `publicExact` | Everyone | Common species, public land |
| `publicObscured` | Everyone (±10km) | Citizen science, semi-sensitive |

**Rules:**
1. Default is always `private`
2. Users can increase privacy but not decrease below foray default
3. Private observations may skip cloud sync entirely

---

## Documentation Reference

| Document | Purpose |
|----------|---------|
| `OVERVIEW.md` | Full project vision and requirements |
| `WORK_PLAN.md` | Phased development plan with steps |
| `PROGRESS.md` | Current development progress tracking |
| `specs/*.md` | Detailed specifications per feature |

---

## Common Tasks

### Adding a New Feature

1. Check `WORK_PLAN.md` for the relevant phase
2. Read the corresponding spec in `specs/`
3. Follow existing patterns in similar features
4. Update `PROGRESS.md` as you complete steps
5. Write tests for critical functionality

### Adding a New Table

1. Create table definition in `lib/database/tables/`
2. Add to `@DriftDatabase` tables list in `database.dart`
3. Create DAO in `lib/database/daos/`
4. Add DAO to `@DriftDatabase` daos list
5. Run `dart run build_runner build`
6. Add mock data to `MockDataSeeder` if needed

### Adding a New Screen

1. Create screen in appropriate feature folder
2. Add route to `lib/routing/routes.dart`
3. Add route handler to `lib/routing/router.dart`
4. Handle all states (loading, error, empty, success)
5. Support both light and dark themes

### Debugging Sync Issues

1. Check `sync_queue` table for pending/failed items
2. Check network connectivity
3. Verify Supabase RLS policies allow the operation
4. Check for constraint violations in Supabase logs
5. Verify local-remote ID mapping

---

## Contact & Resources

### Official Documentation (Use Context7 MCP)
- **Flutter**: `flutter` - Framework APIs, widgets, Material Design
- **Riverpod**: `riverpod` - State management patterns
- **Drift**: `drift` - SQLite database, DAOs, queries
- **Supabase**: `supabase` - Auth, database, storage, realtime
- **GoRouter**: `go_router` - Navigation, deep linking
- **flutter_map**: `flutter_map` - Map widgets, markers, layers

### Web Resources
- **Flutter Docs**: https://docs.flutter.dev/
- **Riverpod Docs**: https://riverpod.dev/
- **Drift Docs**: https://drift.simonbinder.eu/
- **Supabase Docs**: https://supabase.com/docs
- **flutter_map Docs**: https://docs.fleaflet.dev/

### MCP Tools Quick Reference
| Need | Tool | Example Query |
|------|------|---------------|
| API signature | Context7 | "Riverpod ref.watch vs ref.read" |
| Real implementation | grep.app | `AsyncNotifier` in TypeScript files |
| Error troubleshooting | Exa | "Flutter Drift migration error" |
| Supabase debugging | Supabase MCP | Direct RLS policy inspection |

---

*This document should be updated as the project evolves.*
