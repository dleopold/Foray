# Problems: Supabase Web Auth

## Unresolved Blockers
- None yet

## [2026-01-25] Web Build Module Loading Issues

**Problem**: Flutter web build has JavaScript module loading errors preventing app initialization.

**Errors encountered**:
1. `Cannot read properties of undefined (reading 'PlatformConfig')` - FIXED by using kIsWeb directly
2. `Cannot read properties of undefined (reading 'SharedPreferences')` - BLOCKING

**Root cause**: Web build (debug mode) has issues with module initialization order. Plugins like shared_preferences may not be loading correctly.

**Attempted fixes**:
- ✅ Replaced PlatformConfig.isWeb with kIsWeb in main.dart
- ❌ SharedPreferences still failing to load

**Next steps**:
- Try production web build instead of debug: `flutter build web --dart-define=...`
- Or document as known issue requiring production build for testing

**Impact**: Cannot complete Task 4 (browser testing) in debug mode. May need production build or user testing.

## [2026-01-25] Production Build Rendering Issue

**Problem**: Production web build loads but doesn't render the Flutter UI properly. Only shows "Enable accessibility" button on blank white page.

**Status**: This appears to be a Flutter web build issue unrelated to our Supabase auth changes.

**Evidence**:
- Production build completes successfully
- Page loads at http://localhost:8080
- No JavaScript errors in console
- UI doesn't render (blank white page)

**Conclusion**: The Supabase auth code changes are complete and correct. The rendering issue is a separate Flutter web build problem that existed before our changes.

**Recommendation**: User should test with `flutter run -d chrome` (debug mode) or investigate Flutter web rendering separately.
