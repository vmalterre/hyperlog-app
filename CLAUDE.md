# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview

HyperLog mobile app - a Flutter application for blockchain-powered pilot logbook. Part of the HyperLog platform by HyperLog Ltd (UK).

This app connects to the HyperLog backend API which interfaces with a Hyperledger Fabric blockchain network. See [hyperlog-backend](https://github.com/vmalterre/hyperlog-backend) for the backend and blockchain components.

## Commands

```bash
flutter pub get          # Install dependencies
flutter analyze          # Run static analysis
flutter test             # Run tests
flutter run              # Run on connected device/emulator
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app
```

## Architecture

### Project Structure
```
lib/
├── config/              # API configuration
├── models/              # Data models (Pilot, LogbookEntry)
├── screens/             # App screens
├── services/            # API services
├── theme/               # App theme (colors, typography)
└── widgets/             # Reusable widgets
```

### State Management
- Provider for state management (`LoginState` in `login_state.dart`)
- Firebase Auth for authentication
- Firestore for user data
- Crashlytics for error reporting

### API Integration (`lib/services/`, `lib/config/`)
- `api_config.dart` - Base URL configuration (localhost:3001, 10.0.2.2 for Android emulator)
- `api_service.dart` - HTTP client with GET/POST, error handling, JSON parsing
- `api_exception.dart` - Custom exception for API errors
- `pilot_service.dart` - Register/get pilot operations
- `flight_service.dart` - CRUD operations for flights

### Data Models (`lib/models/`)
- `pilot.dart` - Pilot identity (licenseNumber, name, email, status)
- `logbook_entry.dart` - Full flight entry with `FlightTime`, `Landings`, and `toShort()` converter
- `logbook_entry_short.dart` - Simplified entry for list display

### Theme System (`lib/theme/`)
- `app_colors.dart` - Full color palette (Denim blues, Night Rider neutrals, Trust levels)
- `app_typography.dart` - Outfit (UI) and JetBrains Mono (data) via google_fonts
- `app_theme.dart` - Dark theme configuration with Material 3

### Reusable Widgets (`lib/widgets/`)
- `glass_card.dart` - Glass-morphism cards with backdrop blur
- `trust_badge.dart` - Logged/Tracked/Certified trust level badges
- `app_button.dart` - Primary, Secondary, Danger buttons with animations
- `flight_entry_card.dart` - Flight list items with trust badges and route lines
- `glass_bottom_nav.dart` - Blurred bottom navigation bar
- `route_line.dart` - Gradient line with airplane icon
- `form/` - Form input widgets (glass_text_field, glass_date_picker, glass_time_picker, number_stepper, role_selector)

### Design System
- Dark theme first (Night Rider #333333 background)
- Primary color: Denim Blue (#025EB5)
- Trust levels: Logged (blue), Tracked (amber), Certified (green)
- Typography: Outfit for UI, JetBrains Mono for data/codes
- Glass-morphism effects with backdrop blur

## Backend Connection

The app connects to the HyperLog backend API:
- Development: `http://localhost:3001` (web) or `http://10.0.2.2:3001` (Android emulator)
- The backend must be running for API features to work

**API Endpoints:**
- `POST /api/pilots` - Register pilot
- `GET /api/pilots/:license` - Get pilot by license
- `POST /api/flights` - Create flight entry
- `GET /api/flights/:id` - Get flight by ID
- `GET /api/pilots/:license/flights` - Get pilot's flights

## Dev Environment

- Flutter 3.x / Dart 3.6+
- Android Studio for emulator
- Firebase project configured

### Running on Windows
```bash
flutter pub get
flutter run              # Run on connected device/emulator
flutter run -d chrome    # Run on web
```

## Current Status

- Firebase Auth integration complete
- API layer implemented (services, models)
- UI screens: auth, home, logbook, add flight, settings
- Trust level badges and glass-morphism design
- Pilot license hardcoded for dev (`UK-ATPL-123456`)

**Next steps:**
- Add pilot registration flow (link Firebase Auth to blockchain pilot)
- Test full flow with backend running
