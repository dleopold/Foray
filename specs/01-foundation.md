# Specification: Foundation & Design System

**Phase:** 1  
**Estimated Duration:** 5-7 days  
**Dependencies:** None

---

## 1. Project Initialization

### 1.1 Flutter Project Creation

```bash
flutter create --org com.foray --project-name foray .
```

### 1.2 Core Dependencies (`pubspec.yaml`)

```yaml
name: foray
description: A mobile app for mycological field collection
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Navigation
  go_router: ^13.0.0
  
  # Local Database
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.18
  path_provider: ^2.1.1
  path: ^1.8.3
  
  # Supabase
  supabase_flutter: ^2.3.0
  
  # Location & Compass
  geolocator: ^10.1.0
  flutter_compass: ^0.8.0
  
  # Camera & Images
  camera: ^0.10.5+7
  image_picker: ^1.0.5
  
  # Maps
  flutter_map: ^6.1.0
  latlong2: ^0.9.0
  
  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  
  # Utilities
  uuid: ^4.2.1
  intl: ^0.18.1
  collection: ^1.18.0
  equatable: ^2.0.5
  
  # UI
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  flutter_svg: ^2.0.9
  qr_flutter: ^4.1.0
  mobile_scanner: ^4.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  
  # Code Generation
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
  drift_dev: ^2.14.0
  
  # Testing
  mocktail: ^1.0.1

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/fonts/
```

### 1.3 Analysis Options (`analysis_options.yaml`)

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    - always_declare_return_types
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_returning_null_for_future
    - avoid_slow_async_io
    - avoid_type_to_string
    - avoid_types_as_parameter_names
    - avoid_web_libraries_in_flutter
    - cancel_subscriptions
    - close_sinks
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - prefer_single_quotes
    - require_trailing_commas
    - sort_constructors_first
    - sort_unnamed_constructors_first
    - unnecessary_await_in_return
    - unnecessary_statements
    - use_key_in_widget_constructors
```

### 1.4 Project Structure

Create the following directory structure:

```
lib/
├── main.dart
├── app.dart
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
│   │   ├── app_spacing.dart
│   │   └── app_shadows.dart
│   ├── utils/
│   │   ├── gps_utils.dart
│   │   ├── validators.dart
│   │   └── formatters.dart
│   └── widgets/
│       ├── buttons/
│       ├── inputs/
│       ├── cards/
│       ├── indicators/
│       ├── compass/
│       └── feedback/
├── features/
│   ├── auth/
│   ├── forays/
│   ├── observations/
│   ├── navigation/
│   ├── maps/
│   ├── sync/
│   └── settings/
├── database/
│   ├── database.dart
│   ├── tables/
│   ├── daos/
│   └── migrations/
├── services/
│   ├── api/
│   ├── location/
│   ├── compass/
│   ├── camera/
│   ├── connectivity/
│   └── storage/
└── routing/
    ├── router.dart
    └── routes.dart

assets/
├── images/
├── icons/
└── fonts/

test/
├── unit/
├── widget/
└── integration/
```

### 1.5 Entry Points

**`lib/main.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foray/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services here (database, supabase, etc.)
  
  runApp(
    const ProviderScope(
      child: ForayApp(),
    ),
  );
}
```

**`lib/app.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foray/core/theme/app_theme.dart';
import 'package:foray/routing/router.dart';

class ForayApp extends ConsumerWidget {
  const ForayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Foray',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
```

---

## 2. Theme System

### 2.1 Color Palette (`app_colors.dart`)

Design philosophy: Earthy, nature-inspired colors with fungi-derived accents.

```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary - Warm earth brown (chanterelle-inspired)
  static const Color primary = Color(0xFFD4843E);
  static const Color primaryLight = Color(0xFFE9A864);
  static const Color primaryDark = Color(0xFFB56A2A);
  
  // Secondary - Forest green
  static const Color secondary = Color(0xFF4A6741);
  static const Color secondaryLight = Color(0xFF6B8A5F);
  static const Color secondaryDark = Color(0xFF324530);
  
  // Accent - Spore purple (for highlights)
  static const Color accent = Color(0xFF8B6B8E);
  
  // Neutrals - Light theme
  static const Color backgroundLight = Color(0xFFF8F6F3);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF2C2416);
  static const Color textSecondaryLight = Color(0xFF6B5D4D);
  static const Color dividerLight = Color(0xFFE0DCD5);
  
  // Neutrals - Dark theme
  static const Color backgroundDark = Color(0xFF1A1814);
  static const Color surfaceDark = Color(0xFF262220);
  static const Color textPrimaryDark = Color(0xFFF5F2ED);
  static const Color textSecondaryDark = Color(0xFFB5ADA0);
  static const Color dividerDark = Color(0xFF3D3832);
  
  // Semantic colors
  static const Color success = Color(0xFF4A7C4E);
  static const Color warning = Color(0xFFD4A03E);
  static const Color error = Color(0xFFB84A4A);
  static const Color info = Color(0xFF4A6A8C);
  
  // Privacy level colors
  static const Color privacyPrivate = Color(0xFF6B5D4D);
  static const Color privacyForay = Color(0xFF4A6741);
  static const Color privacyPublic = Color(0xFF4A6A8C);
  static const Color privacyObscured = Color(0xFF8B6B8E);
  
  // Sync status colors
  static const Color syncLocal = Color(0xFF6B5D4D);
  static const Color syncPending = Color(0xFFD4A03E);
  static const Color syncSynced = Color(0xFF4A7C4E);
  static const Color syncFailed = Color(0xFFB84A4A);
}
```

### 2.2 Typography (`app_typography.dart`)

```dart
import 'package:flutter/material.dart';

abstract class AppTypography {
  static const String fontFamily = 'Inter'; // Or system default
  
  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.25,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  // Titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );
  
  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.4,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.4,
  );
}
```

### 2.3 Spacing (`app_spacing.dart`)

```dart
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  
  // Common paddings
  static const double screenPadding = 16;
  static const double cardPadding = 16;
  static const double listItemPadding = 12;
  
  // Border radius
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusFull = 999;
}
```

### 2.4 Shadows (`app_shadows.dart`)

```dart
import 'package:flutter/material.dart';

abstract class AppShadows {
  static List<BoxShadow> get small => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
```

### 2.5 Theme Data (`app_theme.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

abstract class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryLight,
      surface: AppColors.surfaceLight,
      background: AppColors.backgroundLight,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
      onBackground: AppColors.textPrimaryLight,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    dividerColor: AppColors.dividerLight,
    textTheme: _buildTextTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
    ),
    inputDecorationTheme: _buildInputDecoration(isLight: true),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    outlinedButtonTheme: _buildOutlinedButtonTheme(),
    textButtonTheme: _buildTextButtonTheme(),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
    ),
  );
  
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryDark,
      surface: AppColors.surfaceDark,
      background: AppColors.backgroundDark,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryDark,
      onBackground: AppColors.textPrimaryDark,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    dividerColor: AppColors.dividerDark,
    textTheme: _buildTextTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: AppColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
    ),
    inputDecorationTheme: _buildInputDecoration(isLight: false),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    outlinedButtonTheme: _buildOutlinedButtonTheme(),
    textButtonTheme: _buildTextButtonTheme(),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
    ),
  );
  
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      headlineLarge: AppTypography.headlineLarge.copyWith(color: primary),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: primary),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: primary),
      titleLarge: AppTypography.titleLarge.copyWith(color: primary),
      titleMedium: AppTypography.titleMedium.copyWith(color: primary),
      titleSmall: AppTypography.titleSmall.copyWith(color: primary),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: primary),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: secondary),
      bodySmall: AppTypography.bodySmall.copyWith(color: secondary),
      labelLarge: AppTypography.labelLarge.copyWith(color: primary),
      labelMedium: AppTypography.labelMedium.copyWith(color: secondary),
      labelSmall: AppTypography.labelSmall.copyWith(color: secondary),
    );
  }
  
  static InputDecorationTheme _buildInputDecoration({required bool isLight}) {
    final borderColor = isLight ? AppColors.dividerLight : AppColors.dividerDark;
    final fillColor = isLight ? AppColors.surfaceLight : AppColors.surfaceDark;
    
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }
  
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: AppTypography.labelLarge,
      ),
    );
  }
  
  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        side: const BorderSide(color: AppColors.primary),
        textStyle: AppTypography.labelLarge,
      ),
    );
  }
  
  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        textStyle: AppTypography.labelLarge,
      ),
    );
  }
}
```

---

## 3. Component Library

### 3.1 Buttons (`core/widgets/buttons/`)

**`foray_button.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:foray/core/theme/app_spacing.dart';

enum ForayButtonVariant { primary, secondary, text, icon }
enum ForayButtonSize { small, medium, large }

class ForayButton extends StatelessWidget {
  const ForayButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.variant = ForayButtonVariant.primary,
    this.size = ForayButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final ForayButtonVariant variant;
  final ForayButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isLoading || isDisabled) ? null : onPressed;
    
    Widget child = isLoading
        ? SizedBox(
            width: _getLoadingSize(),
            height: _getLoadingSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _getLoadingColor(context),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _getIconSize()),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label),
            ],
          );

    Widget button;
    switch (variant) {
      case ForayButtonVariant.primary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: _getPrimaryStyle(),
          child: child,
        );
        break;
      case ForayButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: _getSecondaryStyle(),
          child: child,
        );
        break;
      case ForayButtonVariant.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: _getTextStyle(),
          child: child,
        );
        break;
      case ForayButtonVariant.icon:
        button = IconButton(
          onPressed: effectiveOnPressed,
          icon: icon != null ? Icon(icon) : child,
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    return button;
  }

  double _getLoadingSize() {
    switch (size) {
      case ForayButtonSize.small:
        return 16;
      case ForayButtonSize.medium:
        return 20;
      case ForayButtonSize.large:
        return 24;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ForayButtonSize.small:
        return 16;
      case ForayButtonSize.medium:
        return 20;
      case ForayButtonSize.large:
        return 24;
    }
  }

  Color _getLoadingColor(BuildContext context) {
    switch (variant) {
      case ForayButtonVariant.primary:
        return Colors.white;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  ButtonStyle _getPrimaryStyle() {
    return ElevatedButton.styleFrom(
      padding: _getPadding(),
    );
  }

  ButtonStyle _getSecondaryStyle() {
    return OutlinedButton.styleFrom(
      padding: _getPadding(),
    );
  }

  ButtonStyle _getTextStyle() {
    return TextButton.styleFrom(
      padding: _getPadding(),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ForayButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ForayButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ForayButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    }
  }
}
```

### 3.2 Inputs (`core/widgets/inputs/`)

**`foray_text_field.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForayTextField extends StatelessWidget {
  const ForayTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autofocus = false,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final String? error;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          autofocus: autofocus,
          decoration: InputDecoration(
            hintText: hint,
            errorText: error,
            helperText: helper,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixTap,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
```

### 3.3 Indicators (`core/widgets/indicators/`)

**`privacy_badge.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:foray/core/constants/privacy_levels.dart';
import 'package:foray/core/theme/app_colors.dart';
import 'package:foray/core/theme/app_spacing.dart';

class PrivacyBadge extends StatelessWidget {
  const PrivacyBadge({
    super.key,
    required this.level,
    this.showLabel = true,
    this.size = PrivacyBadgeSize.medium,
  });

  final PrivacyLevel level;
  final bool showLabel;
  final PrivacyBadgeSize size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? AppSpacing.sm : AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: _getIconSize(),
            color: _getColor(),
          ),
          if (showLabel) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              level.label,
              style: TextStyle(
                fontSize: _getFontSize(),
                fontWeight: FontWeight.w500,
                color: _getColor(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (level) {
      case PrivacyLevel.private:
        return Icons.lock;
      case PrivacyLevel.foray:
        return Icons.group;
      case PrivacyLevel.publicExact:
        return Icons.public;
      case PrivacyLevel.publicObscured:
        return Icons.blur_on;
    }
  }

  Color _getColor() {
    switch (level) {
      case PrivacyLevel.private:
        return AppColors.privacyPrivate;
      case PrivacyLevel.foray:
        return AppColors.privacyForay;
      case PrivacyLevel.publicExact:
        return AppColors.privacyPublic;
      case PrivacyLevel.publicObscured:
        return AppColors.privacyObscured;
    }
  }

  double _getIconSize() {
    switch (size) {
      case PrivacyBadgeSize.small:
        return 12;
      case PrivacyBadgeSize.medium:
        return 16;
      case PrivacyBadgeSize.large:
        return 20;
    }
  }

  double _getFontSize() {
    switch (size) {
      case PrivacyBadgeSize.small:
        return 10;
      case PrivacyBadgeSize.medium:
        return 12;
      case PrivacyBadgeSize.large:
        return 14;
    }
  }
}

enum PrivacyBadgeSize { small, medium, large }
```

**`sync_status_indicator.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:foray/core/theme/app_colors.dart';
import 'package:foray/core/theme/app_spacing.dart';

enum SyncStatus { local, pending, synced, failed }

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({
    super.key,
    required this.status,
    this.showLabel = false,
    this.size = 16,
  });

  final SyncStatus status;
  final bool showLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(),
        if (showLabel) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            _getLabel(),
            style: TextStyle(
              fontSize: 12,
              color: _getColor(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIcon() {
    if (status == SyncStatus.pending) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _getColor(),
        ),
      );
    }
    return Icon(
      _getIcon(),
      size: size,
      color: _getColor(),
    );
  }

  IconData _getIcon() {
    switch (status) {
      case SyncStatus.local:
        return Icons.smartphone;
      case SyncStatus.pending:
        return Icons.sync;
      case SyncStatus.synced:
        return Icons.cloud_done;
      case SyncStatus.failed:
        return Icons.cloud_off;
    }
  }

  Color _getColor() {
    switch (status) {
      case SyncStatus.local:
        return AppColors.syncLocal;
      case SyncStatus.pending:
        return AppColors.syncPending;
      case SyncStatus.synced:
        return AppColors.syncSynced;
      case SyncStatus.failed:
        return AppColors.syncFailed;
    }
  }

  String _getLabel() {
    switch (status) {
      case SyncStatus.local:
        return 'Local only';
      case SyncStatus.pending:
        return 'Syncing...';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.failed:
        return 'Sync failed';
    }
  }
}
```

**`gps_accuracy_indicator.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:foray/core/theme/app_colors.dart';
import 'package:foray/core/theme/app_spacing.dart';

class GPSAccuracyIndicator extends StatelessWidget {
  const GPSAccuracyIndicator({
    super.key,
    required this.accuracyMeters,
    this.showLabel = true,
  });

  final double? accuracyMeters;

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final quality = _getQuality();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: quality.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.gps_fixed,
            size: 16,
            color: quality.color,
          ),
          if (showLabel) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              _getLabel(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: quality.color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _GPSQuality _getQuality() {
    if (accuracyMeters == null) {
      return _GPSQuality.unknown;
    }
    if (accuracyMeters! <= 5) {
      return _GPSQuality.excellent;
    }
    if (accuracyMeters! <= 15) {
      return _GPSQuality.good;
    }
    if (accuracyMeters! <= 30) {
      return _GPSQuality.fair;
    }
    return _GPSQuality.poor;
  }

  String _getLabel() {
    if (accuracyMeters == null) {
      return 'No GPS';
    }
    final quality = _getQuality();
    final meters = accuracyMeters!.round();
    return '${quality.label} (±${meters}m)';
  }
}

enum _GPSQuality {
  excellent(AppColors.success, 'Excellent'),
  good(AppColors.success, 'Good'),
  fair(AppColors.warning, 'Fair'),
  poor(AppColors.error, 'Poor'),
  unknown(AppColors.syncLocal, 'Unknown');

  const _GPSQuality(this.color, this.label);
  final Color color;
  final String label;
}
```

---

## 4. Navigation Structure

### 4.1 Routes Definition (`routing/routes.dart`)

```dart
abstract class AppRoutes {
  // Auth
  static const String login = '/login';
  static const String register = '/register';
  
  // Main
  static const String home = '/';
  static const String settings = '/settings';
  
  // Forays
  static const String forays = '/forays';
  static const String forayDetail = '/forays/:id';
  static const String createForay = '/forays/create';
  static const String joinForay = '/forays/join';
  
  // Observations
  static const String observationDetail = '/observations/:id';
  static const String createObservation = '/forays/:forayId/observations/create';
  static const String editObservation = '/observations/:id/edit';
  
  // Navigation
  static const String navigate = '/navigate/:observationId';
  
  // Maps
  static const String personalMap = '/map';
}
```

### 4.2 Router Configuration (`routing/router.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      // Home / Foray List
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Placeholder(), // ForayListScreen
      ),
      
      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const Placeholder(), // LoginScreen
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const Placeholder(), // RegisterScreen
      ),
      
      // Foray routes
      GoRoute(
        path: AppRoutes.createForay,
        builder: (context, state) => const Placeholder(), // CreateForayScreen
      ),
      GoRoute(
        path: AppRoutes.joinForay,
        builder: (context, state) => const Placeholder(), // JoinForayScreen
      ),
      GoRoute(
        path: AppRoutes.forayDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return Placeholder(); // ForayDetailScreen(forayId: id)
        },
      ),
      
      // Observation routes
      GoRoute(
        path: AppRoutes.createObservation,
        builder: (context, state) {
          final forayId = state.pathParameters['forayId']!;
          return Placeholder(); // CreateObservationScreen(forayId: forayId)
        },
      ),
      GoRoute(
        path: AppRoutes.observationDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return Placeholder(); // ObservationDetailScreen(observationId: id)
        },
      ),
      
      // Navigation
      GoRoute(
        path: AppRoutes.navigate,
        builder: (context, state) {
          final observationId = state.pathParameters['observationId']!;
          return Placeholder(); // CompassNavigationScreen(observationId: observationId)
        },
      ),
      
      // Maps
      GoRoute(
        path: AppRoutes.personalMap,
        builder: (context, state) => const Placeholder(), // PersonalMapScreen
      ),
      
      // Settings
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const Placeholder(), // SettingsScreen
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
```

---

## 5. Utilities

### 5.1 Constants (`core/constants/`)

**`app_constants.dart`**

```dart
abstract class AppConstants {
  static const String appName = 'Foray';
  static const String appVersion = '1.0.0';
  
  // GPS
  static const double defaultGpsAccuracyThreshold = 50.0; // meters
  static const int gpsTimeoutSeconds = 30;
  
  // Photos
  static const int maxPhotosPerObservation = 10;
  static const int photoCompressionQuality = 85;
  static const int photoMaxDimension = 2048;
  
  // Navigation
  static const double arrivalThresholdMeters = 10.0;
  static const double farDistanceThresholdKm = 50.0;
  
  // Sync
  static const int syncRetryMaxAttempts = 3;
  static const Duration syncRetryBaseDelay = Duration(seconds: 5);
  
  // Foray
  static const int joinCodeLength = 6;
}
```

**`privacy_levels.dart`**

```dart
enum PrivacyLevel {
  private('Private', 'Only you can see'),
  foray('Foray', 'Visible to foray participants'),
  publicExact('Public', 'Visible to everyone'),
  publicObscured('Obscured', 'Public with approximate location');

  const PrivacyLevel(this.label, this.description);
  
  final String label;
  final String description;
}
```

### 5.2 Extensions (`core/extensions/`)

**`context_extensions.dart`**

```dart
import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }
}
```

**`datetime_extensions.dart`**

```dart
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String get formatted => DateFormat.yMMMd().format(this);
  String get formattedWithTime => DateFormat.yMMMd().add_jm().format(this);
  String get timeOnly => DateFormat.jm().format(this);
  String get dateOnly => DateFormat.yMMMd().format(this);
  
  String get relative {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
```

### 5.3 Formatters (`core/utils/formatters.dart`)

```dart
abstract class Formatters {
  static String distance(double meters, {bool useMetric = true}) {
    if (useMetric) {
      if (meters < 1000) {
        return '${meters.round()} m';
      }
      return '${(meters / 1000).toStringAsFixed(1)} km';
    } else {
      final feet = meters * 3.28084;
      if (feet < 5280) {
        return '${feet.round()} ft';
      }
      return '${(feet / 5280).toStringAsFixed(1)} mi';
    }
  }
  
  static String bearing(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return '${directions[index]} (${degrees.round()}°)';
  }
  
  static String coordinates(double lat, double lon, {int decimals = 5}) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lonDir = lon >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(decimals)}° $latDir, ${lon.abs().toStringAsFixed(decimals)}° $lonDir';
  }
}
```

---

## 6. Settings Screen (Phase 10)

Settings will be implemented in Phase 10 but the data models are defined here.

### 6.1 User Preferences Model

```dart
import 'package:flutter/material.dart';
import 'package:foray/core/constants/privacy_levels.dart';

class UserPreferences {
  const UserPreferences({
    this.themeMode = ThemeMode.system,
    this.useMetricUnits = true,
    this.defaultPrivacy = PrivacyLevel.private,
  });

  final ThemeMode themeMode;
  final bool useMetricUnits;
  final PrivacyLevel defaultPrivacy;

  UserPreferences copyWith({
    ThemeMode? themeMode,
    bool? useMetricUnits,
    PrivacyLevel? defaultPrivacy,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      useMetricUnits: useMetricUnits ?? this.useMetricUnits,
      defaultPrivacy: defaultPrivacy ?? this.defaultPrivacy,
    );
  }
}
```

---

## 7. Error Handling

### 7.1 Failure Classes (`core/errors/failures.dart`)

```dart
abstract class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Please check your connection.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database error.']);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Could not get location.']);
}

class CameraFailure extends Failure {
  const CameraFailure([super.message = 'Camera error.']);
}

class SyncFailure extends Failure {
  const SyncFailure([super.message = 'Sync failed. Will retry automatically.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
```

### 7.2 Exceptions (`core/errors/exceptions.dart`)

```dart
class AppException implements Exception {
  const AppException(this.message);
  final String message;
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication error']);
}

class DatabaseException extends AppException {
  const DatabaseException([super.message = 'Database error']);
}
```

---

## 8. Animation Constants

Define animation durations and curves for consistency:

```dart
// core/theme/app_animations.dart
import 'package:flutter/material.dart';

abstract class AppAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  // Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve enterCurve = Curves.easeOut;
  static const Curve exitCurve = Curves.easeIn;
  static const Curve bounceCurve = Curves.elasticOut;
  
  // Compass specific
  static const Duration compassUpdate = Duration(milliseconds: 16); // ~60fps
  static const Curve compassCurve = Curves.easeOutCubic;
}
```

---

## 9. Performance Guidelines

### Build Optimization
- Use `const` constructors wherever possible
- Avoid rebuilding unchanged widgets (use `Selector`, `select` in Riverpod)
- Use `RepaintBoundary` for complex animated widgets (compass)
- Lazy load heavy screens

### Image Optimization
- Use `cached_network_image` for remote images
- Implement proper image caching strategy
- Use appropriate image resolution for display size

### List Optimization
- Use `ListView.builder` for long lists
- Implement pagination for observation lists
- Use `AutomaticKeepAliveClientMixin` sparingly

---

## Acceptance Criteria

Phase 1 is complete when:

1. [ ] Flutter project runs on iOS, Android, and Web
2. [ ] Theme switches between light and dark mode
3. [ ] All core components render correctly in both themes
4. [ ] Navigation works between placeholder screens
5. [ ] No linter warnings or errors
6. [ ] Component showcase screen demonstrates all widgets
7. [ ] Unit tests exist for utility classes
