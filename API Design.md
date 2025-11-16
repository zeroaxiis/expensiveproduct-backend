# Expense Manager — API Design (v1)

Base URL examples:

* **Prod**: `https://api.expense-manager.com/api`
* **Dev**: `https://dev-api.expense-manager.com/api`

All endpoints below are prefixed with `/api` (omitted in headings for brevity).


## 1. General API Conventions

### 1.1 Authentication

* **Access token**: short-lived JWT (e.g., 15 min)

  * Sent as: `Authorization: Bearer <access_token>`
* **Refresh token**: long-lived, **httpOnly**, **secure**, `SameSite=strict` cookie

  * Used only with `/auth/refresh` and `/auth/logout`.
* Some admin endpoints may require additional roles in JWT (`role: 'admin'`).

### 1.2 Content Types

* Requests: `Content-Type: application/json`
* Responses: `Content-Type: application/json`

### 1.3 Standard Response Envelope

All responses:

```js
{
  "data": { ... },   // null on error
  "error": null      // or { "code": "STRING_CODE", "message": "Human readable" }
}
````

### 1.4 Date, Time & IDs

* Timestamps in **ISO 8601** (UTC), e.g. `2025-11-16T14:23:00Z`.
* IDs are UUIDv4 strings, e.g. `"c9dc4b0c-..."`.

### 1.5 Pagination

* Query parameters: `page`, `limit`

  * `page` (1-based), default `1`
  * `limit`, default `20`, max `100`
* Response includes:

```js
{
  "data": {
    "items": [ ... ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "totalItems": 123,
      "totalPages": 7
    }
  },
  "error": null
}
```

### 1.6 Filtering & Sorting (generic)

* Common filters: `start`, `end` (dates), `category`, `wallet_id`, `jar_id`.
* Sorting: `sort_by` (e.g. `paid_at`), `sort_order` (`asc` | `desc`).

### 1.7 Error Codes (examples)

* `AUTH_INVALID_CREDENTIALS`
* `AUTH_TOKEN_EXPIRED`
* `AUTH_FORBIDDEN`
* `RESOURCE_NOT_FOUND`
* `VALIDATION_ERROR`
* `RATE_LIMIT_EXCEEDED`
* `CONFLICT_IDEMPOTENT`
* `SERVER_ERROR`


## 2. Auth APIs

### POST `/auth/signup`

Create a new user account (email/password).

**Auth:** Public
**Body:**

```js
{
  "email": "user@example.com",
  "name": "Ashish",
  "password": "password123",
  "timezone": "Asia/Kolkata",
  "currency": "INR"
}
```

**Responses:**

* `201 Created`

```js
{
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "Ashish",
      "timezone": "Asia/Kolkata",
      "currency": "INR",
      "created_at": "2025-11-16T14:23:00Z"
    }
  },
  "error": null
}
```

* Sets **refresh token cookie** (httpOnly, secure).


### POST `/auth/login`

Email/password login.

**Auth:** Public
**Body:**

```js
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Responses:**

* `200 OK`

```js
{
  "data": {
    "access_token": "jwt-access-token"
  },
  "error": null
}
```

* Sets **refresh token cookie**.


### POST `/auth/refresh`

Obtain a new access token using the refresh token cookie.

**Auth:** Requires valid refresh token cookie
**Body:** *none*

**Response:**

* `200 OK`

```js
{
  "data": {
    "access_token": "new-jwt-access-token"
  },
  "error": null
}
```


### POST `/auth/logout`

Invalidate refresh token & clear cookie.

**Auth:** Requires refresh token cookie
**Body:** *none*

**Response:**

* `204 No Content`
  (Envelope can be `{ "data": null, "error": null }` if you prefer consistency.)


### POST `/auth/oauth/:provider/callback`

Handle OAuth callback for providers like `google`, `apple`.

**Auth:** Public
**Path params:**

* `provider`: `google` | `apple`

**Body** (depending on provider, often query params / code exchange):

```js
{
  "code": "oauth-auth-code",
  "redirect_uri": "https://app.expense-manager.com/oauth/callback"
}
```

**Response:**

* `200 OK`
  Same as login: returns `access_token` and sets refresh cookie.


## 3. Users & Profile

### GET `/me`

Get current authenticated user profile.

**Auth:** `Bearer` access token
**Response:**

```js
{
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "Ashish",
    "timezone": "Asia/Kolkata",
    "currency": "INR",
    "created_at": "2025-11-16T14:23:00Z",
    "updated_at": "2025-11-16T14:23:00Z"
  },
  "error": null
}
```


### PUT `/me`

Update user profile.

**Auth:** `Bearer`
**Body (partial):**

```js
{
  "name": "Ashish C",
  "timezone": "Asia/Kolkata",
  "currency": "USD"
}
```

**Response:**

* `200 OK` with updated user.


### POST `/me/change-password`

Change password (for email/password users).

**Auth:** `Bearer`
**Body:**

```js
{
  "current_password": "oldPass123",
  "new_password": "newPass456"
}
```

## 4. Wallets

Represents accounts like "Cash", "Bank", "Credit Card".

### GET `/wallets`

List wallets for current user.

**Auth:** `Bearer`
**Query:** pagination optional.

**Response:**

```js
{
  "data": {
    "items": [
      {
        "id": "uuid",
        "name": "HDFC Bank",
        "type": "bank",
        "currency": "INR",
        "initial_balance": 5000,
        "current_balance": 4200,
        "created_at": "2025-11-16T14:23:00Z"
      }
    ],
    "pagination": { ... }
  },
  "error": null
}
```


### POST `/wallets`

Create a wallet.

**Body:**

```js
{
  "name": "HDFC Bank",
  "type": "bank",
  "currency": "INR",
  "initial_balance": 5000
}
```



### GET `/wallets/:id`

Get wallet details.


### PUT `/wallets/:id`

Update wallet (e.g., name, type).



### DELETE `/wallets/:id`

Soft delete wallet (if no constraints violated); may reject if it has transactions.



## 5. Budgets

Optional monthly/weekly budgets per category/wallet.

### GET `/budgets`

List budgets.

### POST `/budgets`

Create a budget.

**Body:**

```js
{
  "name": "Monthly Food",
  "period": "monthly",
  "start_date": "2025-11-01",
  "amount": 10000,
  "currency": "INR",
  "category": "food",
  "wallet_id": "uuid"
}
```

### GET `/budgets/:id`

Budget details with usage summary.

### PUT `/budgets/:id`

Update budget.

### DELETE `/budgets/:id`

Delete budget.



## 6. Categories (optional but common)

### GET `/categories`

List all categories (system + user-defined).

### POST `/categories`

Create a custom category.

### PUT `/categories/:id`

Update custom category.

### DELETE `/categories/:id`

Delete custom category (may require re-mapping or deny if in use).


## 7. Expenses

Primary transaction resource.

### GET `/expenses`

List expenses with filters.

**Auth:** `Bearer`
**Query params:**

* `start`: ISO date (optional)
* `end`: ISO date (optional)
* `category`: string (optional)
* `wallet_id`: UUID (optional)
* `jar_id`: UUID (optional)
* `is_recurring`: boolean (optional)
* `page`, `limit`

**Response:** paginated list.


### POST `/expenses`

Create an expense.

**Auth:** `Bearer`
**Body:**

```js
{
  "amount": 500,
  "currency": "INR",
  "category": "food",
  "note": "Dinner with friends",
  "paid_at": "2025-11-16T19:30:00+05:30",
  "wallet_id": "uuid-wallet",
  "jar_id": "uuid-jar-optional",
  "is_recurring": false,
  "recurring_rule": null,     // optional (RRULE JSON or custom structure)
  "metadata": {
    "merchant": "Swiggy",
    "tags": ["friends", "weekend"]
  }
}
```

**Server behaviour:**

* Wrap in DB transaction:

  * Insert expense row.
  * Adjust `wallet.current_balance`.
  * If `jar_id` present, create jar transaction and update jar amount.
  * Insert outbox events for analytics & notifications.

**Response:**

* `201 Created` with created expense.


### GET `/expenses/:id`

Get one expense.


### PUT `/expenses/:id`

**Design choice:**
Rather than directly modifying historic rows, you can:

* Either:

  * Allow limited updates (note/category only), or
* For amount changes, append reversing transaction internally.

**Body:**

```js
{
  "amount": 600,
  "category": "food",
  "note": "Updated: included dessert"
}
```


### DELETE `/expenses/:id`

Soft delete an expense.

* Marks as deleted and **adds reversing effect** to wallet/jar.
* Response: `204 No Content` or `200` with updated expense state.


## 8. Jars (Savings) & Jar Transactions

### 8.1 Jars

### GET `/jars`

List all jars.

**Response:**

```js
{
  "data": {
    "items": [
      {
        "id": "uuid",
        "name": "Emergency Fund",
        "mode": "auto" ,   // 'auto' | 'manual'
        "current_amount": 15000,
        "target_amount": 50000,
        "auto_amount": 500,
        "auto_frequency": "daily",  // daily|weekly|monthly
        "allow_manual_topup": true,
        "last_auto_run": "2025-11-15",
        "created_at": "2025-10-01T00:00:00Z"
      }
    ],
    "pagination": { ... }
  },
  "error": null
}
```


### POST `/jars`

Create a jar.

**Body:**

```js
{
  "name": "Emergency Fund",
  "mode": "auto",
  "auto_amount": 500,
  "auto_frequency": "daily",
  "target_amount": 50000,
  "allow_manual_topup": true
}
```


### GET `/jars/:id`

Jar details (including summary).

---

### PUT `/jars/:id`

Update jar settings (mode, auto rules, target, name).


### DELETE `/jars/:id`

Delete or archive jar (if allowed).


### 8.2 Jar transactions

### GET `/jars/:id/transactions`

List jar-specific transactions.

**Query params:**

* `start`, `end`, `page`, `limit`


### POST `/jars/:id/topup`

Manual or external top-up.

**Body:**

```js
{
  "amount": 1000,
  "source": "manual",        // 'manual' | 'external'
  "note": "Salary topup",
  "wallet_id": "uuid-wallet" // optional; if provided, money moves from wallet
}
```

* Wrapped in DB transaction:

  * Update jar amount.
  * Adjust wallet if provided.
  * Insert jar_transaction row.
  * Insert outbox event for analytics.

---

### POST `/jars/:id/withdraw`

Withdraw from jar into wallet.

**Body:**

```js
{
  "amount": 2000,
  "target_wallet_id": "uuid-wallet",
  "note": "Emergency hospital bill"
}
```


## 9. Recurring Rules & Scheduler

### GET `/recurring`

List recurring rules for current user.

**Query:** `page`, `limit`, `type`, `enabled`


### POST `/recurring`

Create recurring rule for expenses or jars.

**Body:**

```js
{
  "type": "expense",          // 'expense' | 'jar_topup'
  "rule": {
    "rrule": "FREQ=MONTHLY;BYMONTHDAY=1"
  },
  "start_date": "2025-11-01",
  "enabled": true,
  "template": {
    "amount": 2000,
    "currency": "INR",
    "category": "rent",
    "wallet_id": "uuid-wallet",
    "note": "Monthly rent"
  }
}
```



### GET `/recurring/:id`

Details of a recurring rule.


### PUT `/recurring/:id`

Update recurring rule (enable/disable, change frequency, etc.).


### DELETE `/recurring/:id`

Delete recurring rule.


### POST `/scheduler/run`

Admin/debug endpoint to trigger scheduled jobs (e.g., for testing).

**Auth:** Admin only
**Body:**

```js
{
  "job_type": "jar_daily_save",
  "jar_id": "uuid",
  "date": "2025-11-16"
}
```



## 10. Dashboard & Analytics

### GET `/dashboard/summary`

High-level aggregates.

**Auth:** `Bearer`
**Query:**

* `range`: `7d` | `30d` | `90d` | `custom`
* `start`, `end` (if `range=custom`)

**Example Response:**

```js
{
  "data": {
    "total_expense": 25000,
    "total_income": 30000,
    "net_savings": 5000,
    "by_category": [
      { "category": "food", "amount": 9000 },
      { "category": "rent", "amount": 12000 }
    ],
    "by_wallet": [
      { "wallet_id": "uuid", "amount": 15000 }
    ]
  },
  "error": null
}
```


### GET `/dashboard/graph`

Time-series data for charts.

**Query:**

* `range`: `30d` (etc.)
* `granularity`: `daily` | `weekly` | `monthly`

**Response:**

```js
{
  "data": {
    "points": [
      { "date": "2025-11-01", "expense": 500, "income": 0 },
      { "date": "2025-11-02", "expense": 700, "income": 0 }
    ]
  },
  "error": null
}
```



### GET `/dashboard/jars-overview`

(optional separate endpoint)

Summary of jars for dashboard widget.



## 11. Notifications

### GET `/notifications`

List notifications.

**Query:**

* `status`: `unread` | `all`
* `page`, `limit`

**Response:**

```js
{
  "data": {
    "items": [
      {
        "id": "uuid",
        "type": "jar_auto_credit_failed",
        "title": "Jar auto-save failed",
        "body": "We couldn't auto-save ₹500 to Emergency Fund.",
        "read": false,
        "created_at": "2025-11-16T14:23:00Z"
      }
    ],
    "pagination": { ... }
  },
  "error": null
}
```



### POST `/notifications/mark-read`

Mark notifications as read.

**Body:**

```js
{
  "ids": ["uuid1", "uuid2"]
}
```



### DELETE `/notifications/:id`

Delete (or archive) a single notification.



## 12. AI Assistant

### POST `/ai/chat`

Send a message to AI assistant.

**Auth:** `Bearer`
**Body:**

```js
{
  "session_id": "uuid-optional",
  "message": "How much did I spend on food this month?",
  "include_personal_data": true   // if true, server will use aggregates/analytics
}
```

**Server behaviour:**

* Fetch aggregate data (never raw PII unless absolutely necessary).
* Call vector DB + LLM.
* Optionally store conversation summary (not raw transaction data).

**Response:**

```js
{
  "data": {
    "session_id": "uuid",
    "reply": "You've spent ₹9,000 on food so far this month.",
    "sources": [
      {
        "type": "aggregate",
        "range": "2025-11-01 to 2025-11-16",
        "category": "food"
      }
    ]
  },
  "error": null
}
```



### GET `/ai/history`

Get AI conversation history.

**Query:**

* `session_id` (filter single session)
* or list last N sessions.



## 13. Admin & Ops

### GET `/health`

Basic health check.

**Auth:** Public or IP-restricted.

**Response:**

```js
{
  "data": {
    "status": "ok",
    "uptime": 12345,
    "dependencies": {
      "db": "ok",
      "redis": "ok",
      "queue": "ok"
    }
  },
  "error": null
}
```


### GET `/metrics`

Prometheus metrics endpoint.

**Auth:** Protected via IP allowlist or basic auth.

* Exposes plain text metrics (not JSON).



### POST `/admin/rebuild-analytics`

Trigger manual refresh of materialized views / analytics caches.

**Auth:** Admin only
**Body:**

```js
{
  "scope": "all"        // 'all' | 'dashboard' | 'category_breakdown'
}
```



### GET `/admin/users`

Admin-only user list (for support / management).

**Auth:** Admin
**Query:** `email`, `page`, `limit`, etc.



## 14. Exports & Data Management

### POST `/exports/transactions`

Request data export (e.g., CSV of expenses).

**Body:**

```js
{
  "format": "csv",           // 'csv' | 'xlsx'
  "start": "2025-11-01",
  "end": "2025-11-30",
  "email_when_ready": true
}
```

* Enqueues job; sends email when completed with link to S3 object.

**Response:**

```js
{
  "data": {
    "export_id": "uuid",
    "status": "queued"
  },
  "error": null
}
```



### GET `/exports/:id`

Check export status or download link.



### POST `/me/data/delete`

Account/data deletion request (for compliance).



## 15. Idempotency & Rate Limiting

### 15.1 Idempotency

For **non-safe** endpoints that might be retried (e.g., payments, jar top-ups):

* Header: `Idempotency-Key: <uuid>`
* If a request with the same key was already processed, server returns previous response and `409` or `200` depending on approach.

### 15.2 Rate limiting

* Per-IP and per-user rate limits on:

  * `/auth/login`
  * `/auth/signup`
  * `/ai/chat`
* Too many requests → `429 Too Many Requests` with:

```js
{
  "data": null,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again later."
  }
}
```


