---
name: owasp-secure-coding
description: >-
  Enforces OWASP Top 10 secure coding defenses, input sanitization, parameterized queries, and safe authentication patterns.
  Use whenever authoring API endpoints, authentication flows, authorization checks, SQL/database queries, or handling user input.
---

# OWASP Secure Coding Protocol

This skill enforces proactive application security standards based on the **OWASP Top 10** across all web applications, APIs, and microservices.

> **Reference** (load on demand):
> - [OWASP Top 10 Secure Coding Playbook](./references/owasp_top_10_playbook.md): Injection, broken access control, and cryptographic failures.

---

## Non-Negotiable Invariants

### 1. SQL / NoSQL Injection Prevention
- **Never concatenate user strings into database queries**:
  ```typescript
  // ❌ CRITICAL VULNERABILITY: SQL Injection
  db.query(`SELECT * FROM users WHERE email = '${email}'`);

  // ✅ Google / OWASP Standard: Parameterized query
  db.query('SELECT * FROM users WHERE email = $1', [email]);
  ```
- With ORMs (Prisma, Entity Framework, SQLAlchemy), never bypass parameterization with raw string template interpolations.

### 2. Strict Input Validation at Public Seams
- Every external HTTP request payload, query string, and route parameter must be validated with a strict runtime schema:
  - TypeScript: **Zod**, **Valibot**, or **TypeBox**.
  - Python: **Pydantic** models.
  - C#: Data Annotations or **FluentValidation**.
- Reject unexpected properties (`stripUnknown: true` or strict schemas) to prevent **Mass Assignment vulnerabilities**.

### 3. Cross-Site Scripting (XSS) Prevention
- In frontend code (React, Vue, Svelte, Angular), never use `dangerouslySetInnerHTML`, `v-html`, or direct DOM `element.innerHTML = userInput`.
- Sanitize rich HTML with DOMPurify if raw HTML rendering is strictly required by the product specification.

### 4. Authentication & Password Security
- Never store plaintext passwords or use obsolete hashing algorithms (MD5, SHA-1, SHA-256 without salt).
- Always hash passwords using modern memory-hard key derivation functions: **Argon2id** (recommended) or **bcrypt** with work factor $\ge 12$.
- Session cookies must include: `HttpOnly`, `Secure`, and `SameSite=Lax` or `Strict`.

---

## Phase 1: Static Pattern Verification

Before completing tasks touching API or database code, run the SAST pattern verifier:
```powershell
powershell -File ./skills/owasp-secure-coding/scripts/verify_sast_patterns.ps1
```

---

## Phase 2: Evidence Delivery

In your response to the user:
- Show that all queries are parameterized.
- Demonstrate that schemas validate input boundaries.
- Show the clean execution output of `verify_sast_patterns.ps1`.

