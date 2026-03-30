# Festum App: QA + Real Notifications Plan

## 1) Functional QA Checklist (Client + Provider)

### Authentication
- Login with valid credentials.
- Login with invalid credentials (error message visible).
- Logout from Client top bar and confirm dialog flow.
- Reopen app and verify persisted session behavior.

### Client Flow
- Home loads categories and cards without overflow.
- Service detail opens and returns with back arrow.
- Add one service to cart (no duplicate quantity).
- Select add-ons/products and verify cart subtotal update.
- Submit order request from cart with event date + notes.
- Validate order appears in `Mis órdenes` with correct total.
- Pull-to-refresh works in Home, Cart, and Orders.

### Provider Flow
- New order request appears in `Reservas` / requests section.
- Accept request and verify:
  - request disappears from pending list
  - booking appears in upcoming reservations
  - provider home counters update
- Reject request and verify client sees cancelled/rejected state.

### Cross-Role Consistency
- Client cannot pay a rejected/cancelled request.
- Client can continue payment only after provider acceptance (according to current flow rules).
- Service and totals match between client order detail and provider reservation detail.

## 2) Real Notifications (Push) – Required Scope

Current app uses polling/badge logic. For real-time notifications, implement:

### Frontend (Flutter)
1. Add dependencies:
   - `firebase_core`
   - `firebase_messaging`
   - `flutter_local_notifications`
2. Initialize Firebase in app startup.
3. Request notification permissions (Android 13+ and iOS).
4. Get FCM token and send it to backend after login/refresh.
5. Handle:
   - foreground notifications (local notification banner)
   - background tap/open navigation to `Mis órdenes` or provider `Reservas`
6. Refresh order/reservation screens after notification tap.

### Backend
1. Store device tokens per user:
   - `POST /api/v1/notifications/device-token`
   - `DELETE /api/v1/notifications/device-token`
2. Trigger push when key events happen:
   - provider accepts request
   - provider rejects request
   - reservation status updates
3. Use Firebase Admin SDK to send notifications.
4. Include payload with navigation hints:
   - `type`
   - `order_id` or `request_id`
   - `target_screen`

## 3) Backend Prompt (ready to send)

```text
Implement real push notifications for Festum using Firebase Admin SDK.

Requirements:
1) Device token endpoints (JWT protected):
   - POST /api/v1/notifications/device-token
     body: { "token": "...", "platform": "android|ios" }
   - DELETE /api/v1/notifications/device-token
     body: { "token": "..." }

2) Persistence:
   - Store tokens by user id (support multiple devices per user).
   - Deduplicate tokens.
   - Allow token invalidation/cleanup when Firebase reports invalid token.

3) Send push on domain events:
   - provider accepts order request
   - provider rejects order request
   - booking/reservation status changes

4) Notification payload:
   - notification: title/body (human-readable)
   - data:
     - type (order_accepted, order_rejected, reservation_updated)
     - order_id or request_id
     - target_screen (client_orders | provider_reservations)

5) Reliability:
   - non-blocking send (do not break main transaction if push fails)
   - structured logging for success/failure
   - remove invalid/unregistered tokens automatically

6) Security:
   - endpoints require JWT
   - user can only register/remove own tokens

Deliverables:
- endpoints + schema changes
- service for sending notifications
- integration in existing order/reservation flows
- sample responses and errors
```

## 4) Frontend Prompt (ready to execute)

```text
Implement real push notifications in Flutter for Festum.

Requirements:
1) Add and configure:
   - firebase_core
   - firebase_messaging
   - flutter_local_notifications

2) Create NotificationService that:
   - initializes Firebase
   - requests permissions (iOS/Android 13+)
   - obtains FCM token
   - sends token to backend endpoint after login
   - listens token refresh and updates backend
   - handles foreground/background/opened-app notifications

3) Navigation behavior:
   - if payload target_screen=client_orders => open client orders tab/view
   - if payload target_screen=provider_reservations => open provider reservations view

4) UX:
   - show local notification in foreground
   - update badge counters in app state after receiving notification
   - avoid duplicate processing of same notification id

5) Keep fallback:
   - if push setup fails, app continues with current polling behavior.

Deliverables:
- service classes
- DI wiring
- platform config changes (AndroidManifest + Info.plist + Firebase files)
- minimal docs for setup/testing
```

