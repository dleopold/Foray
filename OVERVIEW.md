# Foray
## A Mobile App for Mycological Field Collection

**Document Version:** 2.0  
**Purpose:** Foundational architecture document for AI coding agents to generate detailed specifications

---

## 1. Project Vision

### 1.1 Overview
Foray is a cross-platform mobile application for documenting fungal collections in the field. Whether organizing a mycological society outing with dozens of participants or building a personal collection map over years of solo foraging, Foray provides a beautiful, offline-first experience for recording, organizing, and returning to productive collection sites.

### 1.2 Core Value Propositions

**For Mycological Societies**
> Organize your forays effortlessly. Create a session, share the link, and every participant's collections flow into one place—photos, locations, IDs, all synchronized.

**For Foraging Groups**  
> Heading out with friends? Start a foray and everyone's finds appear on the same map. No more "where did you see that chicken of the woods?"

**For Solo Collectors**
> Build your personal mushroom map over years. Tag your productive spots, track fruiting seasons, and navigate back to that perfect chanterelle patch with in-app compass navigation.

### 1.3 Strategic Goals
- **Showcase Quality:** This app serves as a portfolio demonstration piece. UI/UX must be polished, modern, and delightful—not merely functional.
- **Privacy-First:** Collection locations are sensitive data. All location sharing is opt-in, with granular controls. Users trust Foray with their secret spots.
- **Offline-First:** Full functionality without network connectivity is a core requirement. Forays happen in forests without cell service.
- **Web Demo Capability:** The app must deploy to web for portfolio demonstration, allowing prospective clients to experience the UI directly in-browser.

### 1.4 Target Users
- Mycological society members and foray organizers
- Amateur mycologists and mushroom foragers
- Citizen scientists contributing to fungal biodiversity records
- Professional mycologists conducting field surveys

### 1.5 Name & Concept
**Foray** (noun): An organized group excursion to collect and study fungi in their natural habitat.

The "foray" becomes the universal organizing unit in the app—a container for observations that scales from a solo walk to a society event with 100 participants.

---

## 2. Technical Stack

### 2.1 Mobile Framework: Flutter
**Rationale:** Flutter provides superior control over UI/UX polish, consistent cross-platform rendering, excellent offline database options, and—critically—first-party web compilation for portfolio demos.

**Language:** Dart

**Target Platforms:**
- iOS (primary)
- Android (primary)
- Web (demo/portfolio deployment)

### 2.2 Web Demo Deployment
Flutter's web target enables a live, interactive demo embedded in a portfolio site:
- Compile with `flutter build web`
- Deploy to static hosting (Vercel, Netlify, GitHub Pages, or S3/CloudFront)
- Embed in a phone-frame mockup via CSS/iframe
- Mobile-specific features (camera, GPS) gracefully degrade to mock data or placeholder flows

**Demo Considerations:**
- Initial bundle size ~2-3MB (acceptable for portfolio context)
- Use mock/seeded data to demonstrate full UI flows
- Compass navigation can use simulated location data on web

### 2.3 State Management
**Primary:** Riverpod 2.x  
**Rationale:** Type-safe, testable, supports code generation, handles async state elegantly.

### 2.4 Local Database
**Primary:** Drift (formerly Moor)  
**Rationale:** Type-safe SQLite wrapper with excellent migration support, reactive queries, and complex relational query capability needed for sync and offline operation.

### 2.5 Backend Services (Supabase)
| Service | Purpose |
|---------|---------|
| Supabase Auth | User authentication (email, Google, Apple) |
| Supabase PostgreSQL | Primary relational data store |
| Supabase Storage | Photo storage (S3-compatible) |
| Supabase Realtime | Live updates for collaborative forays |

**Rationale:** Supabase provides a unified backend with PostgreSQL (ideal for relational data model), built-in auth, storage, and real-time subscriptions. Simpler than managing multiple AWS services, with a generous free tier suitable for portfolio/early usage.

**Note:** For the demo version, the backend can be mocked entirely, with all data persisted locally. The architecture supports seamless transition to production.

### 2.6 Key Flutter Packages
| Feature | Package | Purpose |
|---------|---------|---------|
| GPS Location | `geolocator` | Current position, distance calculations |
| Compass | `flutter_compass` | Heading for navigation feature |
| Camera | `camera` / `image_picker` | Photo capture |
| Local Database | `drift` | SQLite with type safety |
| State Management | `flutter_riverpod` | Reactive state |
| Navigation | `go_router` | Declarative routing |
| Maps | `flutter_map` + `latlong2` | Map display (offline-capable) |
| Secure Storage | `flutter_secure_storage` | Auth tokens, sensitive data |

---

## 3. Privacy & Security Model

### 3.1 Design Principles
**Privacy by Default:** All collection locations are private until explicitly shared. Users must opt-in to any form of location sharing.

**Granular Control:** Users choose sharing level per-observation, not globally.

**Trust Architecture:** Users are trusting Foray with the locations of valuable foraging sites (morels, chanterelles, matsutake). This trust must be earned through transparent, conservative privacy defaults.

### 3.2 Observation Privacy Levels

| Level | Icon | Behavior |
|-------|------|----------|
| **Private** | 🔒 | Only visible to the creator. Exact GPS stored locally; if synced to cloud, encrypted at rest. Not shared with foray participants. |
| **Foray-Shared** | 👥 | Visible to participants of the same foray. Exact location shown on shared foray map. |
| **Public** | 🌍 | Visible to all users. Suitable for citizen science contribution, common species, or non-sensitive locations. |
| **Obscured Public** | 🌐 | Public with coordinates randomized within ~10km radius. For users who want to contribute to science without revealing exact spots. |

**Default:** Private (🔒)

### 3.3 Foray Privacy Settings

When creating a foray, the organizer sets a default observation privacy for participants:
- **Private by default** — participants must explicitly share each find
- **Foray-shared by default** — finds visible to group, but not public
- **Public by default** — for citizen science events contributing to GBIF/iNaturalist

Participants can always increase privacy (make something more private) but cannot decrease it below the foray default.

### 3.4 Data Security

| Data Type | Storage | Encryption |
|-----------|---------|------------|
| Auth tokens | `flutter_secure_storage` | Device keychain |
| Private observation GPS | Local SQLite | At-rest encryption via SQLCipher (optional enhancement) |
| Photos | Local filesystem → S3 | TLS in transit, S3 server-side encryption |
| Foray join codes | Ephemeral | Time-limited, single-use option available |

### 3.5 Privacy UI Principles
- Privacy level selector is prominent in observation entry flow, not buried
- Visual indicators (icons, colors) make current privacy state glanceable
- "Who can see this?" summary shown before saving
- Batch privacy controls for existing observations

---

## 4. Core Features

### 4.1 Foray Management

| Feature | Description | Priority |
|---------|-------------|----------|
| Create foray | Name, date, location description, default privacy | P0 |
| Solo foray | Quick-create personal foray (implicit, no sharing) | P0 |
| Join foray | Via link, QR code, or 6-character code | P0 |
| Foray list | User's forays (organized/participated/personal) | P0 |
| Foray settings | Edit name, privacy defaults, participant management | P1 |
| Close foray | Organizer marks foray complete, locks new joins | P1 |
| Foray templates | Save settings for recurring society events | P2 |

### 4.2 Observation Entry (Collection Logging)

| Feature | Description | Priority |
|---------|-------------|----------|
| Quick capture | Minimal-tap flow: photo → auto-GPS → save draft | P0 |
| Multi-photo | Multiple angles per specimen (cap, gills, stipe, context) | P0 |
| GPS capture | Automatic with accuracy indicator | P0 |
| Privacy selector | Prominent control, defaults per foray settings | P0 |
| Substrate/habitat | Picker for common substrates (hardwood, conifer, soil, dung, etc.) | P0 |
| Field notes | Free-text for colors, odor, texture, reactions | P0 |
| Preliminary ID | User's best guess, searchable species list | P1 |
| Spore print color | Common colors picker or free entry | P1 |
| Collection number | Auto-increment or manual entry | P1 |
| Voice notes | Audio attachment for hands-free field notes | P2 |

### 4.3 In-App Compass Navigation

**Purpose:** Enable users to navigate back to previous collection sites using only the device's sensors—no cell service required.

| Feature | Description | Priority |
|---------|-------------|----------|
| Navigate to observation | Tap any past observation → compass navigation view | P0 |
| Compass display | Large, animated compass rose showing bearing to target | P0 |
| Distance readout | Distance to target in user's preferred units (m/km or ft/mi) | P0 |
| Bearing indicator | Arrow or highlight showing direction to travel | P0 |
| Arrival detection | Visual/haptic feedback when within ~10m of target | P1 |
| Breadcrumb trail | Optional: record path taken, display on map | P2 |
| Offline operation | Full functionality without network | P0 |

**UI/UX Goals for Compass Navigation:**
- Feel like a premium handheld GPS or geocaching app
- Smooth, fluid animations (compass rotation, distance countdown)
- High contrast, readable in bright sunlight
- Large touch targets for gloved hands
- Subtle haptic feedback on heading lock and arrival
- Graceful handling of compass calibration prompts

**Technical Notes:**
- Use `flutter_compass` for magnetometer heading
- Use `geolocator` for current position and Haversine distance calculation
- Update rate: compass at 60fps, GPS at 1Hz (battery consideration)
- Handle magnetic declination for accuracy (optional enhancement)

### 4.4 Maps & Spatial Features

| Feature | Description | Priority |
|---------|-------------|----------|
| Foray map | All observations from a foray plotted | P0 |
| Personal map | All user's observations across all forays | P0 |
| Observation clustering | Cluster nearby pins at low zoom | P1 |
| Filter by date/species | Show observations from specific time ranges or taxa | P1 |
| Offline map tiles | Cache tiles for areas user frequents | P2 |
| Heatmap view | Density visualization of collection history | P2 |

### 4.5 Offline Functionality

| Feature | Description | Priority |
|---------|-------------|----------|
| Full offline operation | All features work without network | P0 |
| Local-first storage | Observations saved locally immediately | P0 |
| Sync queue | Pending changes tracked for upload | P0 |
| Sync status indicators | Clear UI showing pending/synced/failed per item | P0 |
| Background sync | Sync when connectivity restored | P1 |
| Conflict resolution | Last-write-wins with timestamp; flag conflicts for review | P1 |
| Bandwidth awareness | Defer photo upload on metered connections (optional) | P2 |

### 4.6 Foray Collaboration

| Feature | Description | Priority |
|---------|-------------|----------|
| Participant list | See who's in the foray | P0 |
| Live feed | Stream of observations from all participants | P0 |
| Observation attribution | Each observation shows collector name/avatar | P0 |
| Species tally | Running count of species observed | P1 |
| Expert ID workflow | Designated identifiers can add/edit IDs | P2 |
| Foray chat | In-app messaging for participants | P3 |

### 4.7 Data Export & Integration

| Feature | Description | Priority |
|---------|-------------|----------|
| Foray report | Summary with species list, stats, participant contributions | P1 |
| CSV export | Tabular data export | P1 |
| Photo export | Bulk download of observation photos | P2 |
| iNaturalist push | Export observations (respecting privacy settings) | P2 |
| GBIF formatting | Darwin Core compatible export | P3 |

---

## 5. Data Architecture

### 5.1 Conceptual Model

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  User                                                                   │
│    │                                                                    │
│    ├──creates──▶ Foray ◀──joins── Other Users                          │
│    │              │                                                     │
│    │              ├── has settings (default privacy, status, etc.)     │
│    │              │                                                     │
│    └──records──▶ Observation                                           │
│                   │                                                     │
│                   ├── belongs to one Foray                             │
│                   ├── has one Location (with privacy level)            │
│                   ├── has many Photos                                   │
│                   ├── has many Identifications (preliminary → expert)  │
│                   └── has Metadata (substrate, notes, spore print)     │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Local Database Schema (Drift/SQLite)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          LOCAL DATABASE                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────┐          ┌─────────────────────────────────────┐ │
│  │      users       │          │              forays                 │ │
│  ├──────────────────┤          ├─────────────────────────────────────┤ │
│  │ id (PK, UUID)    │          │ id (PK, UUID)                       │ │
│  │ remote_id        │──────┐   │ creator_id (FK → users)             │ │
│  │ display_name     │      │   │ name                                │ │
│  │ email            │      │   │ description                         │ │
│  │ avatar_url       │      │   │ date                                │ │
│  │ created_at       │      │   │ location_name                       │ │
│  │ updated_at       │      │   │ default_privacy (enum)              │ │
│  └──────────────────┘      │   │ join_code                           │ │
│                            │   │ status (active/closed)              │ │
│  ┌──────────────────┐      │   │ is_solo (bool)                      │ │
│  │ foray_participants│      │   │ created_at                          │ │
│  ├──────────────────┤      │   │ updated_at                          │ │
│  │ foray_id (FK)    │◀─────┼───│ sync_status                         │ │
│  │ user_id (FK)     │◀─────┘   └─────────────────────────────────────┘ │
│  │ role (organizer/ │                          │                       │
│  │      participant)│                          │                       │
│  │ joined_at        │                          │                       │
│  └──────────────────┘                          │                       │
│                                                │                       │
│  ┌─────────────────────────────────────────────┼─────────────────────┐ │
│  │                    observations             │                     │ │
│  ├─────────────────────────────────────────────┴─────────────────────┤ │
│  │ id (PK, UUID)                                                     │ │
│  │ foray_id (FK → forays)                                            │ │
│  │ collector_id (FK → users)                                         │ │
│  │ latitude (REAL)                                                   │ │
│  │ longitude (REAL)                                                  │ │
│  │ gps_accuracy (REAL, meters)                                       │ │
│  │ altitude (REAL, optional)                                         │ │
│  │ privacy_level (enum: private/foray/public/obscured)               │ │
│  │ observed_at (DATETIME)                                            │ │
│  │ collection_number (TEXT, optional)                                │ │
│  │ substrate (TEXT)                                                  │ │
│  │ habitat_notes (TEXT)                                              │ │
│  │ field_notes (TEXT)                                                │ │
│  │ spore_print_color (TEXT)                                          │ │
│  │ preliminary_id (TEXT, species name)                               │ │
│  │ preliminary_id_confidence (enum: guess/likely/confident)          │ │
│  │ is_draft (BOOL)                                                   │ │
│  │ created_at (DATETIME)                                             │ │
│  │ updated_at (DATETIME)                                             │ │
│  │ sync_status (enum: local/pending/synced/failed)                   │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                              │                                         │
│         ┌────────────────────┼────────────────────┐                    │
│         ▼                    ▼                    ▼                    │
│  ┌─────────────┐    ┌───────────────┐    ┌────────────────┐           │
│  │   photos    │    │identifications│    │   sync_queue   │           │
│  ├─────────────┤    ├───────────────┤    ├────────────────┤           │
│  │ id (PK,UUID)│    │ id (PK, UUID) │    │ id (PK)        │           │
│  │ obs_id (FK) │    │ obs_id (FK)   │    │ entity_type    │           │
│  │ local_path  │    │ identifier_id │    │ entity_id      │           │
│  │ remote_url  │    │ species_name  │    │ operation      │           │
│  │ sort_order  │    │ confidence    │    │ payload (JSON) │           │
│  │ caption     │    │ notes         │    │ retry_count    │           │
│  │ upload_status│   │ created_at    │    │ last_attempt   │           │
│  │ created_at  │    │ is_expert     │    │ status         │           │
│  └─────────────┘    └───────────────┘    └────────────────┘           │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 5.3 Privacy Level Enum
```dart
enum PrivacyLevel {
  private,      // Only creator can see
  foray,        // Visible to foray participants
  public_exact, // Visible to all, exact coordinates
  public_obscured, // Visible to all, coordinates randomized ~10km
}
```

### 5.4 Sync Strategy
1. **Observation created** → Assign local UUID, store locally, add to sync_queue
2. **User submits** → Mark as non-draft, trigger sync if online
3. **Sync process:**
   - Upload photos to S3 first (get URLs)
   - POST observation with photo URLs
   - On success: update sync_status, store server timestamps
   - On failure: increment retry_count, exponential backoff
4. **Privacy enforcement:** Private observations either skip cloud sync entirely OR are encrypted client-side before upload (configurable)

---

## 6. User Experience Design

### 6.1 Design Philosophy
- **Field-Ready:** Large touch targets (min 48dp), high contrast, readable in bright sunlight, usable with gloves
- **Privacy-Confident:** Users always know who can see their data; privacy controls are prominent, not hidden
- **Delightful Navigation:** The compass feature should feel magical—smooth animations, satisfying arrival feedback
- **Progressive Disclosure:** Simple default flow for quick capture; advanced options available but not overwhelming
- **Offline-Transparent:** Never make users wonder "did it save?" — clear, immediate feedback on local save and sync status

### 6.2 Visual Language
- **Style:** Modern, nature-inspired, earthy color palette with fungi-derived accent colors
- **Typography:** Clear hierarchy, excellent legibility in outdoor lighting conditions
- **Iconography:** Custom icon set with mycological motifs (cap shapes, spore prints, mycelium)
- **Motion:** Purposeful animations—compass rotation, sync status transitions, navigation arrival celebration

### 6.3 Key Screens

| Screen | Purpose | Key Interactions |
|--------|---------|------------------|
| **Home / Foray List** | Primary hub showing active and past forays | Quick-start solo foray FAB, join foray button |
| **Create Foray** | Set up new foray with privacy defaults | Name, date, privacy level selector |
| **Join Foray** | Enter code or scan QR to join | Code input, camera for QR |
| **Foray Detail** | View foray observations, participants, map | Tab bar: Feed / Map / Stats / Settings |
| **Observation Entry** | Log a new collection | Photo capture → GPS confirm → Details → Privacy → Save |
| **Camera Capture** | Multi-photo capture flow | Viewfinder, capture, thumbnail strip, done |
| **Observation Detail** | View/edit single observation | Photo gallery, editable fields, navigate button |
| **Compass Navigation** | Navigate to observation location | Full-screen compass, distance, bearing |
| **Personal Map** | All user's observations across time | Clustered pins, filter controls, tap to detail |
| **Profile / Settings** | Account, preferences, privacy defaults | Theme, units, default privacy, export |

### 6.4 Compass Navigation UX (Detailed)

This is a hero feature for demonstrating UI/UX excellence.

**Visual Design:**
```
┌─────────────────────────────────────┐
│                                     │
│           ← Back    Navigate        │
│                                     │
│    ┌─────────────────────────────┐  │
│    │                             │  │
│    │           N                 │  │
│    │                             │  │
│    │      W    ◉    E           │  │
│    │           ▲                 │  │
│    │           │                 │  │
│    │           S                 │  │
│    │                             │  │
│    └─────────────────────────────┘  │
│                                     │
│              0.3 mi                 │
│           NW (315°)                 │
│                                     │
│    ┌─────────────────────────────┐  │
│    │  🍄 Chanterelle sp.         │  │
│    │  Collected Oct 15, 2024     │  │
│    └─────────────────────────────┘  │
│                                     │
│         [ Open in Maps ]            │
│                                     │
└─────────────────────────────────────┘
```

**Behaviors:**
- Compass rotates smoothly as device orientation changes (60fps)
- Target indicator (▲) shows direction to travel relative to current heading
- Distance updates every 1-2 seconds as user moves
- Subtle pulse animation on distance when getting closer
- Haptic tap when user is aligned with correct bearing
- Celebratory animation + strong haptic when within arrival threshold (~10m)
- "Open in Maps" button for users who want turn-by-turn directions to trailhead

**Edge Cases:**
- Compass calibration needed: show calibration prompt with figure-8 animation
- GPS accuracy poor: show warning, display accuracy radius
- Target very close (<20m): switch to "You're here!" arrival mode
- Target very far (>50km): suggest "Open in Maps" for driving directions

### 6.5 Component Library (Build First)

These reusable components establish the design system:

**Core Components:**
- `ForayButton` — Primary, secondary, text variants with loading state
- `ForayTextField` — With validation states, helper text, character count
- `ForayCard` — Elevation variants, touch feedback
- `PrivacyBadge` — Visual indicator for privacy levels (🔒👥🌍)
- `SyncStatusIndicator` — Icon + optional text for sync states
- `GPSAccuracyIndicator` — Visual representation of location precision

**Feature Components:**
- `CompassRose` — Animated compass with customizable style
- `BearingIndicator` — Arrow showing direction to target
- `DistanceDisplay` — Animated distance readout with units
- `PhotoThumbnailStrip` — Horizontal scrolling photo row with add button
- `ObservationListTile` — Standardized list item with photo, species, date, privacy
- `ForayMapView` — Configured flutter_map with clustering
- `EmptyState` — Illustrated placeholders for empty lists

**Feedback Components:**
- `ForaySnackbar` — Success, error, info variants
- `LoadingShimmer` — Skeleton loading placeholders
- `PullToRefresh` — Styled refresh indicator
- `ArrivalCelebration` — Full-screen celebration for navigation arrival

---

## 7. Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp configuration
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── privacy_levels.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── extensions/
│   │   ├── context_extensions.dart
│   │   └── datetime_extensions.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_shadows.dart
│   ├── utils/
│   │   ├── gps_utils.dart       # Haversine, bearing calculations
│   │   ├── validators.dart
│   │   └── formatters.dart
│   └── widgets/                 # Shared component library
│       ├── buttons/
│       ├── inputs/
│       ├── cards/
│       ├── indicators/
│       ├── compass/
│       └── feedback/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── auth_local_source.dart
│   │   ├── domain/
│   │   │   ├── user_model.dart
│   │   │   └── auth_state.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── controllers/
│   │
│   ├── forays/
│   │   ├── data/
│   │   │   ├── foray_repository.dart
│   │   │   └── foray_local_source.dart
│   │   ├── domain/
│   │   │   ├── foray_model.dart
│   │   │   └── participant_model.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── foray_list_screen.dart
│   │       │   ├── foray_detail_screen.dart
│   │       │   ├── create_foray_screen.dart
│   │       │   └── join_foray_screen.dart
│   │       ├── widgets/
│   │       └── controllers/
│   │
│   ├── observations/
│   │   ├── data/
│   │   │   ├── observation_repository.dart
│   │   │   └── observation_local_source.dart
│   │   ├── domain/
│   │   │   ├── observation_model.dart
│   │   │   ├── photo_model.dart
│   │   │   └── identification_model.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── observation_entry_screen.dart
│   │       │   ├── observation_detail_screen.dart
│   │       │   └── camera_capture_screen.dart
│   │       ├── widgets/
│   │       └── controllers/
│   │
│   ├── navigation/              # Compass navigation feature
│   │   ├── data/
│   │   │   └── compass_service.dart
│   │   ├── domain/
│   │   │   └── navigation_state.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── compass_navigation_screen.dart
│   │       ├── widgets/
│   │       │   ├── compass_rose.dart
│   │       │   ├── bearing_indicator.dart
│   │       │   ├── distance_display.dart
│   │       │   └── arrival_celebration.dart
│   │       └── controllers/
│   │           └── navigation_controller.dart
│   │
│   ├── maps/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── foray_map_screen.dart
│   │       │   └── personal_map_screen.dart
│   │       └── widgets/
│   │           ├── observation_marker.dart
│   │           └── cluster_marker.dart
│   │
│   ├── sync/
│   │   ├── data/
│   │   │   ├── sync_repository.dart
│   │   │   └── sync_queue_processor.dart
│   │   ├── domain/
│   │   │   └── sync_status.dart
│   │   └── presentation/
│   │       └── widgets/
│   │           └── sync_status_banner.dart
│   │
│   └── settings/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── database/                    # Drift database
│   ├── database.dart            # Database class
│   ├── tables/
│   │   ├── users_table.dart
│   │   ├── forays_table.dart
│   │   ├── observations_table.dart
│   │   ├── photos_table.dart
│   │   └── sync_queue_table.dart
│   ├── daos/
│   │   ├── forays_dao.dart
│   │   ├── observations_dao.dart
│   │   └── sync_dao.dart
│   └── migrations/
│
├── services/
│   ├── api/
│   │   └── api_client.dart
│   ├── location/
│   │   └── location_service.dart
│   ├── compass/
│   │   └── compass_service.dart
│   ├── camera/
│   │   └── camera_service.dart
│   ├── connectivity/
│   │   └── connectivity_service.dart
│   └── storage/
│       └── secure_storage_service.dart
│
└── routing/
    ├── router.dart              # GoRouter configuration
    └── routes.dart              # Route definitions
```

---

## 8. Development Phases

### Phase 1: Foundation & Design System (Weeks 1-2)
- [ ] Project setup, dependencies, linting, CI
- [ ] Theme system (colors, typography, shadows)
- [ ] Component library: buttons, inputs, cards, indicators
- [ ] Drift database setup with all tables
- [ ] Navigation structure (GoRouter)
- [ ] Mock data seeding for development

### Phase 2: Foray Management (Weeks 3-4)
- [ ] Foray list screen (home)
- [ ] Create foray flow with privacy settings
- [ ] Join foray (code entry, QR scan)
- [ ] Foray detail screen (tabs: Feed, Map, Stats)
- [ ] Solo foray quick-start

### Phase 3: Observation Entry (Weeks 5-6)
- [ ] Camera capture flow (multi-photo)
- [ ] GPS capture with accuracy indicator
- [ ] Observation entry form
- [ ] Privacy selector (prominent placement)
- [ ] Draft save / submission flow
- [ ] Observation list and detail views

### Phase 4: Compass Navigation (Weeks 7-8)
- [ ] Compass service integration
- [ ] Compass rose component (animated)
- [ ] Bearing/distance calculations
- [ ] Navigation screen with full UX
- [ ] Arrival detection and celebration
- [ ] Edge case handling (calibration, poor GPS)

### Phase 5: Maps & Polish (Weeks 9-10)
- [ ] Foray map view with clustering
- [ ] Personal observation map
- [ ] Filter/search on maps
- [ ] Dark mode
- [ ] Animation polish
- [ ] Empty states and loading skeletons

### Phase 6: Web Demo & Launch (Weeks 11-12)
- [ ] Flutter web build optimization
- [ ] Mock data for web demo
- [ ] Graceful degradation for camera/GPS on web
- [ ] Portfolio landing page with embedded demo
- [ ] Phone frame mockup styling
- [ ] Documentation and README

---

## 9. Quality Requirements

### 9.1 Performance Targets
- Cold start: < 2 seconds (mobile), < 4 seconds (web, first load)
- Observation save (local): < 100ms perceived
- Compass update: 60fps smooth rotation
- List scroll: 60fps consistent
- Database queries: < 50ms

### 9.2 Reliability Targets
- Zero data loss (local observations must never be lost)
- Graceful degradation on network failure
- Crash-free rate: > 99.5%
- Compass functions without network

### 9.3 Privacy Targets
- No location data transmitted without explicit user consent
- Private observations never leave device (or are encrypted if synced)
- Clear audit trail of what has been shared

### 9.4 Testing Requirements
- Unit tests for business logic, especially privacy rules (>80% coverage)
- Widget tests for component library
- Integration tests for observation entry flow
- Golden tests for key UI components
- Manual QA checklist with privacy verification

---

## 10. Open Questions for Specification Phase

1. **Species Database:** Include offline species lookup? Which taxonomy source (Index Fungorum, MycoBank, iNaturalist taxa)?
2. **Account Requirement:** Can users create observations without an account? (Device ID only until they want to sync/share)
3. **Photo Storage Limits:** Max photos per observation? Max resolution/file size?
4. **Foray Duration:** Auto-close forays after N days? Organizer-only close?
5. **Offline Maps:** Include downloadable offline map tiles? Which provider?
6. **Expert ID Workflow:** How are experts designated? Per-foray or global?
7. **Data Export Formats:** Which formats beyond CSV? Darwin Core / GBIF-ready?
8. **Monetization (Future):** Free tier limits? Society/organization accounts?

---

## 11. Demo Considerations

### 11.1 Web Demo Scope
The portfolio web demo should showcase:
- Full navigation and screen flows
- Component library and design system
- Compass navigation with simulated location
- Map views with pre-seeded observations
- Privacy controls and indicators
- Offline-first architecture (show sync status UI)

### 11.2 Mock Data for Demo
Pre-seed with realistic data:
- 2-3 sample forays (one society event, one small group, one solo)
- 30-50 observations with varied species, photos, locations
- Multiple users with avatars
- Mix of privacy levels demonstrated
- Some observations marked for sync, others synced

### 11.3 Simulated Features on Web
| Feature | Mobile | Web Demo |
|---------|--------|----------|
| Camera | Real camera | File picker or sample images |
| GPS | Real location | Simulated coordinates |
| Compass | Real magnetometer | Simulated heading (animated) |
| Offline | SQLite | IndexedDB via Drift web |
| Push notifications | Real | N/A |

### 11.4 Portfolio Integration
- Landing page explaining Foray concept
- Device frame (iPhone 15 Pro mockup) containing iframe with Flutter web app
- Call-to-action buttons (even if placeholder) for app stores
- Link to GitHub repo (if open-sourcing)
- Technical write-up of architecture decisions

---

## 12. References & Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Web Support](https://docs.flutter.dev/platform-integration/web)
- [Riverpod Documentation](https://riverpod.dev/)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [flutter_compass Package](https://pub.dev/packages/flutter_compass)
- [geolocator Package](https://pub.dev/packages/geolocator)
- [flutter_map Package](https://pub.dev/packages/flutter_map)

### Design Inspiration
- Merlin Bird ID (excellent field UX)
- AllTrails (offline navigation, trail tracking)
- Komoot (compass/navigation feel)
- iNaturalist (data model, but not UX)
- Mushroom Observer (domain expertise)

### Mycological Resources
- [Index Fungorum](http://www.indexfungorum.org/)
- [MycoBank](https://www.mycobank.org/)
- [Mushroom Observer](https://mushroomobserver.org/)
- North American Mycological Association (NAMA) foray guidelines

---

## Appendix A: Glossary

| Term | Definition |
|------|------------|
| **Foray** | An organized excursion to collect and study fungi; the primary organizing unit in the app |
| **Observation** | A single collection event: one fungal specimen with photos, location, and metadata |
| **Collection Number** | A sequential identifier assigned by the collector for reference |
| **Substrate** | The material on which the fungus is growing (soil, hardwood, conifer, dung, etc.) |
| **Spore Print** | The color of spores deposited on paper/foil; key identification feature |
| **Preliminary ID** | The collector's initial species identification, subject to expert review |
| **Privacy Level** | Controls who can see an observation's location data |
| **Bearing** | The compass direction from current location to a target |
| **Haversine** | Formula for calculating great-circle distance between GPS coordinates |

---

## Appendix B: Substrate Picker Options

Standard substrate options for the observation entry form:

**Wood Substrates:**
- Hardwood (standing dead)
- Hardwood (fallen log)
- Hardwood (stump)
- Hardwood (buried wood)
- Conifer (standing dead)
- Conifer (fallen log)
- Conifer (stump)
- Conifer (buried wood)
- Wood chips/mulch

**Ground Substrates:**
- Soil (forest floor)
- Soil (grassland)
- Soil (disturbed)
- Leaf litter
- Moss
- Sandy soil

**Other Substrates:**
- Dung (herbivore)
- Dung (carnivore)
- Other fungi (mycoparasite)
- Living tree (parasitic)
- Fire site (pyrophilic)
- Other (specify in notes)

---

## Appendix C: Spore Print Color Options

Standard spore print colors for quick selection:

- White / Cream
- Yellow / Buff
- Pink / Salmon
- Ochre / Tan
- Brown (light)
- Brown (dark)
- Rusty brown / Cinnamon
- Purple-brown
- Black
- Other (specify in notes)
- Not taken

---

*This document provides the architectural foundation for Foray. AI coding agents should generate detailed specifications for each feature module, API contracts, database migrations, component designs, and screen-by-screen interaction specs based on this overview.*
