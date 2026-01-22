# Specification: Web Demo

**Phase:** 11  
**Estimated Duration:** 3-4 days  
**Dependencies:** Phase 10 complete  
**Patterns & Pitfalls:** See `PATTERNS_AND_PITFALLS.md` — [Cross-Platform Considerations](#8-cross-platform-considerations)

---

## 1. Web Build Configuration

### 1.1 Flutter Web Setup

```bash
# Enable web support if not already enabled
flutter config --enable-web

# Build for web
flutter build web --release --web-renderer canvaskit
```

### 1.2 Build Optimization

In `web/index.html`, add loading indicator:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Foray - Mycological Field Collection</title>
  <link rel="manifest" href="manifest.json">
  <style>
    .loading {
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      background: #F8F6F3;
    }
    .loading-spinner {
      width: 50px;
      height: 50px;
      border: 4px solid #E0DCD5;
      border-top: 4px solid #D4843E;
      border-radius: 50%;
      animation: spin 1s linear infinite;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  </style>
</head>
<body>
  <div class="loading" id="loading">
    <div class="loading-spinner"></div>
  </div>
  <script src="flutter.js" defer></script>
  <script>
    window.addEventListener('load', function() {
      _flutter.loader.loadEntrypoint({
        onEntrypointLoaded: async function(engineInitializer) {
          let appRunner = await engineInitializer.initializeEngine();
          document.getElementById('loading').remove();
          await appRunner.runApp();
        }
      });
    });
  </script>
</body>
</html>
```

### 1.3 Web-Specific Configuration

```dart
// lib/core/config/platform_config.dart
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class PlatformConfig {
  static bool get isWeb => kIsWeb;
  
  static bool get supportsCamera => !kIsWeb;
  static bool get supportsGPS => !kIsWeb;
  static bool get supportsCompass => !kIsWeb;
  static bool get supportsPushNotifications => !kIsWeb;
  
  // Web uses IndexedDB via Drift
  static bool get supportsLocalDatabase => true;
}
```

---

## 2. Feature Adaptation

### 2.1 Platform-Aware Camera Service

```dart
// lib/services/camera/camera_service.dart (updated)
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:foray/core/config/platform_config.dart';

class CameraService {
  final _picker = ImagePicker();

  Future<File?> capturePhoto() async {
    if (!PlatformConfig.supportsCamera) {
      // On web, fall back to file picker
      return pickFromGallery();
    }
    
    // Native camera implementation
    // ...existing code...
  }

  Future<File?> pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );

    if (xFile == null) return null;

    // On web, XFile handles the abstraction
    if (kIsWeb) {
      // Return XFile-backed pseudo-File for web
      return _WebFile(xFile);
    }

    return File(xFile.path);
  }
}

// Web-compatible file wrapper
class _WebFile implements File {
  _WebFile(this._xFile);
  final XFile _xFile;

  @override
  String get path => _xFile.path;

  @override
  Future<List<int>> readAsBytes() => _xFile.readAsBytes();

  // Implement other File methods as needed...
  // Many can throw UnsupportedError for web
}
```

### 2.2 Simulated GPS for Web

```dart
// lib/services/location/location_service.dart (updated)
import 'package:foray/core/config/platform_config.dart';

class LocationService {
  // Simulated location for web demo (Seattle area)
  static final _simulatedPositions = [
    _SimulatedPosition(47.6062, -122.3321, 'Seattle Center'),
    _SimulatedPosition(47.6205, -122.3493, 'Space Needle'),
    _SimulatedPosition(47.6076, -122.3420, 'Pike Place'),
  ];
  
  int _simulatedIndex = 0;

  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.best,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!PlatformConfig.supportsGPS) {
      // Return simulated position for web
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
      final simulated = _simulatedPositions[_simulatedIndex];
      _simulatedIndex = (_simulatedIndex + 1) % _simulatedPositions.length;
      
      return Position(
        latitude: simulated.lat,
        longitude: simulated.lon,
        accuracy: 10.0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        timestamp: DateTime.now(),
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }

    // Native GPS implementation
    // ...existing code...
  }
}

class _SimulatedPosition {
  final double lat;
  final double lon;
  final String name;
  
  _SimulatedPosition(this.lat, this.lon, this.name);
}
```

### 2.3 Simulated Compass for Web

```dart
// lib/services/compass/compass_service.dart (updated)
import 'dart:async';
import 'dart:math';
import 'package:foray/core/config/platform_config.dart';

class CompassService {
  Timer? _simulationTimer;
  double _simulatedHeading = 0;
  final _random = Random();

  void startListening() {
    if (!PlatformConfig.supportsCompass) {
      // Simulate compass movement for web demo
      _simulationTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => _simulateHeadingChange(),
      );
      return;
    }

    // Native compass implementation
    // ...existing code...
  }

  void _simulateHeadingChange() {
    // Gentle random walk for realistic feel
    _simulatedHeading += (_random.nextDouble() - 0.5) * 5;
    _simulatedHeading = _simulatedHeading % 360;
    if (_simulatedHeading < 0) _simulatedHeading += 360;
    
    _headingController.add(_simulatedHeading);
  }

  void stopListening() {
    _simulationTimer?.cancel();
    // ...existing code...
  }
}
```

### 2.4 Drift Web Configuration

Drift uses `IndexedDB` on web automatically, but ensure the database is properly configured:

```dart
// lib/database/database.dart (web support)
import 'package:drift/drift.dart';
import 'package:drift/web.dart' show WebDatabase;
import 'package:flutter/foundation.dart' show kIsWeb;

LazyDatabase _openConnection() {
  if (kIsWeb) {
    return LazyDatabase(() async {
      return WebDatabase('foray_db');
    });
  }
  
  // Native implementation
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'foray.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

---

## 3. Demo Data

### 3.1 Web Demo Seeder

```dart
// lib/database/web_demo_seeder.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:foray/database/database.dart';
import 'package:foray/database/mock_data_seeder.dart';

class WebDemoSeeder {
  static Future<void> seedIfNeeded(AppDatabase db) async {
    if (!kIsWeb) return;

    // Check if already seeded
    final users = await db.usersDao.getCurrentUser();
    if (users != null) return;

    // Seed demo data
    final seeder = MockDataSeeder(db);
    await seeder.seedAll();

    // Add welcome observation at top
    await _addWelcomeObservation(db);
  }

  static Future<void> _addWelcomeObservation(AppDatabase db) async {
    // Create a special "welcome" observation to orient demo users
    // ...implementation...
  }
}
```

### 3.2 Bundled Demo Assets

Create demo images in `assets/images/demo/`:
- `chanterelle_1.jpg`
- `chanterelle_2.jpg`
- `amanita_1.jpg`
- `boletus_1.jpg`
- `laetiporus_1.jpg`
- ... (10-15 sample mushroom photos)

Reference in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/demo/
```

---

## 4. Portfolio Integration

### 4.1 Deployment Configuration

**Vercel (`vercel.json`):**
```json
{
  "version": 2,
  "builds": [
    {
      "src": "build/web/**",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/build/web/$1"
    }
  ]
}
```

**Netlify (`netlify.toml`):**
```toml
[build]
  publish = "build/web"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### 4.2 Phone Frame Mockup

```html
<!-- Portfolio landing page -->
<!DOCTYPE html>
<html>
<head>
  <title>Foray - Mycological Field Collection App</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      margin: 0;
      padding: 40px;
      background: linear-gradient(135deg, #F8F6F3 0%, #E8E4DE 100%);
      min-height: 100vh;
    }
    
    .container {
      max-width: 1200px;
      margin: 0 auto;
      display: flex;
      gap: 60px;
      align-items: center;
    }
    
    .content {
      flex: 1;
    }
    
    .content h1 {
      font-size: 48px;
      color: #2C2416;
      margin-bottom: 16px;
    }
    
    .content p {
      font-size: 18px;
      color: #6B5D4D;
      line-height: 1.6;
    }
    
    .phone-frame {
      width: 375px;
      height: 812px;
      background: #1a1a1a;
      border-radius: 50px;
      padding: 14px;
      box-shadow: 0 25px 50px rgba(0,0,0,0.25);
    }
    
    .phone-screen {
      width: 100%;
      height: 100%;
      border-radius: 38px;
      overflow: hidden;
      background: white;
    }
    
    .phone-screen iframe {
      width: 100%;
      height: 100%;
      border: none;
    }
    
    .cta-buttons {
      margin-top: 32px;
      display: flex;
      gap: 16px;
    }
    
    .cta-button {
      padding: 16px 32px;
      border-radius: 12px;
      font-size: 16px;
      font-weight: 600;
      text-decoration: none;
      transition: transform 0.2s;
    }
    
    .cta-button:hover {
      transform: translateY(-2px);
    }
    
    .cta-primary {
      background: #D4843E;
      color: white;
    }
    
    .cta-secondary {
      background: white;
      color: #2C2416;
      border: 2px solid #E0DCD5;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="content">
      <h1>Foray</h1>
      <p>
        A beautiful, offline-first mobile app for documenting fungal collections in the field.
        Whether you're organizing a mycological society foray or building your personal
        mushroom map, Foray makes it effortless.
      </p>
      <p>
        <strong>Key Features:</strong> Offline-first design, GPS navigation back to your spots,
        collaborative forays with live updates, privacy controls for sensitive locations.
      </p>
      <div class="cta-buttons">
        <a href="#" class="cta-button cta-primary">View on App Store</a>
        <a href="https://github.com/yourname/foray" class="cta-button cta-secondary">View Source</a>
      </div>
    </div>
    <div class="phone-frame">
      <div class="phone-screen">
        <iframe src="/demo/index.html"></iframe>
      </div>
    </div>
  </div>
</body>
</html>
```

---

## 5. Demo Polish

### 5.1 Demo Mode Banner

```dart
// lib/core/widgets/demo_mode_banner.dart
import 'package:flutter/material.dart';
import 'package:foray/core/config/platform_config.dart';
import 'package:foray/core/theme/app_spacing.dart';

class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!PlatformConfig.isWeb) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Demo Mode - Some features simulated',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
```

### 5.2 Feature Flags for Demo

```dart
// lib/core/config/demo_config.dart
import 'package:foray/core/config/platform_config.dart';

abstract class DemoConfig {
  static bool get showDemoBanner => PlatformConfig.isWeb;
  static bool get useSimulatedLocation => PlatformConfig.isWeb;
  static bool get useSimulatedCompass => PlatformConfig.isWeb;
  static bool get useMockPhotos => PlatformConfig.isWeb;
  static bool get skipAuth => PlatformConfig.isWeb;
  static bool get preSeedData => PlatformConfig.isWeb;
}
```

---

## 6. Testing Checklist

### 6.1 Browser Compatibility

Test on:
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)
- [ ] Mobile Safari (iOS)
- [ ] Mobile Chrome (Android)

### 6.2 Demo Flow Verification

- [ ] App loads within 5 seconds
- [ ] Demo data is visible
- [ ] Navigation between screens works
- [ ] Foray list shows sample forays
- [ ] Observation entry works (with file picker)
- [ ] Map displays correctly
- [ ] Compass animation is smooth
- [ ] Dark mode toggle works
- [ ] All UI is responsive and doesn't overflow

---

## Acceptance Criteria

Phase 11 is complete when:

1. [ ] Flutter web builds successfully
2. [ ] App loads and runs in browser
3. [ ] Demo data is pre-seeded on launch
4. [ ] Camera falls back to file picker
5. [ ] GPS shows simulated coordinates
6. [ ] Compass shows animated simulation
7. [ ] Map displays with markers
8. [ ] All navigation flows work
9. [ ] Deployed to static hosting
10. [ ] Portfolio landing page shows phone mockup
11. [ ] Works in all major browsers
12. [ ] Loading time < 5 seconds on 3G
