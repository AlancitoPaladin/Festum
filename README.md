# Festum

Festum is a Flutter application for event services discovery and booking. It provides a client-facing experience with service catalogs, detailed service pages, cart management, and order tracking, built with a clean architecture that separates UI from data sources.

## Project Status

- Client flow: implemented with mock data and standardized UI states.
- Backend: integration pending. The app is prepared with repositories and use cases to connect APIs without rewriting views.

## Key Features

- Client home with category sections.
- Service detail with gallery, availability mock, and sticky CTA.
- Cart with payment summary, confirmation, and undo.
- Orders with timeline and detail modal.
- Shared bottom navigation with hide/show on scroll.
- Pull-to-refresh across client screens.

## Architecture

- Views are decoupled from data via repositories and use cases.
- Shared tab UI state for badges and scroll position.
- Reusable UI primitives for empty/loading/error states and feedback.

## Requirements

- Flutter (stable channel)
- Dart (bundled with Flutter)

## Configuration

Supported `--dart-define` values:

- `APP_ENV`: `dev` | `staging` | `prod`
- `API_BASE_URL`: URL override for any environment
- `USE_CLIENT_MOCKS`: `true` | `false`

Resolution order:

1. `API_BASE_URL` (highest priority)
2. `APP_ENV`
3. Local defaults (`dev`):
   - Android emulator: `http://10.0.2.2:8000`
   - iOS simulator/macOS: `http://127.0.0.1:8000`

Environment defaults:

- `APP_ENV=dev` -> local defaults
- `APP_ENV=staging` -> `https://staging-api.example.com`
- `APP_ENV=prod` -> `https://api.example.com`

Useful examples:

```bash
# Android emulator + local API
flutter run --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:8000

# iOS simulator + local API
flutter run --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://127.0.0.1:8000

# Device (Android/iOS) + cloud API
flutter run --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://api.tudominio.com

# Force real API (no mocks)
flutter run --dart-define=APP_ENV=dev --dart-define=USE_CLIENT_MOCKS=false
```

### iOS Xcode (sin `--dart-define`)

El proyecto ya incluye defines por configuración:

- `Debug` -> `APP_ENV=dev`, `USE_CLIENT_MOCKS=false`
- `Release/Profile` -> `APP_ENV=prod`, `USE_CLIENT_MOCKS=false`

En Xcode:

1. `Product -> Scheme -> Edit Scheme...`
2. Para `Run` usa `Build Configuration: Debug`.
3. Para `Archive` usa `Build Configuration: Release`.
4. Para pruebas contra staging, usa `Build Configuration: Staging` en `Run` o `Archive`.
5. También puedes seleccionar el scheme compartido `Runner-Staging` para no cambiar la configuración manualmente.

## Run

```bash
flutter pub get
flutter run
```

## Static Analysis

```bash
flutter analyze
```

## Relevant Structure

- `lib/features/client/views` client screens
- `lib/features/client/repositories` data contracts
- `lib/features/client/repositories/mock` mock implementations
- `lib/features/client/usecases` use cases
- `lib/features/client/widgets` reusable components
- `lib/core/theme` theme and colors

## Notes

- Session validation is skipped in debug when using a local API to avoid forced sign-out if the backend is offline.
- Current pricing and content are mock data and will be replaced when backend integration is enabled.
