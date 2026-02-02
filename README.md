# Foray

Foray is a cross-platform mobile application for documenting fungal collections in the field.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android phone with USB debugging enabled
- [Supabase](https://supabase.com/) account and project

### Setup

1. **Clone the repository**

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate database code**
   ```bash
   dart run build_runner build
   ```

4. **Environment Variables**
   Create a `.env` file or export:
   ```bash
   export SUPABASE_URL="your-project-url"
   export SUPABASE_ANON_KEY="your-anon-key"
   ```

5. **Source development aliases**
   ```bash
   source scripts/dev-aliases.sh
   ```

## Development Workflow

| Task | Command |
|------|---------|
| UI iteration (fast) | `foray-web` |
| Test real features | `foray-android` (physical device) |
| Run tests | `foray-test` |
| iOS development | `foray-ios` (macOS only) |

### Recommended Approach

1. **Web mode** for fast UI iteration (hot reload is fastest)
2. **Physical Android device** for testing camera, GPS, compass
3. **CI** handles all release builds - no local builds needed

```bash
# Quick UI work
foray-web

# Test with real sensors
foray-android

# Run tests before pushing
foray-test
```

### Why Physical Device?

Foray relies heavily on hardware features (camera, GPS, compass). Emulators simulate these poorly. A physical Android phone gives you:
- Real camera for photo capture
- Actual GPS for location accuracy
- Working compass for navigation features
- True offline behavior

### iOS Development

Requires macOS with Xcode. If you don't have a Mac:
- CI verifies iOS builds on every PR
- Most features work identically on Android
- Use TestFlight for iOS-specific testing

## CI/CD

GitHub Actions runs on every push/PR:
- `flutter analyze` - Static analysis
- `flutter test` - Unit tests
- `flutter build apk` - Android build
- `flutter build ios` - iOS build (macos runner)

**You don't need to build releases locally.** If CI passes, the code is releasable.

## Commands Reference

```bash
source scripts/dev-aliases.sh

foray-web        # Run in Chrome (fast iteration)
foray-android    # Run on Android device
foray-ios        # Run on iOS (macOS only)
foray-test       # Run all tests
foray-build      # Generate code (build_runner)
foray-clean      # Clean build artifacts
```

## Documentation

- [Development Workflow](docs/DEVELOPMENT.md) - Detailed development guide
- [AGENTS.md](AGENTS.md) - AI agent instructions
- [specs/](specs/) - Feature specifications

## Project Structure

```
lib/
├── core/           # Shared utilities, theme, widgets
├── features/       # Feature modules (auth, forays, observations, etc.)
├── database/       # Drift database, tables, DAOs
├── services/       # Platform services (location, camera, etc.)
└── routing/        # GoRouter configuration
```
