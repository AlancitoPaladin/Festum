# Festum Client API Contract (Pre-Backend Integration)

This document defines the minimum backend contract required by the current client app flow.
It is aligned with the existing frontend repositories, DTOs, and state transitions.

## Base

- Base path: `/api/v1/client`
- Content-Type: `application/json`
- Auth: Bearer token (already handled in client interceptors)

## Order Status Enum

Allowed backend values:

- `pending_payment`
- `confirmed`
- `in_progress`
- `completed`
- `cancelled`

### Allowed transitions

- `pending_payment -> confirmed | cancelled`
- `confirmed -> in_progress | cancelled`
- `in_progress -> completed`
- `completed` and `cancelled` are terminal

---

## Orders

### GET `/api/v1/client/orders`

Returns all client orders.

Response `200`:

```json
[
  {
    "id": "FST-2201",
    "title": "Salón Aurora",
    "status": "pending_payment",
    "total_label": "$41,200 MXN"
  }
]
```

### POST `/api/v1/client/orders`

Creates a new order.

Request body:

```json
{
  "title": "Salón Aurora +1 servicios",
  "status": "pending_payment",
  "total_label": "$56,900 MXN"
}
```

Response `201`:

```json
{
  "id": "FST-2202",
  "title": "Salón Aurora +1 servicios",
  "status": "pending_payment",
  "total_label": "$56,900 MXN"
}
```

### PATCH `/api/v1/client/orders/{orderId}/status`

Updates order status.

Request body:

```json
{
  "status": "confirmed"
}
```

Response `200`:

```json
{
  "ok": true
}
```

Validation rules:

- Reject invalid enum values.
- Reject transitions not allowed by the transition rules.

---

## Cart

### GET `/api/v1/client/cart`

Returns all cart items.

Response `200`:

```json
[
  {
    "id": "hall-aurora",
    "name": "Salón Aurora",
    "quantity": 1,
    "unit_price_cents": 4120000
  }
]
```

### GET `/api/v1/client/cart/contains/{serviceId}`

Checks if service is already in cart.

Response `200`:

```json
{
  "contains": true
}
```

### POST `/api/v1/client/cart/items`

Adds a service to cart.

Request body:

```json
{
  "service_id": "hall-aurora",
  "name": "Salón Aurora",
  "unit_price_cents": 4120000
}
```

Response `200`:

```json
{
  "added": true
}
```

Business rule:

- Services are unique in cart (`quantity` should remain `1`).
- If already present, return `added: false`.

### DELETE `/api/v1/client/cart/items/{id}`

Removes a cart item and returns it (used by client undo flow).

Response `200`:

```json
{
  "id": "hall-aurora",
  "name": "Salón Aurora",
  "quantity": 1,
  "unit_price_cents": 4120000
}
```

If item does not exist:

- Return `404` or `200` with empty payload (frontend supports nullable response).

### POST `/api/v1/client/cart/restore`

Restores a removed item at index.

Request body:

```json
{
  "item": {
    "id": "hall-aurora",
    "name": "Salón Aurora",
    "quantity": 1,
    "unit_price_cents": 4120000
  },
  "index": 0
}
```

Response `200`:

```json
{
  "ok": true
}
```

### DELETE `/api/v1/client/cart`

Clears all cart items.

Response `200`:

```json
{
  "ok": true
}
```

---

## Services (Target Contract)

Current API repository for services is a temporary stub. These are the recommended endpoints for backend implementation:

### GET `/api/v1/client/services/home`

Response `200`:

```json
{
  "salones-sociales": [],
  "mobiliario": [],
  "banquetes": []
}
```

### GET `/api/v1/client/services?category={slug}`

### GET `/api/v1/client/services/{serviceId}?category={slug}`

Service item shape:

```json
{
  "id": "hall-aurora",
  "name": "Salón Aurora",
  "subtitle": "Paquete completo con iluminación",
  "price_label": "Desde $41,200 MXN",
  "unit_price_cents": 4120000,
  "badge": "Premium",
  "category": "salones-sociales"
}
```

---

## Error Handling (Recommended)

Use standard structure:

```json
{
  "detail": "Human-readable error message",
  "code": "ORDER_INVALID_STATUS_TRANSITION"
}
```

Suggested status codes:

- `400` invalid payload
- `401` unauthorized
- `404` resource not found
- `409` conflict (duplicate item or invalid transition)
- `500` unexpected server error

---

## Frontend Toggle

Client currently supports runtime compile-time switching:

- Mock mode (default): `--dart-define=USE_CLIENT_MOCKS=true`
- API mode: `--dart-define=USE_CLIENT_MOCKS=false`

Optional API base URL:

- `--dart-define=API_BASE_URL=http://127.0.0.1:8000`

