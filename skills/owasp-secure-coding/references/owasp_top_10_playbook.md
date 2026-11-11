# OWASP Top 10 Secure Coding Playbook

Actionable code-level patterns for building resilient, exploit-resistant applications.

---

## 1. Injection (A03:2021)

- **SQL / NoSQL**: Never build SQL queries using string formatting or template literals. Always bind variables using positional (`$1`, `?`) or named (`@param`) query parameters.
- **OS Command Injection**: Never pass user inputs to shell execution functions (`child_process.exec`, `os.system`). Use structured argument lists (`execFile`, `subprocess.run(["cmd", arg])`).

---

## 2. Broken Access Control (A01:2021)

- **Indirect Object References (IDOR)**: Always verify tenant/user ownership on every database operation:
  ```typescript
  // ❌ Vulnerable to IDOR: Any authenticated user can view invoice :id
  const invoice = await db.invoice.findUnique({ where: { id: req.params.id } });

  // ✅ Secure: Ownership constraint enforced at data layer
  const invoice = await db.invoice.findFirst({
    where: { id: req.params.id, organizationId: req.user.organizationId }
  });
  ```

---

## 3. Cryptographic Failures (A02:2021)

- **Password Storage**: Use **Argon2id** (preferred) or **bcrypt** ($cost \ge 12$).
- **Data in Transit**: Enforce HTTPS and TLS 1.3 across all endpoints.
- **Tokens**: Use cryptographically secure random number generators (`crypto.randomBytes(32)`), never `Math.random()`.

