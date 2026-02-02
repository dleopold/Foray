# Development Workflow

This document describes the recommended development workflow for Foray.

## Overview

Foray is a mobile-first application targeting iOS and Android. The development workflow is optimized for fast iteration without requiring release builds locally.

| Task | Tool |
|------|------|
| UI iteration | Web mode (fastest hot reload) |
| Mobile features | Physical Android device |
| iOS testing | macOS + physical device, or CI |
| Release builds | CI only (GitHub Actions) |
| Build verification | CI only |

## Local Development

### 1. Web Mode (Fast UI Iteration)

Use web mode for rapid UI development. Hot reload is fastest here.

```bash
flutter run -d chrome --web-port=8080
```

Or with the alias:
```bash
source scripts/dev-aliases.sh
foray-web
```

**Best for:**
- Layout and styling work
- State management logic
- Navigation flows
- Anything that doesn't need real sensors

**Limitations:**
| Feature | Web Behavior |
|---------|--------------|
| Camera | Simulated / not available |
| GPS | Browser geolocation (less accurate) |
| Compass | Not available |
| Offline mode | IndexedDB (different from SQLite) |

### 2. Physical Android Device (Real Features)

Use a physical Android phone for testing sensor-dependent features.

**Why physical device over emulator:**
- Real camera, GPS, compass
- Accurate performance characteristics
- Real network conditions
- Real battery/memory constraints

**Setup (USB):**
1. Enable Developer Options on your phone
2. Enable USB Debugging
3. Connect via USB
4. Verify connection:
   ```bash
   flutter devices
   ```
5. Run:
   ```bash
   flutter run -d <device-id>
   ```

**Setup (Wireless - Android 11+):**
```bash
# One-time pairing
adb pair <ip>:<pairing-port>

# Connect
adb connect <ip>:<port>

# Run
flutter run -d <device-id>
```

**Best for:**
- Camera functionality
- GPS/location features
- Compass/navigation
- Offline mode testing
- Performance testing

### 3. iOS Development (macOS Required)

iOS development requires macOS with Xcode installed.

```bash
flutter run -d ios
```

If you don't have a Mac:
- CI verifies iOS builds on every PR
- Test on Android (most features are cross-platform)
- Use TestFlight for iOS-specific testing

## CI/CD (GitHub Actions)

Release builds happen in CI, not locally. This ensures:
- Consistent build environment
- Build verification on every PR
- No local toolchain requirements

### What CI Does

On every push/PR:
1. **Analyze** - `flutter analyze`
2. **Test** - `flutter test`
3. **Build Android** - `flutter build apk --release`
4. **Build iOS** - `flutter build ios --release --no-codesign`
5. **Build Web** - `flutter build web`

If CI passes, the code is releasable.

### Artifacts

CI uploads build artifacts:
- `app-release.apk` - Android release build

## Recommended Daily Workflow

```
1. Write code
2. Test in web mode (fast iteration)
3. Test on physical Android device (real features)
4. Run tests locally: flutter test
5. Push to branch
6. CI verifies all builds pass
7. Merge when CI green
```

## Commands Reference

```bash
# Source aliases
source scripts/dev-aliases.sh

# Development
foray-web        # Run in Chrome
foray-android    # Run on Android device
foray-ios        # Run on iOS device (macOS only)

# Testing
foray-test       # Run all tests
flutter analyze  # Check for issues

# Code generation
foray-build      # Run build_runner

# Cleanup
foray-clean      # Clean build artifacts
```

## Environment Setup

### Required
- Flutter SDK
- Chrome (for web development)
- Android device with USB debugging enabled

### Optional
- Android Studio (for Android emulator)
- macOS + Xcode (for iOS development)

### Environment Variables

Create a `.env` file or export:
```bash
export SUPABASE_URL="your-project-url"
export SUPABASE_ANON_KEY="your-anon-key"
```

## Troubleshooting

### Device not detected
```bash
flutter devices  # List connected devices
adb devices      # List ADB devices (Android)
```

### Hot reload not working
- Check device connection
- Try `flutter clean && flutter pub get`
- Restart the app with `flutter run`

### Build failures
- CI handles release builds - check CI logs
- For local issues: `flutter doctor -v`
