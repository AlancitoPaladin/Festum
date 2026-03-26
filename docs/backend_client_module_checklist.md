# Backend Checklist - Client Module (Festum)

## Objective
This checklist defines the minimum backend scope required so the Flutter `client` module works reliably in production-like conditions.

## Base
- Base path: `/api/v1/client`
- Auth: `Authorization: Bearer <JWT>` required on all endpoints below.

## 1) Services (Catalog)

### 1.1 `GET /services/home`
- Return grouped data by category.
- Include only `published/active` services.
- Each service should include at least:
  - `id`
  - `name`
  - `subtitle`
  - `description`
  - `unit_price_cents`
  - `price_label`
  - `badge`
  - `products` (array, can be empty)
  - `image` `{ key, url, expires_at }` (new format)
  - `image_url` (legacy compatibility, optional but recommended)

### 1.2 `GET /services?category=...`
- Add server-side filtering/pagination:
  - `q` (text search)
  - `min_price_cents`
  - `max_price_cents`
  - `sort` (`price_asc`, `price_desc`, `newest`, `popular`)
  - `page`, `page_size`
- Return response with metadata:
  - `items`
  - `total`
  - `page`
  - `page_size`
  - `has_next`

### 1.3 `GET /services/{serviceId}?category=...`
- Validate category-service consistency.
- Return full detail including `products`.
- Return `404` if not found or not in that category.

## 2) Cart

### 2.1 `GET /cart`
- Ensure each item returns:
  - `id` (service_id)
  - `name` (service name, legacy)
  - `quantity` (always `1` for current business rule)
  - `unit_price_cents`
  - `service_name` (explicit)
  - `product_id` (nullable)
  - `product_name` (nullable)

### 2.2 `POST /cart/items`
- Expected body:
  - `service_id`
  - `name`
  - `unit_price_cents`
  - `product_id` (optional)
  - `product_name` (optional)
- Business rules:
  - No duplicates by `service_id`.
  - Reject if service is not active/published.
  - Force `quantity = 1` (single-unit service model).
- Errors:
  - `409 CART_DUPLICATE_ITEM`
  - `422` invalid payload
  - `404` service/product not found

### 2.3 `GET /cart/contains/{serviceId}`
- Return: `{ "contains": true|false }`

### 2.4 `DELETE /cart/items/{id}`
- Return removed item payload (for frontend undo).

### 2.5 `POST /cart/restore`
- Accept removed item + index and restore if valid.

### 2.6 `DELETE /cart`
- Clear cart for authenticated user.

## 3) Orders

### 3.1 `GET /orders`
- Return:
  - `items[]` with `id`, `title`, `status`, `total_label`, `created_at`
- Sort by `created_at DESC`.

### 3.2 `POST /orders`
- Create order from cart safely.
- Validate empty-cart scenario.
- Optional hardening:
  - Revalidate item availability/prices before persisting.

### 3.3 `PATCH /orders/{orderId}/status`
- Keep transition guard:
  - `pending_payment -> confirmed | cancelled`
  - `confirmed -> in_progress | cancelled`
  - `in_progress -> completed | cancelled`
- Return `409 ORDER_INVALID_TRANSITION` when invalid.

## 4) Asset URLs (S3 / Media)

- Always return presigned URL object:
  - `{ "key": "...", "url": "...", "expires_at": "UTC_ISO8601" }`
- Keep legacy URL fields for compatibility while frontend migration is ongoing.
- Ensure `expires_at` is UTC and parseable.
- Refresh URLs on each read endpoint where needed.

## 5) Error Contract (Standardize)

All controlled errors should follow:

```json
{
  "success": false,
  "message": "Human-readable message",
  "detail": "Technical detail",
  "code": "MACHINE_READABLE_CODE"
}
```

Minimum codes expected by frontend:
- `CART_DUPLICATE_ITEM`
- `ORDER_INVALID_TRANSITION`
- `UNAUTHORIZED`
- `FORBIDDEN`
- `NOT_FOUND`
- `VALIDATION_ERROR`

## 6) Firestore / DB Requirements

- Collections:
  - `services/{serviceId}`
  - `client_carts/{userId}/items/{serviceId}`
  - `client_orders/{userId}/items/{orderId}`
- Required indexes (according to queries used):
  - category + status/published
  - category + unit_price_cents
  - category + created_at
- Keep service status fields indexed (`is_published`, `is_active`, etc.).

## 7) Integration Tests (Minimum)

- Auth-required protection returns `401` without JWT.
- Services:
  - home/category/detail success path
  - category mismatch returns `404`
- Cart:
  - add item success
  - duplicate returns `409 CART_DUPLICATE_ITEM`
  - remove + restore flow
  - clear cart
- Orders:
  - create from cart
  - invalid transition returns `409 ORDER_INVALID_TRANSITION`

## 8) Ready-to-Consume Definition

Backend is considered ready for full frontend integration when:
- All endpoints above are stable.
- Response contracts are consistent across environments.
- Seed/test data exists for at least:
  - 3 categories
  - 5+ services
  - 2+ services with `products`
  - 1 order lifecycle demo
