# Push Notifications Setup (Android + iOS)

This project already includes:

- `firebase_messaging`
- `flutter_local_notifications`
- Device token registration endpoints:
  - `POST /api/v1/notifications/device-token`
  - `DELETE /api/v1/notifications/device-token`

## 1) Firebase project

1. Create or use an existing Firebase project.
2. Add both apps with the exact bundle IDs/package IDs used by Festum:
   - Android: `android/app/build.gradle.kts` -> `applicationId`
   - iOS: Runner bundle identifier in Xcode

## 2) Android configuration

1. Download `google-services.json` from Firebase.
2. Place it in:
   - `android/app/google-services.json`
3. Ensure notification permission is present (already configured):
   - `android.permission.POST_NOTIFICATIONS`

## 3) iOS configuration

1. Download `GoogleService-Info.plist` from Firebase.
2. Add it to:
   - `ios/Runner/GoogleService-Info.plist`
   - Include it in the Runner target.
3. In Apple Developer + Xcode Signing:
   - Enable Push Notifications capability.
   - Enable Background Modes > Remote notifications.
4. Upload APNs key/certificate in Firebase Cloud Messaging settings.

## 4) Validate token registration

1. Login as client/provider in the app.
2. Verify backend receives `POST /notifications/device-token`.
3. On logout, verify `DELETE /notifications/device-token`.

## 5) Functional test matrix

1. Foreground push:
   - Notification banner should appear (local notification).
2. Background push:
   - Push received from OS tray.
3. Tap on push:
   - `target_screen=client_orders` opens client orders.
   - `target_screen=provider_reservations` opens provider reservations.

## 6) Common failure

- `Push init skipped (Firebase not configured).`
  - Usually means `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is missing or not linked correctly.
