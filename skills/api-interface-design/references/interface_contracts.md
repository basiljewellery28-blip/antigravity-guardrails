# Interface Design & Error Contract Reference

Adapted from Addy Osmani's engineering patterns.

---

## 1. REST Endpoint Error Semantics

Standardized HTTP status mapping:
- `400 Bad Request`: Malformed syntax, invalid JSON structure.
- `401 Unauthorized`: Authentication missing or token invalid.
- `403 Forbidden`: Authenticated, but lacking permissions for the specific resource.
- `404 Not Found`: Resource does not exist.
- `409 Conflict`: Duplicate key or state collision.
- `422 Unprocessable Entity`: Syntactically valid, but domain/business rule validation failed.
- `500 Internal Server Error`: Server failure (never leak internal stack traces or database errors).

---

## 2. Deep Modules vs Shallow Modules

- **Shallow Module (Anti-pattern)**: A complex interface wrapping simple logic. Requires the caller to know many parameters and details.
- **Deep Module (Best Practice)**: A simple, minimal interface that hides substantial internal capability. Easy to invoke, difficult to break.
