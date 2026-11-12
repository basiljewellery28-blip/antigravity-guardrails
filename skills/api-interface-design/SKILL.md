---
name: api-interface-design
description: >-
  Enforces stable, ergonomic API and interface design based on Addy Osmani's engineering standards and Hyrum's Law.
  Use whenever designing REST/GraphQL endpoints, public module boundaries, SDK functions, or data contracts.
---

# API and Interface Design Protocol

Adapted from Addy Osmani's engineering skills and Google interface design principles.

A good interface makes the right thing easy and the wrong thing hard. This skill guides the creation of durable, misuse-resistant public contracts.

> **Reference** (load on demand):
> - [Interface Design & Error Contract Reference](./references/interface_contracts.md): REST endpoint error semantics, and deep vs. shallow modules.

---

## Core Laws of Interface Design

### 1. Hyrum's Law
> *"With a sufficient number of users of an API, all observable behaviors of your system will be depended on by somebody, regardless of what you promise in the contract."*
- **Never leak internal implementation details**: Once an internal detail is exposed in response payloads or timing, it becomes an accidental public contract.
- **Design for deprecation upfront**: Never introduce a field or route without a clear deprecation path.

### 2. Contract First
Always define the formal interface before implementing business logic:
- TypeScript: Define strict interfaces or Zod schemas.
- Python: Define Pydantic models or typed protocols.
- Go / C#: Define consumer-owned interfaces and immutable DTOs.

### 3. Consistent Error Semantics
Use a unified error shape across every endpoint and module:
```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Field 'email' must be a valid email address",
    "details": { "field": "email" }
  }
}
```
Never mix strategies (e.g. some functions returning `null`, some throwing errors, some returning `{ ok: false }`).

### 4. Idempotent Operations
- `DELETE` and `PUT` operations must be idempotent (calling them twice leaves the system in the identical state).
- Use idempotency keys for critical mutating actions (e.g. payment processing, order placement).

---

## Phase 1: Verification Gate

Run the interface verification script:
```powershell
powershell -File ./skills/api-interface-design/scripts/verify_api_surface.ps1
```
The script validates:
1. All public boundaries have explicit schemas.
2. Error responses adhere to structured payloads.
3. No raw untyped dictionaries/objects are exposed at entry points.

