# Foray Development Work Plan

**Version:** 1.0  
**Last Updated:** 2026-01-21  
**Status:** Planning Complete

---

## Overview

This document outlines the development plan for Foray, a cross-platform mobile application for mycological field collection. Development is divided into 9 phases with discrete, self-contained steps that build upon each other.

### Architecture Summary

| Layer | Technology |
|-------|------------|
| Mobile Framework | Flutter (Dart) |
| State Management | Riverpod 2.x |
| Local Database | Drift (SQLite) |
| Cloud Database | Supabase PostgreSQL |
| Authentication | Supabase Auth |
| Photo Storage | Supabase Storage |
| Real-time | Supabase Realtime |
| Routing | GoRouter |

### Key Decisions Reference

See `OVERVIEW.md` for full context. Key decisions made during planning:

- **Offline-first**: All features work without network. Drift handles local persistence.
- **Privacy-first**: Default to private. User controls sharing granularity.
- **Account optional**: Local-only use without registration. Auth required for sync/sharing/collaboration.
- **Supabase backend**: Single service for auth, database, storage, real-time.
- **Species search**: Autocomplete with common + Latin names (Index Fungorum or MycoBank).
- **Collaboration model**: Specimen IDs, ID voting (one vote per user), comment threads per observation.

---

## Phase 1: Foundation & Design System

**Goal:** Establish project structure, theming, and reusable component library.  
**Duration:** 5-7 days  
**Dependencies:** None

### Step 1.1: Project Initialization
**Spec:** `specs/01-foundation.md` Section 1

- [ ] Create Flutter project with recommended structure
- [ ] Configure `pubspec.yaml` with core dependencies
- [ ] Set up linting rules (`analysis_options.yaml`)
- [ ] Configure VS Code / IDE settings
- [ ] Initialize Git repository with `.gitignore`
- [ ] Create basic `main.dart` and `app.dart` entry points

**Deliverables:** Runnable Flutter app with "Hello Foray" screen

### Step 1.2: Theme System
**Spec:** `specs/01-foundation.md` Section 2

- [ ] Define `AppColors` with light/dark variants
- [ ] Define `AppTypography` with text styles
- [ ] Define `AppSpacing` constants
- [ ] Define `AppShadows` for elevation
- [ ] Create `AppTheme` class combining all theme data
- [ ] Implement theme provider with light/dark toggle
- [ ] Create theme showcase screen for development

**Deliverables:** Complete theme system with toggle functionality

### Step 1.3: Core Component Library — Inputs & Buttons
**Spec:** `specs/01-foundation.md` Section 3

- [ ] `ForayButton` — primary, secondary, text, icon variants
- [ ] `ForayTextField` — with validation, helper text, error states
- [ ] `ForayDropdown` — styled dropdown selector
- [ ] `ForaySwitch` — toggle switch
- [ ] `ForayCheckbox` — checkbox with label
- [ ] Component showcase screen

**Deliverables:** Input components with all states documented

### Step 1.4: Core Component Library — Display & Feedback
**Spec:** `specs/01-foundation.md` Section 3

- [ ] `ForayCard` — elevation variants, tap feedback
- [ ] `ForayListTile` — standardized list item
- [ ] `ForayAvatar` — user avatar with fallback
- [ ] `ForayBadge` — status badges
- [ ] `PrivacyBadge` — privacy level indicator (icon + label)
- [ ] `SyncStatusIndicator` — sync state visualization
- [ ] `GPSAccuracyIndicator` — location precision display
- [ ] `ForaySnackbar` — success, error, info variants
- [ ] `LoadingShimmer` — skeleton loading placeholders
- [ ] `EmptyState` — illustrated empty state component

**Deliverables:** Display and feedback components complete

### Step 1.5: Navigation Structure
**Spec:** `specs/01-foundation.md` Section 4

- [ ] Configure GoRouter with initial routes
- [ ] Create bottom navigation shell (if applicable)
- [ ] Implement route guards (auth check placeholder)
- [ ] Set up deep linking structure
- [ ] Create placeholder screens for all main routes

**Deliverables:** Navigation skeleton with all routes accessible

### Step 1.6: Development Utilities
**Spec:** `specs/01-foundation.md` Section 5

- [ ] Create `AppConstants` class
- [ ] Create extension methods (`context_extensions.dart`, `datetime_extensions.dart`)
- [ ] Create `Validators` utility class
- [ ] Create `Formatters` utility class (distance, dates)
- [ ] Set up logging utility

**Deliverables:** Utility classes ready for use

---

## Phase 2: Local Database & Core Models

**Goal:** Implement Drift database with all tables and DAOs for offline-first operation.  
**Duration:** 4-5 days  
**Dependencies:** Phase 1 complete

### Step 2.1: Drift Setup & Configuration
**Spec:** `specs/02-database.md` Section 1

- [ ] Add Drift dependencies to `pubspec.yaml`
- [ ] Configure build runner for code generation
- [ ] Create `database.dart` with AppDatabase class
- [ ] Set up database provider in Riverpod
- [ ] Implement database initialization on app start

**Deliverables:** Empty Drift database initializing on app launch

### Step 2.2: User & Auth Tables
**Spec:** `specs/02-database.md` Section 2

- [ ] Create `users` table definition
- [ ] Create `UsersDao` with CRUD operations
- [ ] Create `UserModel` domain class
- [ ] Implement local user storage for anonymous mode
- [ ] Write unit tests for UsersDao

**Deliverables:** User persistence working locally

### Step 2.3: Foray Tables
**Spec:** `specs/02-database.md` Section 3

- [ ] Create `forays` table definition
- [ ] Create `foray_participants` table definition
- [ ] Create `ForaysDao` with CRUD + queries
- [ ] Create `ForayModel` and `ParticipantModel` domain classes
- [ ] Implement foray-participant relationships
- [ ] Write unit tests for ForaysDao

**Deliverables:** Foray persistence with participant support

### Step 2.4: Observation Tables
**Spec:** `specs/02-database.md` Section 4

- [ ] Create `observations` table definition
- [ ] Create `photos` table definition
- [ ] Create `ObservationsDao` with CRUD + queries
- [ ] Create `ObservationModel` and `PhotoModel` domain classes
- [ ] Implement observation-photo relationships
- [ ] Implement observation-foray relationships
- [ ] Write unit tests for ObservationsDao

**Deliverables:** Observation persistence with photo support

### Step 2.5: Collaboration Tables
**Spec:** `specs/02-database.md` Section 5

- [ ] Create `identifications` table definition
- [ ] Create `identification_votes` table definition
- [ ] Create `comments` table definition
- [ ] Create DAOs for collaboration entities
- [ ] Create domain models
- [ ] Implement voting logic (one vote per user, change vote)
- [ ] Write unit tests

**Deliverables:** Full collaboration data model working

### Step 2.6: Sync Queue Table
**Spec:** `specs/02-database.md` Section 6

- [ ] Create `sync_queue` table definition
- [ ] Create `SyncDao` with queue operations
- [ ] Implement queue entry creation on data changes
- [ ] Implement queue status tracking
- [ ] Write unit tests

**Deliverables:** Sync queue infrastructure ready

### Step 2.7: Mock Data Seeding
**Spec:** `specs/02-database.md` Section 7

- [ ] Create `MockDataSeeder` class
- [ ] Generate sample users
- [ ] Generate sample forays (solo, group, society event)
- [ ] Generate sample observations with varied data
- [ ] Generate sample photos (placeholder paths)
- [ ] Generate sample IDs, votes, comments
- [ ] Add developer toggle to seed on fresh install

**Deliverables:** Rich mock data for development and demo

---

## Phase 3: Authentication System

**Goal:** Implement local-only mode and Supabase authentication.  
**Duration:** 4-5 days  
**Dependencies:** Phase 2 complete

### Step 3.1: Supabase Project Setup
**Spec:** `specs/03-auth.md` Section 1

- [ ] Create Supabase project
- [ ] Configure auth providers (email, Google, Apple)
- [ ] Set up environment variables / config
- [ ] Add `supabase_flutter` package
- [ ] Initialize Supabase client in app

**Deliverables:** Supabase project connected to app

### Step 3.2: Auth State Management
**Spec:** `specs/03-auth.md` Section 2

- [ ] Create `AuthState` enum (anonymous, authenticated, loading)
- [ ] Create `AuthController` Riverpod provider
- [ ] Implement auth state persistence
- [ ] Implement auth state listeners
- [ ] Handle app lifecycle (resume, etc.)

**Deliverables:** Auth state management infrastructure

### Step 3.3: Anonymous Mode
**Spec:** `specs/03-auth.md` Section 3

- [ ] Implement device ID generation
- [ ] Create local-only user on first launch
- [ ] Ensure all features work without network
- [ ] Implement "Upgrade to account" prompt logic
- [ ] Track anonymous user's local data for migration

**Deliverables:** Full app functionality without sign-in

### Step 3.4: Registration Flow
**Spec:** `specs/03-auth.md` Section 4

- [ ] Create registration screen UI
- [ ] Implement email/password registration
- [ ] Implement social auth (Google, Apple)
- [ ] Handle registration errors
- [ ] Migrate anonymous data to new account
- [ ] Email verification flow (if required)

**Deliverables:** Working registration with data migration

### Step 3.5: Login Flow
**Spec:** `specs/03-auth.md` Section 5

- [ ] Create login screen UI
- [ ] Implement email/password login
- [ ] Implement social auth login
- [ ] Handle login errors
- [ ] Implement "Forgot Password" flow
- [ ] Session persistence across app restarts

**Deliverables:** Working login with session persistence

### Step 3.6: Auth UI Integration
**Spec:** `specs/03-auth.md` Section 6

- [ ] Implement route guards (redirect to login when needed)
- [ ] Add auth status to app bar / profile area
- [ ] Create profile screen with logout
- [ ] Handle auth expiration gracefully
- [ ] Implement "Sign in to enable feature" prompts

**Deliverables:** Auth fully integrated into app navigation

---

## Phase 4: Foray Management

**Goal:** Implement foray creation, listing, joining, and state management.  
**Duration:** 5-6 days  
**Dependencies:** Phase 3 complete

### Step 4.1: Foray List Screen
**Spec:** `specs/04-forays.md` Section 1

- [ ] Create `ForayListScreen` UI
- [ ] Implement foray list provider (Riverpod)
- [ ] Display forays grouped by status (active, completed)
- [ ] Show foray cards with key info (name, date, observation count)
- [ ] Implement pull-to-refresh
- [ ] Handle empty state

**Deliverables:** Foray list displaying local forays

### Step 4.2: Solo Foray Creation
**Spec:** `specs/04-forays.md` Section 2

- [ ] Implement "Quick Start" FAB for solo foray
- [ ] Auto-generate solo foray with sensible defaults
- [ ] Navigate to foray detail after creation
- [ ] Support multiple solo forays (personal organization)

**Deliverables:** One-tap solo foray creation

### Step 4.3: Group Foray Creation
**Spec:** `specs/04-forays.md` Section 3

- [ ] Create `CreateForayScreen` UI
- [ ] Implement form: name, description, date, location name
- [ ] Implement default privacy selector
- [ ] Generate join code on creation
- [ ] Generate QR code for join code
- [ ] Save foray locally (queue for sync if authenticated)

**Deliverables:** Full group foray creation flow

### Step 4.4: Join Foray Flow
**Spec:** `specs/04-forays.md` Section 4

- [ ] Create `JoinForayScreen` UI
- [ ] Implement code entry (6-character)
- [ ] Implement QR code scanning
- [ ] Implement deep link handling for join URLs
- [ ] Validate join code against Supabase
- [ ] Add user as participant
- [ ] Handle errors (invalid code, already joined, etc.)

**Deliverables:** Multiple methods to join a foray

### Step 4.5: Foray Detail Screen
**Spec:** `specs/04-forays.md` Section 5

- [ ] Create `ForayDetailScreen` with tab structure
- [ ] Implement "Feed" tab (observation list)
- [ ] Implement "Map" tab (placeholder for Phase 7)
- [ ] Implement "Participants" tab
- [ ] Implement "Settings" tab (organizer only)
- [ ] Show foray status and key stats

**Deliverables:** Foray detail with tabbed interface

### Step 4.6: Foray State Management
**Spec:** `specs/04-forays.md` Section 6

- [ ] Implement "Complete" foray action (organizer)
- [ ] Implement "Reopen" foray action (organizer)
- [ ] Implement "Lock observations" action (organizer)
- [ ] Implement participant removal (organizer)
- [ ] Implement "Leave foray" action (participant)
- [ ] Update UI based on foray state

**Deliverables:** Full foray lifecycle management

### Step 4.7: Share Foray
**Spec:** `specs/04-forays.md` Section 7

- [ ] Create share sheet with join code
- [ ] Generate shareable QR code image
- [ ] Generate shareable link
- [ ] Export QR codes as PDF (for printing)
- [ ] Integrate with native share sheet

**Deliverables:** Multiple sharing mechanisms

---

## Phase 5: Observation Entry & Management

**Goal:** Implement observation creation, editing, and display.  
**Duration:** 6-7 days  
**Dependencies:** Phase 4 complete

### Step 5.1: Camera Capture Flow
**Spec:** `specs/05-observations.md` Section 1

- [ ] Implement camera permission handling
- [ ] Create camera capture screen
- [ ] Support multi-photo capture (up to 10)
- [ ] Display thumbnail strip of captured photos
- [ ] Implement photo deletion before save
- [ ] Handle camera errors gracefully

**Deliverables:** Multi-photo capture working

### Step 5.2: GPS Capture
**Spec:** `specs/05-observations.md` Section 2

- [ ] Implement location permission handling
- [ ] Create `LocationService` for GPS operations
- [ ] Capture coordinates with accuracy reading
- [ ] Display `GPSAccuracyIndicator` during capture
- [ ] Handle GPS timeout / failure
- [ ] Store altitude if available

**Deliverables:** Reliable GPS capture with accuracy info

### Step 5.3: Observation Entry Form
**Spec:** `specs/05-observations.md` Section 3

- [ ] Create `ObservationEntryScreen` UI
- [ ] Implement photo gallery section (add more, delete)
- [ ] Display GPS info with accuracy
- [ ] Implement privacy selector (prominent placement)
- [ ] Implement substrate picker
- [ ] Implement habitat notes field
- [ ] Implement field notes field
- [ ] Implement spore print color picker
- [ ] Implement collection number field (auto-increment option)

**Deliverables:** Complete observation entry form

### Step 5.4: Species Search & Selection
**Spec:** `specs/05-observations.md` Section 4

- [ ] Integrate species database (Index Fungorum or MycoBank)
- [ ] Create species search component
- [ ] Implement autocomplete for common + Latin names
- [ ] Cache species data locally for offline
- [ ] Handle "species not found" (allow free text)
- [ ] Display selected species with both names

**Deliverables:** Species autocomplete working

### Step 5.5: Specimen ID Field
**Spec:** `specs/05-observations.md` Section 5

- [ ] Add specimen ID field to observation
- [ ] Support manual text entry
- [ ] Support barcode/QR scanning
- [ ] Auto-generate specimen ID option
- [ ] Validate uniqueness within foray

**Deliverables:** Specimen ID capture via text or scan

### Step 5.6: Observation Persistence
**Spec:** `specs/05-observations.md` Section 6

- [ ] Implement draft save (auto-save)
- [ ] Implement explicit save/submit
- [ ] Compress photos for storage
- [ ] Store photos locally with references
- [ ] Add to sync queue if authenticated
- [ ] Show save confirmation

**Deliverables:** Observations persisting locally

### Step 5.7: Observation List View
**Spec:** `specs/05-observations.md` Section 7

- [ ] Create observation list component
- [ ] Display thumbnail, species, date, privacy badge
- [ ] Implement "updated since viewed" indicator
- [ ] Implement search within foray
- [ ] Implement sort options (date, species, collector)
- [ ] Handle long lists efficiently (lazy loading)

**Deliverables:** Searchable, sortable observation list

### Step 5.8: Observation Detail View
**Spec:** `specs/05-observations.md` Section 8

- [ ] Create `ObservationDetailScreen` UI
- [ ] Display photo gallery (swipeable)
- [ ] Display all observation metadata
- [ ] Display location on mini-map
- [ ] Add "Navigate to" button (placeholder for Phase 6)
- [ ] Display IDs section (placeholder for Phase 5B)
- [ ] Display comments section (placeholder for Phase 5B)

**Deliverables:** Full observation detail view

### Step 5.9: Observation Editing
**Spec:** `specs/05-observations.md` Section 9

- [ ] Enable edit mode on own observations
- [ ] Allow adding/removing photos
- [ ] Allow editing all fields
- [ ] Track changes for sync
- [ ] Handle edit conflicts (if synced)
- [ ] Respect foray lock state

**Deliverables:** Full observation editing capability

---

## Phase 6: Collaboration Features

**Goal:** Implement specimen lookup, ID voting, and comments.  
**Duration:** 5-6 days  
**Dependencies:** Phase 5 complete

### Step 6.1: Specimen Lookup
**Spec:** `specs/06-collaboration.md` Section 1

- [ ] Create specimen lookup UI (search + scan)
- [ ] Add lookup button to foray detail screen
- [ ] Implement text search by specimen ID
- [ ] Implement barcode/QR scan for lookup
- [ ] Navigate to observation on match
- [ ] Handle "not found" gracefully

**Deliverables:** Find observation by specimen ID

### Step 6.2: Identification Entry
**Spec:** `specs/06-collaboration.md` Section 2

- [ ] Create "Add ID" UI on observation detail
- [ ] Integrate species search component
- [ ] Add confidence level selector
- [ ] Add optional notes field for reasoning
- [ ] Save identification locally
- [ ] Queue for sync

**Deliverables:** Users can add species IDs

### Step 6.3: ID Voting System
**Spec:** `specs/06-collaboration.md` Section 3

- [ ] Display ID list sorted by votes
- [ ] Implement upvote button
- [ ] Enforce one vote per user per ID
- [ ] Allow changing vote (move to different ID)
- [ ] Show vote count and voter names
- [ ] Update UI in real-time

**Deliverables:** Working voting on IDs

### Step 6.4: ID Management
**Spec:** `specs/06-collaboration.md` Section 4

- [ ] Allow ID deletion by creator
- [ ] Allow ID deletion by foray organizer
- [ ] Confirm before deletion
- [ ] Update vote counts on deletion
- [ ] Sync deletions

**Deliverables:** ID lifecycle management

### Step 6.5: Comment Thread
**Spec:** `specs/06-collaboration.md` Section 5

- [ ] Create comment list UI
- [ ] Display comments with author, timestamp
- [ ] Implement comment entry field
- [ ] Support multi-line comments
- [ ] Implement comment submission
- [ ] Order by timestamp (oldest first)

**Deliverables:** Working comment thread

### Step 6.6: Comment Management
**Spec:** `specs/06-collaboration.md` Section 6

- [ ] Allow comment deletion by author
- [ ] Allow comment deletion by organizer
- [ ] Confirm before deletion
- [ ] Show "deleted" placeholder or remove entirely
- [ ] Sync deletions

**Deliverables:** Comment lifecycle management

### Step 6.7: Real-time Updates (Supabase)
**Spec:** `specs/06-collaboration.md` Section 7

- [ ] Subscribe to foray observation changes
- [ ] Subscribe to ID changes
- [ ] Subscribe to vote changes
- [ ] Subscribe to comment changes
- [ ] Update local state on remote changes
- [ ] Handle subscription lifecycle (connect/disconnect)

**Deliverables:** Live collaboration without polling

---

## Phase 7: Compass Navigation

**Goal:** Implement compass-based navigation to observation locations.  
**Duration:** 4-5 days  
**Dependencies:** Phase 5 complete

### Step 7.1: Compass Service
**Spec:** `specs/07-navigation.md` Section 1

- [ ] Integrate `flutter_compass` package
- [ ] Create `CompassService` class
- [ ] Implement heading stream with smoothing
- [ ] Handle compass calibration prompts
- [ ] Handle devices without magnetometer

**Deliverables:** Reliable compass heading data

### Step 7.2: GPS Utilities
**Spec:** `specs/07-navigation.md` Section 2

- [ ] Implement Haversine distance calculation
- [ ] Implement bearing calculation
- [ ] Create `GpsUtils` class
- [ ] Support metric and imperial units
- [ ] Write unit tests for calculations

**Deliverables:** Accurate distance and bearing math

### Step 7.3: Compass Rose Component
**Spec:** `specs/07-navigation.md` Section 3

- [ ] Create `CompassRose` widget
- [ ] Implement smooth rotation animation (60fps)
- [ ] Display cardinal directions (N, E, S, W)
- [ ] Support customizable styling
- [ ] High contrast for outdoor visibility

**Deliverables:** Animated compass rose component

### Step 7.4: Bearing Indicator Component
**Spec:** `specs/07-navigation.md` Section 4

- [ ] Create `BearingIndicator` widget
- [ ] Show direction arrow to target
- [ ] Integrate with compass rotation
- [ ] Animate smoothly with heading changes
- [ ] Highlight when aligned with target

**Deliverables:** Target direction indicator

### Step 7.5: Distance Display Component
**Spec:** `specs/07-navigation.md` Section 5

- [ ] Create `DistanceDisplay` widget
- [ ] Animate distance countdown
- [ ] Switch units based on user preference
- [ ] Format appropriately (m vs km, ft vs mi)
- [ ] Pulse animation when getting closer

**Deliverables:** Animated distance readout

### Step 7.6: Navigation Screen
**Spec:** `specs/07-navigation.md` Section 6

- [ ] Create `CompassNavigationScreen` UI
- [ ] Integrate compass, bearing, distance components
- [ ] Display target observation info
- [ ] Show current GPS accuracy
- [ ] Add "Open in Maps" button
- [ ] Handle permission prompts

**Deliverables:** Full navigation screen

### Step 7.7: Arrival Detection
**Spec:** `specs/07-navigation.md` Section 7

- [ ] Detect when within arrival threshold (~10m)
- [ ] Create `ArrivalCelebration` component
- [ ] Implement haptic feedback on arrival
- [ ] Transition to arrival mode gracefully
- [ ] Allow dismissing to continue navigating

**Deliverables:** Satisfying arrival experience

### Step 7.8: Edge Cases & Polish
**Spec:** `specs/07-navigation.md` Section 8

- [ ] Handle compass calibration needed
- [ ] Handle poor GPS accuracy (show warning)
- [ ] Handle very close targets (<20m)
- [ ] Handle very far targets (>50km)
- [ ] Handle location permission denied
- [ ] Handle device without compass

**Deliverables:** Robust navigation in all conditions

---

## Phase 8: Maps

**Goal:** Implement map views for forays and personal observation history.  
**Duration:** 4-5 days  
**Dependencies:** Phase 5 complete

### Step 8.1: Map Infrastructure
**Spec:** `specs/08-maps.md` Section 1

- [ ] Integrate `flutter_map` package
- [ ] Configure tile provider (OpenStreetMap)
- [ ] Create `ForayMapView` base component
- [ ] Implement map controller provider
- [ ] Handle map lifecycle (dispose)

**Deliverables:** Basic map rendering

### Step 8.2: Observation Markers
**Spec:** `specs/08-maps.md` Section 2

- [ ] Create `ObservationMarker` widget
- [ ] Display species icon or photo thumbnail
- [ ] Show privacy indicator
- [ ] Implement tap interaction
- [ ] Show popup/tooltip on tap

**Deliverables:** Tappable observation markers

### Step 8.3: Marker Clustering
**Spec:** `specs/08-maps.md` Section 3

- [ ] Implement marker clustering logic
- [ ] Create `ClusterMarker` widget
- [ ] Show count in cluster
- [ ] Expand cluster on tap
- [ ] Animate cluster expansion

**Deliverables:** Clustered markers at low zoom

### Step 8.4: Foray Map Screen
**Spec:** `specs/08-maps.md` Section 4

- [ ] Create `ForayMapScreen` (or tab content)
- [ ] Display all foray observations
- [ ] Implement "fit all markers" action
- [ ] Filter by date range
- [ ] Filter by collector
- [ ] Navigate to observation detail on marker tap

**Deliverables:** Foray map with filtering

### Step 8.5: Personal Map Screen
**Spec:** `specs/08-maps.md` Section 5

- [ ] Create `PersonalMapScreen`
- [ ] Display all user's observations across forays
- [ ] Implement time-range filter
- [ ] Implement species filter
- [ ] "My location" button
- [ ] Navigate to observation detail on marker tap

**Deliverables:** Personal observation history map

### Step 8.6: Map Interaction Polish
**Spec:** `specs/08-maps.md` Section 6

- [ ] Smooth pan and zoom
- [ ] Current location indicator
- [ ] Compass bearing indicator on map
- [ ] Map style consistent with app theme
- [ ] Handle map loading states

**Deliverables:** Polished map experience

---

## Phase 9: Sync System

**Goal:** Implement robust offline-first sync with Supabase.  
**Duration:** 5-6 days  
**Dependencies:** Phase 6 complete

### Step 9.1: Supabase Schema Setup
**Spec:** `specs/09-sync.md` Section 1

- [ ] Create Supabase database tables (mirror Drift schema)
- [ ] Configure Row Level Security policies
- [ ] Set up indexes for common queries
- [ ] Create database functions (if needed)
- [ ] Test schema with sample data

**Deliverables:** Supabase database ready

### Step 9.2: Photo Upload
**Spec:** `specs/09-sync.md` Section 2

- [ ] Implement photo compression for upload
- [ ] Create upload service for Supabase Storage
- [ ] Generate unique storage paths
- [ ] Handle upload progress
- [ ] Handle upload failures with retry
- [ ] Store remote URLs after success

**Deliverables:** Photos uploading to Supabase Storage

### Step 9.3: Observation Sync (Push)
**Spec:** `specs/09-sync.md` Section 3

- [ ] Implement observation push to Supabase
- [ ] Upload photos first, then observation
- [ ] Handle partial failures (rollback)
- [ ] Update local sync status on success
- [ ] Implement retry with exponential backoff

**Deliverables:** Observations syncing to cloud

### Step 9.4: Observation Sync (Pull)
**Spec:** `specs/09-sync.md` Section 4

- [ ] Fetch foray observations from Supabase
- [ ] Merge with local observations
- [ ] Download new photos
- [ ] Handle "new since last sync" efficiently
- [ ] Update local database with remote changes

**Deliverables:** Pulling observations from cloud

### Step 9.5: Collaboration Data Sync
**Spec:** `specs/09-sync.md` Section 5

- [ ] Sync identifications (push/pull)
- [ ] Sync votes (push/pull)
- [ ] Sync comments (push/pull)
- [ ] Handle real-time updates via Supabase
- [ ] Ensure consistency

**Deliverables:** Full collaboration sync

### Step 9.6: Conflict Resolution
**Spec:** `specs/09-sync.md` Section 6

- [ ] Detect conflicts (same entity modified locally and remotely)
- [ ] Implement last-write-wins for simple fields
- [ ] Flag conflicts for review (optional)
- [ ] Preserve local changes on conflict
- [ ] Provide conflict UI (if flagging)

**Deliverables:** Graceful conflict handling

### Step 9.7: Background Sync
**Spec:** `specs/09-sync.md` Section 7

- [ ] Detect connectivity changes
- [ ] Trigger sync on connectivity restore
- [ ] Process sync queue in background
- [ ] Implement sync status indicators in UI
- [ ] Handle app backgrounding/foregrounding

**Deliverables:** Automatic background sync

### Step 9.8: Sync Status UI
**Spec:** `specs/09-sync.md` Section 8

- [ ] Show sync status per observation
- [ ] Show global sync status (app bar or banner)
- [ ] Show pending upload count
- [ ] Show last sync time
- [ ] Manual "Sync now" button
- [ ] Show sync errors with retry option

**Deliverables:** Clear sync visibility

---

## Phase 10: Polish & Settings

**Goal:** Complete settings, dark mode, and overall polish.  
**Duration:** 3-4 days  
**Dependencies:** Phase 8 complete

### Step 10.1: Settings Screen
**Spec:** `specs/01-foundation.md` Section 6

- [ ] Create `SettingsScreen` UI
- [ ] Implement theme toggle (light/dark)
- [ ] Implement units toggle (metric/imperial)
- [ ] Implement default privacy setting
- [ ] Account section (profile, logout)
- [ ] About section (version, licenses)

**Deliverables:** Complete settings screen

### Step 10.2: Dark Mode Implementation
**Spec:** `specs/01-foundation.md` Section 2

- [ ] Verify all components support dark theme
- [ ] Test all screens in dark mode
- [ ] Fix any contrast or visibility issues
- [ ] Ensure maps work in dark mode
- [ ] Test compass in dark mode (outdoor visibility)

**Deliverables:** Full dark mode support

### Step 10.3: Error Handling Polish
**Spec:** `specs/01-foundation.md` Section 7

- [ ] Audit all error states
- [ ] Implement user-friendly error messages
- [ ] Add retry mechanisms where appropriate
- [ ] Ensure no unhandled exceptions crash app
- [ ] Add error reporting infrastructure (optional)

**Deliverables:** Graceful error handling throughout

### Step 10.4: Animation Polish
**Spec:** `specs/01-foundation.md` Section 8

- [ ] Review all transitions
- [ ] Add page transitions
- [ ] Polish list animations
- [ ] Polish compass animations
- [ ] Add micro-interactions (button feedback, etc.)

**Deliverables:** Smooth, delightful animations

### Step 10.5: Performance Audit
**Spec:** `specs/01-foundation.md` Section 9

- [ ] Profile app startup time
- [ ] Profile list scrolling
- [ ] Profile map performance
- [ ] Optimize database queries
- [ ] Optimize image loading
- [ ] Fix any jank

**Deliverables:** Meets performance targets

---

## Phase 11: Web Demo

**Goal:** Build and deploy Flutter web version for portfolio demonstration.  
**Duration:** 3-4 days  
**Dependencies:** Phase 10 complete

### Step 11.1: Web Build Configuration
**Spec:** `specs/10-web-demo.md` Section 1

- [ ] Configure Flutter web build
- [ ] Optimize for size (tree-shaking, deferred loading)
- [ ] Configure web-specific settings
- [ ] Test build locally
- [ ] Fix any web-specific compilation issues

**Deliverables:** Flutter web building successfully

### Step 11.2: Feature Adaptation
**Spec:** `specs/10-web-demo.md` Section 2

- [ ] Replace camera with file picker
- [ ] Use simulated/fixed GPS coordinates
- [ ] Simulate compass (animated demo)
- [ ] Ensure Drift works with IndexedDB on web
- [ ] Handle any missing platform APIs

**Deliverables:** All features work or degrade gracefully on web

### Step 11.3: Demo Data
**Spec:** `specs/10-web-demo.md` Section 3

- [ ] Create rich demo dataset
- [ ] Include sample forays (society, group, solo)
- [ ] Include diverse observations
- [ ] Include sample photos (bundled assets)
- [ ] Pre-seed authenticated demo user

**Deliverables:** Compelling demo content

### Step 11.4: Portfolio Integration
**Spec:** `specs/10-web-demo.md` Section 4

- [ ] Deploy to static hosting (Vercel/Netlify)
- [ ] Create phone frame mockup (CSS)
- [ ] Embed Flutter web in iframe
- [ ] Add landing page with app description
- [ ] Add links to GitHub repo (if public)

**Deliverables:** Live portfolio demo

### Step 11.5: Demo Polish
**Spec:** `specs/10-web-demo.md` Section 5

- [ ] Test full demo flow
- [ ] Optimize loading experience
- [ ] Add loading splash screen
- [ ] Test on multiple browsers
- [ ] Test responsive behavior

**Deliverables:** Polished web demo experience

---

## Dependencies Graph

```
Phase 1 (Foundation)
    │
    ▼
Phase 2 (Database)
    │
    ▼
Phase 3 (Auth)
    │
    ▼
Phase 4 (Forays)
    │
    ▼
Phase 5 (Observations) ───────┬───────────────┐
    │                         │               │
    ▼                         ▼               ▼
Phase 6 (Collaboration)   Phase 7 (Navigation)  Phase 8 (Maps)
    │                         │               │
    └─────────────────────────┼───────────────┘
                              │
                              ▼
                      Phase 9 (Sync)
                              │
                              ▼
                      Phase 10 (Polish)
                              │
                              ▼
                      Phase 11 (Web Demo)
```

---

## Estimated Timeline

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Phase 1: Foundation | 5-7 days | Week 1 |
| Phase 2: Database | 4-5 days | Week 2 |
| Phase 3: Auth | 4-5 days | Week 3 |
| Phase 4: Forays | 5-6 days | Week 4 |
| Phase 5: Observations | 6-7 days | Week 5-6 |
| Phase 6: Collaboration | 5-6 days | Week 6-7 |
| Phase 7: Navigation | 4-5 days | Week 7-8 |
| Phase 8: Maps | 4-5 days | Week 8-9 |
| Phase 9: Sync | 5-6 days | Week 9-10 |
| Phase 10: Polish | 3-4 days | Week 10-11 |
| Phase 11: Web Demo | 3-4 days | Week 11-12 |

**Total:** ~10-12 weeks

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Species database integration complexity | Start with simple local list; iterate to full API |
| Compass calibration UX | Follow platform guidelines; test on multiple devices |
| Sync conflicts | Start with simple last-write-wins; add conflict UI if needed |
| Web performance | Profile early; defer loading where possible |
| Supabase real-time reliability | Implement fallback polling; handle disconnections |

---

## Success Criteria

Each phase is complete when:
1. All checklist items are done
2. Unit tests pass for new code
3. Manual QA verifies functionality
4. No regressions in existing features
5. Code reviewed and merged to main branch

---

*This work plan should be used in conjunction with the detailed specifications in the `specs/` directory.*
