# Foray Specifications Index

**Purpose:** This document is the entrypoint for all feature specifications. Use it to quickly find the right spec for any task.

---

## How to Use These Specs

### For Implementing Features

1. **Check WORK_PLAN.md first** — It breaks work into discrete steps, each referencing a specific spec section
2. **Read the referenced spec section** — Contains code snippets, data models, and implementation details
3. **Follow existing patterns** — Specs include example code matching project conventions
4. **Update PROGRESS.md** — Mark steps complete as you finish them

### For Understanding a Feature

1. **Use the Quick Lookup table below** — Find which spec covers your topic
2. **Read the spec's overview section** — Each spec starts with context and goals
3. **Check dependencies** — Some specs build on others

### Spec Conventions

Each spec follows this structure:

```
# Specification: [Feature Name]

**Phase:** N                    ← Matches WORK_PLAN phase number
**Estimated Duration:** X days  ← Planning reference
**Dependencies:** Phase N-1     ← What must be complete first

---

## 1. First Major Section       ← Referenced as "Section 1" in WORK_PLAN
### 1.1 Subsection
[Code snippets, models, implementation details]

## 2. Second Major Section      ← Referenced as "Section 2" in WORK_PLAN
...
```

**Code snippets** are ready-to-use — copy and adapt them. They follow project patterns (Riverpod, Drift, GoRouter).

---

## Spec Index

| Spec | Phase | Scope | Key Topics |
|------|-------|-------|------------|
| [01-foundation.md](01-foundation.md) | 1 | Project setup & design system | Theme, colors, typography, core widgets, constants, extensions |
| [02-database.md](02-database.md) | 2 | Local database | Drift tables, DAOs, relationships, mock data seeder |
| [03-auth.md](03-auth.md) | 3 | Authentication | Supabase auth, anonymous mode, registration, login, session management |
| [04-forays.md](04-forays.md) | 4 | Foray management | Create/join forays, participant management, foray states, sharing |
| [05-observations.md](05-observations.md) | 5 | Observation entry | Camera, GPS, observation form, species search, photo management |
| [06-collaboration.md](06-collaboration.md) | 6 | Collaboration features | Specimen lookup, ID voting, comments, real-time updates |
| [07-navigation.md](07-navigation.md) | 7 | Compass navigation | Compass service, bearing/distance, navigation UI, arrival detection |
| [08-maps.md](08-maps.md) | 8 | Map views | flutter_map setup, markers, clustering, foray/personal maps |
| [09-sync.md](09-sync.md) | 9 | Sync system | Supabase schema, RLS policies, photo upload, push/pull sync, conflicts |
| [10-web-demo.md](10-web-demo.md) | 11 | Web deployment | Web build, feature simulation, demo data, portfolio integration |

---

## Feature Quick Lookup

Use this table to find the right spec for any topic:

### UI & Design
| Topic | Spec | Section |
|-------|------|---------|
| Colors, themes, dark mode | 01-foundation | 2 |
| Typography, text styles | 01-foundation | 2 |
| Spacing, shadows | 01-foundation | 2 |
| ForayButton, ForayTextField | 01-foundation | 3 |
| ForayCard, badges, indicators | 01-foundation | 3 |
| Loading states, empty states | 01-foundation | 3 |
| Navigation structure (GoRouter) | 01-foundation | 4 |

### Database & Models
| Topic | Spec | Section |
|-------|------|---------|
| Drift setup, database class | 02-database | 1 |
| Users table & DAO | 02-database | 2 |
| Forays table & DAO | 02-database | 3 |
| Observations table & DAO | 02-database | 4 |
| Identifications, votes, comments tables | 02-database | 5 |
| Sync queue table | 02-database | 6 |
| Mock data seeding | 02-database | 7 |

### Authentication
| Topic | Spec | Section |
|-------|------|---------|
| Supabase project setup | 03-auth | 1 |
| Auth state management | 03-auth | 2 |
| Anonymous/local-only mode | 03-auth | 3 |
| Registration flow | 03-auth | 4 |
| Login flow | 03-auth | 5 |
| Route guards, auth UI | 03-auth | 6 |

### Forays
| Topic | Spec | Section |
|-------|------|---------|
| Foray list screen | 04-forays | 1 |
| Solo foray creation | 04-forays | 2 |
| Group foray creation | 04-forays | 3 |
| Join foray (code, QR, deep link) | 04-forays | 4 |
| Foray detail screen | 04-forays | 5 |
| Foray states (complete, lock, reopen) | 04-forays | 6 |
| Share foray (QR codes, PDF) | 04-forays | 7 |

### Observations
| Topic | Spec | Section |
|-------|------|---------|
| Camera capture, multi-photo | 05-observations | 1 |
| GPS capture, accuracy | 05-observations | 2 |
| Observation entry form | 05-observations | 3 |
| Species search/autocomplete | 05-observations | 4 |
| Specimen ID field (text + scan) | 05-observations | 5 |
| Save/draft persistence | 05-observations | 6 |
| Observation list view | 05-observations | 7 |
| Observation detail view | 05-observations | 8 |
| Observation editing | 05-observations | 9 |

### Collaboration
| Topic | Spec | Section |
|-------|------|---------|
| Specimen lookup (search + scan) | 06-collaboration | 1 |
| Add identification | 06-collaboration | 2 |
| ID voting system | 06-collaboration | 3 |
| ID deletion | 06-collaboration | 4 |
| Comment threads | 06-collaboration | 5 |
| Comment management | 06-collaboration | 6 |
| Real-time updates (Supabase) | 06-collaboration | 7 |

### Navigation & Maps
| Topic | Spec | Section |
|-------|------|---------|
| Compass service | 07-navigation | 1 |
| GPS utilities (Haversine, bearing) | 07-navigation | 2 |
| Compass rose widget | 07-navigation | 3 |
| Bearing indicator | 07-navigation | 4 |
| Distance display | 07-navigation | 5 |
| Navigation screen | 07-navigation | 6 |
| Arrival detection | 07-navigation | 7 |
| Edge cases (calibration, poor GPS) | 07-navigation | 8 |
| Map infrastructure (flutter_map) | 08-maps | 1 |
| Observation markers | 08-maps | 2 |
| Marker clustering | 08-maps | 3 |
| Foray map screen | 08-maps | 4 |
| Personal map screen | 08-maps | 5 |
| Map polish | 08-maps | 6 |

### Sync & Backend
| Topic | Spec | Section |
|-------|------|---------|
| Supabase schema (tables) | 09-sync | 1 |
| Row Level Security (RLS) | 09-sync | 1.2 |
| Photo upload | 09-sync | 2 |
| Observation push | 09-sync | 3 |
| Observation pull | 09-sync | 4 |
| Collaboration sync | 09-sync | 5 |
| Conflict resolution | 09-sync | 6 |
| Background sync | 09-sync | 7 |
| Sync status UI | 09-sync | 8 |

### Web Demo
| Topic | Spec | Section |
|-------|------|---------|
| Web build configuration | 10-web-demo | 1 |
| Feature simulation (camera, GPS) | 10-web-demo | 2 |
| Demo data | 10-web-demo | 3 |
| Portfolio integration | 10-web-demo | 4 |
| Demo polish | 10-web-demo | 5 |

---

## Dependency Order

Specs must be implemented in order due to dependencies:

```
┌─────────────────────────────────────────────────────────────────┐
│  01-foundation                                                   │
│  (Theme, widgets, navigation structure)                         │
└─────────────────────┬───────────────────────────────────────────┘
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│  02-database                                                     │
│  (Drift tables, DAOs - required by all features)                │
└─────────────────────┬───────────────────────────────────────────┘
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│  03-auth                                                         │
│  (Supabase auth - required for sync, collaboration)             │
└─────────────────────┬───────────────────────────────────────────┘
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│  04-forays                                                       │
│  (Foray management - container for observations)                │
└─────────────────────┬───────────────────────────────────────────┘
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│  05-observations                                                 │
│  (Core data entry - required by collaboration, maps, nav)       │
└───────────┬─────────────────────┬─────────────────┬─────────────┘
            ▼                     ▼                 ▼
┌───────────────────┐  ┌───────────────────┐  ┌───────────────────┐
│  06-collaboration │  │  07-navigation    │  │  08-maps          │
│  (IDs, voting,    │  │  (Compass nav to  │  │  (Map views of    │
│   comments)       │  │   observations)   │  │   observations)   │
└─────────┬─────────┘  └─────────┬─────────┘  └─────────┬─────────┘
          └──────────────────────┼──────────────────────┘
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│  09-sync                                                         │
│  (Cloud sync - requires all data features complete)             │
└─────────────────────┬───────────────────────────────────────────┘
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│  10-web-demo (Phase 11 in WORK_PLAN)                            │
│  (Web deployment - final polish)                                │
└─────────────────────────────────────────────────────────────────┘
```

**Note:** Phases 6, 7, and 8 can be implemented in parallel after Phase 5.

---

## Cross-References

Some features span multiple specs:

| Feature | Primary Spec | Also See |
|---------|--------------|----------|
| Privacy levels | 01-foundation (constants) | 02-database (table column), 05-observations (UI selector) |
| Sync status | 01-foundation (indicator widget) | 02-database (table column), 09-sync (processing) |
| GPS/Location | 05-observations (capture) | 07-navigation (tracking), 08-maps (display) |
| Specimen ID | 05-observations (field) | 06-collaboration (lookup/scan) |
| User model | 02-database (table) | 03-auth (state management) |
| Foray participants | 02-database (table) | 04-forays (management), 06-collaboration (permissions) |
| Photos | 02-database (table) | 05-observations (capture), 09-sync (upload) |

---

## When to Use What

| Task | Start Here |
|------|------------|
| "Implement step X.Y from WORK_PLAN" | WORK_PLAN.md → referenced spec section |
| "How does feature X work?" | This index → Quick Lookup table → spec |
| "What's left to do?" | PROGRESS.md |
| "What patterns should I follow?" | AGENTS.md → existing code in same feature |
| "What are the project requirements?" | OVERVIEW.md |
| "What are common pitfalls for X?" | `PATTERNS_AND_PITFALLS.md` → relevant section |
| "How do I avoid bugs with Drift/Supabase/etc?" | `PATTERNS_AND_PITFALLS.md` → tech-specific section |

---

## Related Documents

| Document | Purpose |
|----------|---------|
| `../PATTERNS_AND_PITFALLS.md` | Comprehensive patterns, gotchas, and best practices for the tech stack |
| `../AGENTS.md` | Quick reference for development guidelines (includes condensed gotchas) |

Each spec header includes a **Patterns & Pitfalls** line linking to relevant sections.

---

*This index should be updated when specs are added or significantly modified.*
