# Foray Development Progress

**Project:** Foray - Mycological Field Collection App  
**Started:** 2026-01-21  
**Last Updated:** 2026-01-21

---

## Overview

This document tracks development progress for the Foray mobile application. Each phase contains discrete steps with checkboxes for tracking completion.

---

## Phase 1: Foundation & Design System
**Status:** In Progress  
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
- [ ] Create theme showcase screen

### Step 1.3: Core Components — Inputs & Buttons
- [x] ForayButton
- [x] ForayTextField
- [ ] ForayDropdown
- [ ] ForaySwitch
- [ ] ForayCheckbox
- [ ] Component showcase

### Step 1.4: Core Components — Display & Feedback
- [ ] ForayCard
- [ ] ForayListTile
- [ ] ForayAvatar
- [ ] ForayBadge
- [x] PrivacyBadge
- [x] SyncStatusIndicator
- [x] GPSAccuracyIndicator
- [ ] ForaySnackbar
- [ ] LoadingShimmer
- [ ] EmptyState

### Step 1.5: Navigation Structure
- [x] Configure GoRouter
- [ ] Create bottom navigation shell
- [ ] Implement route guards
- [ ] Set up deep linking
- [x] Create placeholder screens

### Step 1.6: Development Utilities
- [x] AppConstants class
- [x] Extension methods
- [ ] Validators utility
- [x] Formatters utility
- [ ] Logging utility

---

## Phase 2: Local Database & Core Models
**Status:** Not Started  
**Target Duration:** 4-5 days

### Step 2.1: Drift Setup
- [ ] Add Drift dependencies
- [ ] Configure build runner
- [ ] Create AppDatabase class
- [ ] Set up Riverpod provider
- [ ] Initialize on app start

### Step 2.2: User & Auth Tables
- [ ] Users table definition
- [ ] UsersDao implementation
- [ ] UserModel domain class
- [ ] Local user storage
- [ ] Unit tests

### Step 2.3: Foray Tables
- [ ] Forays table definition
- [ ] ForayParticipants table
- [ ] ForaysDao implementation
- [ ] Domain models
- [ ] Unit tests

### Step 2.4: Observation Tables
- [ ] Observations table definition
- [ ] Photos table definition
- [ ] ObservationsDao implementation
- [ ] Domain models
- [ ] Relationships
- [ ] Unit tests

### Step 2.5: Collaboration Tables
- [ ] Identifications table
- [ ] IdentificationVotes table
- [ ] Comments table
- [ ] DAOs implementation
- [ ] Voting logic
- [ ] Unit tests

### Step 2.6: Sync Queue Table
- [ ] SyncQueue table definition
- [ ] SyncDao implementation
- [ ] Queue entry creation
- [ ] Status tracking
- [ ] Unit tests

### Step 2.7: Mock Data Seeding
- [ ] MockDataSeeder class
- [ ] Sample users
- [ ] Sample forays
- [ ] Sample observations
- [ ] Sample photos
- [ ] Sample collaboration data
- [ ] Developer toggle

---

## Phase 3: Authentication System
**Status:** Not Started  
**Target Duration:** 4-5 days

### Step 3.1: Supabase Setup
- [ ] Create Supabase project
- [ ] Configure auth providers
- [ ] Set up environment variables
- [ ] Add supabase_flutter package
- [ ] Initialize Supabase client

### Step 3.2: Auth State Management
- [ ] AuthState enum
- [ ] AuthController provider
- [ ] State persistence
- [ ] State listeners
- [ ] App lifecycle handling

### Step 3.3: Anonymous Mode
- [ ] Device ID generation
- [ ] Local user creation
- [ ] Offline feature verification
- [ ] Upgrade prompt logic
- [ ] Data migration tracking

### Step 3.4: Registration Flow
- [ ] Registration screen UI
- [ ] Email/password registration
- [ ] Social auth (Google, Apple)
- [ ] Error handling
- [ ] Data migration
- [ ] Email verification

### Step 3.5: Login Flow
- [ ] Login screen UI
- [ ] Email/password login
- [ ] Social auth login
- [ ] Error handling
- [ ] Forgot password flow
- [ ] Session persistence

### Step 3.6: Auth UI Integration
- [ ] Route guards
- [ ] Auth status in app bar
- [ ] Profile screen
- [ ] Auth expiration handling
- [ ] Feature prompts

---

## Phase 4: Foray Management
**Status:** Not Started  
**Target Duration:** 5-6 days

### Step 4.1: Foray List Screen
- [ ] ForayListScreen UI
- [ ] Foray list provider
- [ ] Status grouping
- [ ] Foray cards
- [ ] Pull-to-refresh
- [ ] Empty state

### Step 4.2: Solo Foray Creation
- [ ] Quick Start FAB
- [ ] Auto-generate solo foray
- [ ] Navigate to detail
- [ ] Multiple solo forays support

### Step 4.3: Group Foray Creation
- [ ] CreateForayScreen UI
- [ ] Form fields
- [ ] Privacy selector
- [ ] Join code generation
- [ ] QR code generation
- [ ] Local save + sync queue

### Step 4.4: Join Foray Flow
- [ ] JoinForayScreen UI
- [ ] Code entry
- [ ] QR code scanning
- [ ] Deep link handling
- [ ] Code validation
- [ ] Add participant
- [ ] Error handling

### Step 4.5: Foray Detail Screen
- [ ] ForayDetailScreen with tabs
- [ ] Feed tab
- [ ] Map tab placeholder
- [ ] Participants tab
- [ ] Settings tab
- [ ] Status and stats display

### Step 4.6: Foray State Management
- [ ] Complete foray action
- [ ] Reopen foray action
- [ ] Lock observations action
- [ ] Participant removal
- [ ] Leave foray action
- [ ] UI state updates

### Step 4.7: Share Foray
- [ ] Share sheet with join code
- [ ] QR code generation
- [ ] Shareable link
- [ ] PDF export
- [ ] Native share integration

---

## Phase 5: Observation Entry & Management
**Status:** Not Started  
**Target Duration:** 6-7 days

### Step 5.1: Camera Capture Flow
- [ ] Camera permissions
- [ ] Camera capture screen
- [ ] Multi-photo capture
- [ ] Thumbnail strip
- [ ] Photo deletion
- [ ] Error handling

### Step 5.2: GPS Capture
- [ ] Location permissions
- [ ] LocationService
- [ ] Accuracy indicator
- [ ] Timeout handling
- [ ] Altitude capture

### Step 5.3: Observation Entry Form
- [ ] ObservationEntryScreen UI
- [ ] Photo gallery section
- [ ] GPS display
- [ ] Privacy selector
- [ ] Substrate picker
- [ ] Habitat notes
- [ ] Field notes
- [ ] Spore print picker
- [ ] Collection number

### Step 5.4: Species Search
- [ ] Species database integration
- [ ] Search component
- [ ] Autocomplete
- [ ] Offline caching
- [ ] Free text fallback
- [ ] Display both names

### Step 5.5: Specimen ID Field
- [ ] Specimen ID input
- [ ] Barcode/QR scanning
- [ ] Auto-generate option
- [ ] Uniqueness validation

### Step 5.6: Observation Persistence
- [ ] Draft auto-save
- [ ] Explicit save
- [ ] Photo compression
- [ ] Local storage
- [ ] Sync queue entry
- [ ] Save confirmation

### Step 5.7: Observation List View
- [ ] List component
- [ ] Thumbnail display
- [ ] Updated indicator
- [ ] Search
- [ ] Sort options
- [ ] Lazy loading

### Step 5.8: Observation Detail View
- [ ] DetailScreen UI
- [ ] Photo gallery
- [ ] Metadata display
- [ ] Mini-map
- [ ] Navigate button
- [ ] IDs section placeholder
- [ ] Comments section placeholder

### Step 5.9: Observation Editing
- [ ] Edit mode
- [ ] Photo add/remove
- [ ] Field editing
- [ ] Change tracking
- [ ] Conflict handling
- [ ] Lock state respect

---

## Phase 6: Collaboration Features
**Status:** Not Started  
**Target Duration:** 5-6 days

### Step 6.1: Specimen Lookup
- [ ] Lookup UI
- [ ] Text search
- [ ] Barcode/QR scan
- [ ] Navigation on match
- [ ] Not found handling

### Step 6.2: Identification Entry
- [ ] Add ID UI
- [ ] Species search integration
- [ ] Confidence selector
- [ ] Notes field
- [ ] Save + auto-vote
- [ ] Sync queue

### Step 6.3: ID Voting System
- [ ] ID list display
- [ ] Vote sorting
- [ ] Upvote button
- [ ] One vote enforcement
- [ ] Vote changing
- [ ] Real-time updates

### Step 6.4: ID Management
- [ ] Creator deletion
- [ ] Organizer deletion
- [ ] Confirmation dialog
- [ ] Vote cleanup
- [ ] Sync deletion

### Step 6.5: Comment Thread
- [ ] Comment list UI
- [ ] Author/timestamp display
- [ ] Comment entry
- [ ] Multi-line support
- [ ] Submission
- [ ] Ordering

### Step 6.6: Comment Management
- [ ] Author deletion
- [ ] Organizer deletion
- [ ] Confirmation dialog
- [ ] Sync deletion

### Step 6.7: Real-time Updates
- [ ] Observation subscriptions
- [ ] ID subscriptions
- [ ] Vote subscriptions
- [ ] Comment subscriptions
- [ ] Local state updates
- [ ] Connection handling

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
| 1. Foundation | Not Started | 0/6 |
| 2. Database | Not Started | 0/7 |
| 3. Auth | Not Started | 0/6 |
| 4. Forays | Not Started | 0/7 |
| 5. Observations | Not Started | 0/9 |
| 6. Collaboration | Not Started | 0/7 |
| 7. Navigation | Not Started | 0/8 |
| 8. Maps | Not Started | 0/6 |
| 9. Sync | Not Started | 0/8 |
| 10. Polish | Not Started | 0/5 |
| 11. Web Demo | Not Started | 0/5 |

**Overall Progress:** 0/74 steps (0%)
