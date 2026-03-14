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

Optional environment variable:

- `API_BASE_URL` (debug default: `http://127.0.0.1:8000`).

Example:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

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
