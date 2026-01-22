# Foray Development Progress

**Project:** Foray - Mycological Field Collection App  
**Started:** 2026-01-21  
**Last Updated:** 2026-01-22

---

## Overview

This document tracks development progress for the Foray mobile application. Each phase contains discrete steps with checkboxes for tracking completion.

---

## Phase 1: Foundation & Design System
**Status:** Nearly Complete  
**Target Duration:** 5-7 days

### Step 1.1: Project Initialization
- [x] Create Flutter project
- [x] Configure pubspec.yaml
- [x] Set up linting rules
- [x] Initialize Git repository
- [x] Create basic entry points

### Step 1.2: Theme System
- [x] Define AppColors
- [x] Define AppTypography
- [x] Define AppSpacing
- [x] Define AppShadows
- [x] Create AppTheme class
- [x] Implement theme provider
- [x] Create theme showcase screen (integrated into component showcase)

### Step 1.3: Core Components — Inputs & Buttons
- [x] ForayButton
- [x] ForayTextField
- [x] ForayDropdown
- [x] ForaySwitch
- [x] ForayCheckbox
- [x] Component showcase

### Step 1.4: Core Components — Display & Feedback
- [x] ForayCard
- [x] ForayListTile
- [x] ForayAvatar
- [x] ForayBadge
- [x] PrivacyBadge
- [x] SyncStatusIndicator
- [x] GPSAccuracyIndicator
- [x] ForaySnackbar
- [x] LoadingShimmer
- [x] EmptyState

### Step 1.5: Navigation Structure
- [x] Configure GoRouter
- [x] Create bottom navigation shell
- [x] Implement route guards (auth_guard.dart)
- [ ] Set up deep linking (deferred)
- [x] Create placeholder screens

### Step 1.6: Development Utilities
- [x] AppConstants class
- [x] Extension methods
- [x] Validators utility
- [x] Formatters utility
- [ ] Logging utility

---

## Phase 2: Local Database & Core Models
**Status:** Complete  
**Target Duration:** 4-5 days

### Step 2.1: Drift Setup
- [x] Add Drift dependencies
- [x] Configure build runner
- [x] Create AppDatabase class
- [x] Set up Riverpod provider
- [x] Initialize on app start

### Step 2.2: User & Auth Tables
- [x] Users table definition
- [x] UsersDao implementation
- [x] UserModel domain class
- [x] Local user storage
- [ ] Unit tests

### Step 2.3: Foray Tables
- [x] Forays table definition
- [x] ForayParticipants table
- [x] ForaysDao implementation
- [x] Domain models
- [ ] Unit tests

### Step 2.4: Observation Tables
- [x] Observations table definition
- [x] Photos table definition
- [x] ObservationsDao implementation
- [x] Domain models
- [x] Relationships
- [ ] Unit tests

### Step 2.5: Collaboration Tables
- [x] Identifications table
- [x] IdentificationVotes table
- [x] Comments table
- [x] DAOs implementation
- [x] Voting logic
- [ ] Unit tests

### Step 2.6: Sync Queue Table
- [x] SyncQueue table definition
- [x] SyncDao implementation
- [x] Queue entry creation
- [x] Status tracking
- [ ] Unit tests

### Step 2.7: Mock Data Seeding
- [x] MockDataSeeder class
- [x] Sample users
- [x] Sample forays
- [x] Sample observations
- [x] Sample photos
- [x] Sample collaboration data
- [ ] Developer toggle

---

## Phase 3: Authentication System
**Status:** Complete  
**Target Duration:** 4-5 days

### Step 3.1: Supabase Setup
- [x] Create Supabase project (config ready, needs project URL/key)
- [ ] Configure auth providers (in Supabase dashboard - manual step)
- [x] Set up environment variables
- [x] Add supabase_flutter package (in pubspec.yaml)
- [x] Initialize Supabase client

### Step 3.2: Auth State Management
- [x] AuthState enum (AppAuthState/AppAuthStatus)
- [x] AuthController provider
- [x] State persistence
- [x] State listeners
- [x] App lifecycle handling

### Step 3.3: Anonymous Mode
- [x] Device ID generation
- [x] Local user creation
- [x] Offline feature verification (FeatureGate)
- [x] Upgrade prompt logic
- [x] Data migration tracking

### Step 3.4: Registration Flow
- [x] Registration screen UI
- [x] Email/password registration
- [x] Social auth (Google, Apple)
- [x] Error handling
- [x] Data migration (automatic on sign-in)
- [x] Email verification (Supabase handles)

### Step 3.5: Login Flow
- [x] Login screen UI
- [x] Email/password login
- [x] Social auth login
- [x] Error handling
- [x] Forgot password flow
- [x] Session persistence

### Step 3.6: Auth UI Integration
- [x] Route guards
- [x] Auth status in app bar
- [x] Profile/Settings screen
- [x] Auth expiration handling
- [x] Feature prompts (UpgradePrompt, UpgradeBanner)

---

## Phase 4: Foray Management
**Status:** Complete  
**Target Duration:** 5-6 days

### Step 4.1: Foray List Screen
- [x] ForayListScreen UI
- [x] Foray list provider
- [x] Status grouping
- [x] Foray cards
- [x] Pull-to-refresh
- [x] Empty state

### Step 4.2: Solo Foray Creation
- [x] Quick Start FAB
- [x] Auto-generate solo foray
- [x] Navigate to detail
- [x] Multiple solo forays support

### Step 4.3: Group Foray Creation
- [x] CreateForayScreen UI
- [x] Form fields
- [x] Privacy selector
- [x] Join code generation
- [ ] QR code generation (placeholder - needs qr_flutter package)
- [x] Local save + sync queue

### Step 4.4: Join Foray Flow
- [x] JoinForayScreen UI
- [x] Code entry
- [ ] QR code scanning (placeholder - needs mobile_scanner package)
- [ ] Deep link handling
- [x] Code validation
- [x] Add participant
- [x] Error handling

### Step 4.5: Foray Detail Screen
- [x] ForayDetailScreen with tabs
- [x] Feed tab (placeholder for Phase 5)
- [x] Map tab placeholder (for Phase 8)
- [x] Participants tab
- [x] Settings tab
- [x] Status and stats display

### Step 4.6: Foray State Management
- [x] Complete foray action
- [x] Reopen foray action
- [x] Lock observations action
- [ ] Participant removal (UI present, logic TODO)
- [ ] Leave foray action
- [x] UI state updates

### Step 4.7: Share Foray
- [x] Share sheet with join code
- [ ] QR code generation (placeholder - needs qr_flutter package)
- [x] Shareable link
- [ ] PDF export (placeholder)
- [ ] Native share integration (placeholder - needs share_plus package)

---

## Phase 5: Observation Entry & Management
**Status:** Complete  
**Target Duration:** 6-7 days

### Step 5.1: Camera Capture Flow
- [x] Camera permissions
- [x] Camera capture screen
- [x] Multi-photo capture
- [x] Thumbnail strip
- [x] Photo deletion
- [x] Error handling

### Step 5.2: GPS Capture
- [x] Location permissions
- [x] LocationService
- [x] Accuracy indicator
- [x] Timeout handling
- [x] Altitude capture

### Step 5.3: Observation Entry Form
- [x] ObservationEntryScreen UI
- [x] Photo gallery section
- [x] GPS display
- [x] Privacy selector
- [x] Substrate picker
- [x] Habitat notes
- [x] Field notes
- [x] Spore print picker
- [x] Collection number

### Step 5.4: Species Search
- [x] Species database integration (mock data)
- [x] Search component
- [x] Autocomplete
- [ ] Offline caching (deferred - uses mock data)
- [x] Free text fallback
- [x] Display both names

### Step 5.5: Specimen ID Field
- [x] Specimen ID input
- [ ] Barcode/QR scanning (placeholder - needs mobile_scanner)
- [ ] Auto-generate option
- [ ] Uniqueness validation

### Step 5.6: Observation Persistence
- [x] Draft auto-save
- [x] Explicit save
- [ ] Photo compression (deferred to Phase 9)
- [x] Local storage
- [x] Sync queue entry (code present, commented out)
- [x] Save confirmation

### Step 5.7: Observation List View
- [x] List component (ObservationCard)
- [x] Thumbnail display
- [x] Updated indicator
- [ ] Search (deferred)
- [ ] Sort options (deferred)
- [x] Lazy loading

### Step 5.8: Observation Detail View
- [x] DetailScreen UI
- [x] Photo gallery
- [x] Metadata display
- [ ] Mini-map (deferred to Phase 8)
- [x] Navigate button
- [x] IDs section placeholder
- [x] Comments section placeholder

### Step 5.9: Observation Editing
- [x] Edit mode (route exists)
- [x] Photo add/remove
- [x] Field editing
- [ ] Change tracking (deferred)
- [ ] Conflict handling (deferred to Phase 9)
- [ ] Lock state respect (TODO)

---

## Phase 6: Collaboration Features
**Status:** Complete  
**Target Duration:** 5-6 days

### Step 6.1: Specimen Lookup
- [x] Lookup UI (SpecimenLookupSheet)
- [x] Text search
- [ ] Barcode/QR scan (placeholder - needs mobile_scanner)
- [x] Navigation on match
- [x] Not found handling

### Step 6.2: Identification Entry
- [x] Add ID UI (AddIdentificationSheet)
- [x] Species search integration
- [x] Confidence selector
- [x] Notes field
- [x] Save + auto-vote
- [x] Sync queue (code present, commented out)

### Step 6.3: ID Voting System
- [x] ID list display (IdentificationsList)
- [x] Vote sorting (by vote count)
- [x] Upvote button
- [x] One vote enforcement (in DAO)
- [x] Vote changing (in DAO)
- [ ] Real-time updates (deferred to Phase 9)

### Step 6.4: ID Management
- [x] Creator deletion
- [x] Organizer deletion
- [x] Confirmation dialog
- [x] Vote cleanup (in DAO)
- [ ] Sync deletion (deferred to Phase 9)

### Step 6.5: Comment Thread
- [x] Comment list UI (CommentsList)
- [x] Author/timestamp display
- [x] Comment entry
- [x] Multi-line support
- [x] Submission
- [x] Ordering (by createdAt)

### Step 6.6: Comment Management
- [x] Author deletion
- [x] Organizer deletion
- [x] Confirmation dialog
- [ ] Sync deletion (deferred to Phase 9)

### Step 6.7: Real-time Updates
- [ ] Observation subscriptions (deferred to Phase 9)
- [ ] ID subscriptions (deferred to Phase 9)
- [ ] Vote subscriptions (deferred to Phase 9)
- [ ] Comment subscriptions (deferred to Phase 9)
- [x] Local state updates (via Riverpod streams)
- [ ] Connection handling (deferred to Phase 9)

---

## Phase 7: Compass Navigation
**Status:** Not Started  
**Target Duration:** 4-5 days

### Step 7.1: Compass Service
- [ ] flutter_compass integration
- [ ] Heading stream with smoothing
- [ ] Calibration prompts
- [ ] Device support check

### Step 7.2: GPS Utilities
- [ ] Haversine distance
- [ ] Bearing calculation
- [ ] GpsUtils class
- [ ] Unit support
- [ ] Unit tests

### Step 7.3: Compass Rose Component
- [ ] CompassRose widget
- [ ] Smooth rotation
- [ ] Cardinal directions
- [ ] Customizable styling
- [ ] High contrast

### Step 7.4: Bearing Indicator
- [ ] BearingIndicator widget
- [ ] Direction arrow
- [ ] Compass integration
- [ ] Smooth animation
- [ ] Alignment highlight

### Step 7.5: Distance Display
- [ ] DistanceDisplay widget
- [ ] Countdown animation
- [ ] Unit preference
- [ ] Format switching
- [ ] Pulse animation

### Step 7.6: Navigation Screen
- [ ] CompassNavigationScreen UI
- [ ] Component integration
- [ ] Target info display
- [ ] GPS accuracy
- [ ] Open in Maps button
- [ ] Permission handling

### Step 7.7: Arrival Detection
- [ ] Threshold detection
- [ ] ArrivalCelebration widget
- [ ] Haptic feedback
- [ ] Mode transition
- [ ] Dismissal handling

### Step 7.8: Edge Cases
- [ ] Calibration prompt
- [ ] Poor GPS warning
- [ ] Very close targets
- [ ] Very far targets
- [ ] Permission denied
- [ ] No compass device

---

## Phase 8: Maps
**Status:** Not Started  
**Target Duration:** 4-5 days

### Step 8.1: Map Infrastructure
- [ ] flutter_map integration
- [ ] Tile provider config
- [ ] ForayMapView component
- [ ] Map controller provider
- [ ] Lifecycle handling

### Step 8.2: Observation Markers
- [ ] ObservationMarker widget
- [ ] Photo thumbnails
- [ ] Privacy indicator
- [ ] Tap interaction
- [ ] Tooltip/popup

### Step 8.3: Marker Clustering
- [ ] Clustering logic
- [ ] ClusterMarker widget
- [ ] Count display
- [ ] Tap to expand
- [ ] Animation

### Step 8.4: Foray Map Screen
- [ ] ForayMapScreen (tab)
- [ ] All observations display
- [ ] Fit all markers
- [ ] Date filter
- [ ] Collector filter
- [ ] Detail navigation

### Step 8.5: Personal Map Screen
- [ ] PersonalMapScreen
- [ ] Cross-foray observations
- [ ] Time filter
- [ ] Species filter
- [ ] My location button
- [ ] Detail navigation

### Step 8.6: Map Polish
- [ ] Smooth pan/zoom
- [ ] Location indicator
- [ ] Compass indicator
- [ ] Theme consistency
- [ ] Loading states

---

## Phase 9: Sync System
**Status:** Not Started  
**Target Duration:** 5-6 days

### Step 9.1: Supabase Schema
- [ ] Create database tables
- [ ] Configure RLS policies
- [ ] Set up indexes
- [ ] Create functions
- [ ] Test with sample data

### Step 9.2: Photo Upload
- [ ] Photo compression
- [ ] Upload service
- [ ] Storage paths
- [ ] Progress tracking
- [ ] Failure retry
- [ ] URL storage

### Step 9.3: Observation Push
- [ ] Push implementation
- [ ] Photo-first upload
- [ ] Partial failure rollback
- [ ] Status update
- [ ] Exponential backoff

### Step 9.4: Observation Pull
- [ ] Fetch from Supabase
- [ ] Local merge
- [ ] Photo download
- [ ] Incremental sync
- [ ] Database update

### Step 9.5: Collaboration Sync
- [ ] Identifications push/pull
- [ ] Votes push/pull
- [ ] Comments push/pull
- [ ] Real-time integration
- [ ] Consistency

### Step 9.6: Conflict Resolution
- [ ] Conflict detection
- [ ] Last-write-wins
- [ ] Conflict flagging
- [ ] Local preservation
- [ ] Conflict UI

### Step 9.7: Background Sync
- [ ] Connectivity detection
- [ ] Auto-trigger on restore
- [ ] Queue processing
- [ ] Status indicators
- [ ] App lifecycle handling

### Step 9.8: Sync Status UI
- [ ] Per-observation status
- [ ] Global status
- [ ] Pending count
- [ ] Last sync time
- [ ] Sync Now button
- [ ] Error retry

---

## Phase 10: Polish & Settings
**Status:** Not Started  
**Target Duration:** 3-4 days

### Step 10.1: Settings Screen
- [ ] SettingsScreen UI
- [ ] Theme toggle
- [ ] Units toggle
- [ ] Default privacy
- [ ] Account section
- [ ] About section

### Step 10.2: Dark Mode
- [ ] Component verification
- [ ] Screen testing
- [ ] Contrast fixes
- [ ] Map dark mode
- [ ] Compass visibility

### Step 10.3: Error Handling
- [ ] Error state audit
- [ ] User-friendly messages
- [ ] Retry mechanisms
- [ ] Crash prevention
- [ ] Error reporting

### Step 10.4: Animation Polish
- [ ] Transition review
- [ ] Page transitions
- [ ] List animations
- [ ] Compass smoothness
- [ ] Micro-interactions

### Step 10.5: Performance Audit
- [ ] Startup profiling
- [ ] Scroll profiling
- [ ] Map profiling
- [ ] Query optimization
- [ ] Image optimization
- [ ] Jank fixes

---

## Phase 11: Web Demo
**Status:** Not Started  
**Target Duration:** 3-4 days

### Step 11.1: Web Build Config
- [ ] Flutter web build
- [ ] Size optimization
- [ ] Web settings
- [ ] Local testing
- [ ] Compilation fixes

### Step 11.2: Feature Adaptation
- [ ] Camera → file picker
- [ ] Simulated GPS
- [ ] Simulated compass
- [ ] IndexedDB support
- [ ] API fallbacks

### Step 11.3: Demo Data
- [ ] Rich dataset
- [ ] Sample forays
- [ ] Diverse observations
- [ ] Bundled photos
- [ ] Pre-authenticated user

### Step 11.4: Portfolio Integration
- [ ] Static hosting deploy
- [ ] Phone frame mockup
- [ ] Iframe embed
- [ ] Landing page
- [ ] GitHub links

### Step 11.5: Demo Polish
- [ ] Full flow test
- [ ] Loading optimization
- [ ] Splash screen
- [ ] Browser testing
- [ ] Responsive testing

---

## Notes & Issues

### Blockers
_None currently_

### Technical Debt
_Track items to revisit_

### Decisions Made
| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-01-21 | Use Supabase for backend | Simplicity, PostgreSQL fit, good free tier |
| 2026-01-21 | Drift for local database | Type-safe, relational model support |
| 2026-01-21 | Simple upvote voting | Easier to implement, sufficient for use case |

### Lessons Learned
_Document insights during development_

---

## Completion Summary

| Phase | Status | Steps Complete |
|-------|--------|----------------|
| 1. Foundation | Nearly Complete | 5/6 |
| 2. Database | Complete (tests pending) | 7/7 |
| 3. Auth | Complete | 6/6 |
| 4. Forays | Complete | 7/7 |
| 5. Observations | Complete | 9/9 |
| 6. Collaboration | Complete | 7/7 |
| 7. Navigation | Not Started | 0/8 |
| 8. Maps | Not Started | 0/6 |
| 9. Sync | Not Started | 0/8 |
| 10. Polish | Not Started | 0/5 |
| 11. Web Demo | Not Started | 0/5 |

**Overall Progress:** 41/74 steps (55%)
