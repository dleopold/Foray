/// Utility class for form validation.
///
/// Provides reusable validation functions that return error messages
/// or null if validation passes.
///
/// Example:
/// ```dart
/// TextFormField(
///   validator: (value) => Validators.required(value, 'Email')
///       ?? Validators.email(value),
/// )
/// ```
abstract class Validators {
  /// Validates that a value is not null or empty.
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName is required' : 'This field is required';
    }
    return null;
  }

  /// Validates email format.
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null; // Use required() for empty check

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates minimum string length.
  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.isEmpty) return null;

    if (value.length < minLength) {
      final field = fieldName ?? 'This field';
      return '$field must be at least $minLength characters';
    }
    return null;
  }

  /// Validates maximum string length.
  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value == null || value.isEmpty) return null;

    if (value.length > maxLength) {
      final field = fieldName ?? 'This field';
      return '$field must be no more than $maxLength characters';
    }
    return null;
  }

  /// Validates that a value matches a pattern.
  static String? pattern(String? value, RegExp pattern, String message) {
    if (value == null || value.isEmpty) return null;

    if (!pattern.hasMatch(value)) {
      return message;
    }
    return null;
  }

  /// Validates password strength.
  static String? password(String? value, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireDigit = true,
    bool requireSpecial = false,
  }) {
    if (value == null || value.isEmpty) return null;

    final errors = <String>[];

    if (value.length < minLength) {
      errors.add('at least $minLength characters');
    }
    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      errors.add('an uppercase letter');
    }
    if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      errors.add('a lowercase letter');
    }
    if (requireDigit && !value.contains(RegExp(r'[0-9]'))) {
      errors.add('a number');
    }
    if (requireSpecial && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add('a special character');
    }

    if (errors.isEmpty) return null;

    return 'Password must contain ${errors.join(', ')}';
  }

  /// Validates that two values match (e.g., password confirmation).
  static String? match(String? value, String? other, [String? message]) {
    if (value == null || value.isEmpty) return null;

    if (value != other) {
      return message ?? 'Values do not match';
    }
    return null;
  }

  /// Validates a phone number format.
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;

    // Remove common formatting characters
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)\.]+'), '');

    // Allow optional + prefix and 10-15 digits
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates a URL format.
  static String? url(String? value) {
    if (value == null || value.isEmpty) return null;

    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Please enter a valid URL starting with http:// or https://';
      }
    } catch (_) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Validates a numeric value.
  static String? numeric(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) return null;

    if (double.tryParse(value) == null) {
      final field = fieldName ?? 'This field';
      return '$field must be a number';
    }
    return null;
  }

  /// Validates a value is within a numeric range.
  static String? range(String? value, double min, double max, [String? fieldName]) {
    if (value == null || value.isEmpty) return null;

    final number = double.tryParse(value);
    if (number == null) {
      final field = fieldName ?? 'This field';
      return '$field must be a number';
    }

    if (number < min || number > max) {
      final field = fieldName ?? 'Value';
      return '$field must be between $min and $max';
    }
    return null;
  }

  /// Validates latitude (-90 to 90).
  static String? latitude(String? value) {
    if (value == null || value.isEmpty) return null;

    final lat = double.tryParse(value);
    if (lat == null || lat < -90 || lat > 90) {
      return 'Latitude must be between -90 and 90';
    }
    return null;
  }

  /// Validates longitude (-180 to 180).
  static String? longitude(String? value) {
    if (value == null || value.isEmpty) return null;

    final lon = double.tryParse(value);
    if (lon == null || lon < -180 || lon > 180) {
      return 'Longitude must be between -180 and 180';
    }
    return null;
  }

  /// Validates a join code format (6 alphanumeric characters).
  static String? joinCode(String? value) {
    if (value == null || value.isEmpty) return null;

    final cleanedCode = value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleanedCode.length != 6) {
      return 'Join code must be 6 characters';
    }
    return null;
  }

  /// Validates a specimen ID format.
  static String? specimenId(String? value, {bool allowEmpty = true}) {
    if (value == null || value.isEmpty) {
      return allowEmpty ? null : 'Specimen ID is required';
    }

    // Allow alphanumeric, hyphens, and underscores
    final specimenRegex = RegExp(r'^[A-Za-z0-9\-_]+$');
    if (!specimenRegex.hasMatch(value)) {
      return 'Specimen ID can only contain letters, numbers, hyphens, and underscores';
    }

    if (value.length > 50) {
      return 'Specimen ID must be 50 characters or less';
    }

    return null;
  }

  /// Combines multiple validators into one.
  ///
  /// Returns the first error found, or null if all pass.
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
