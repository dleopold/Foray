#!/bin/bash
# Foray Development Aliases and Functions
# Source this file in your shell: source scripts/dev-aliases.sh
#
# NOTE: Set your Supabase credentials before using these aliases:
#   export SUPABASE_URL="YOUR_SUPABASE_URL"
#   export SUPABASE_ANON_KEY="YOUR_SUPABASE_ANON_KEY"
#
# Or create a .env file in the project root with these variables

# Android development
alias foray-android='flutter run -d android'
alias foray-android-build='flutter build apk --release'
alias foray-android-clean='flutter clean && cd android && ./gradlew clean && cd ..'

# iOS development
alias foray-ios='flutter run -d ios'
alias foray-ios-build='flutter build ios --release'
alias foray-ios-clean='flutter clean && cd ios && rm -rf Pods && rm Podfile.lock && cd ..'

# Web development
alias foray-web='flutter run -d chrome --web-port=8080 --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY'
alias foray-web-build='flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY'

# Testing
alias foray-test='flutter test'
alias foray-test-coverage='flutter test --coverage'

# General Flutter commands
alias foray-clean='flutter clean'
alias foray-pub-get='flutter pub get'
alias foray-pub-upgrade='flutter pub upgrade'
alias foray-analyze='flutter analyze'
alias foray-format='dart format lib/ test/'

# Database/Build Runner
alias foray-build='dart run build_runner build'
alias foray-build-watch='dart run build_runner watch'
alias foray-build-clean='dart run build_runner clean'

# Helpful function to run a specific device
foray-run() {
  if [ -z "$1" ]; then
    echo "Usage: foray-run <device-id>"
    echo "Available devices:"
    flutter devices
  else
    flutter run -d "$1"
  fi
}

# Helpful function to check environment
foray-env-check() {
  echo "=== Foray Environment Check ==="
  echo "Flutter version:"
  flutter --version
  echo ""
  echo "Dart version:"
  dart --version
  echo ""
  echo "Supabase URL: ${SUPABASE_URL:-'NOT SET'}"
  echo "Supabase Anon Key: ${SUPABASE_ANON_KEY:-'NOT SET'}"
  echo ""
  echo "Available devices:"
  flutter devices
}

echo "✓ Foray development aliases loaded"
echo "  Run 'foray-env-check' to verify your environment"
