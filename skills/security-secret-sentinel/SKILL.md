---
name: security-secret-sentinel
description: >-
  Audits codebases and git staging for leaked secrets, API keys, credentials, and unprotected environment files.
  Use whenever handling environment configurations, setting up authentication, reviewing commits, or before deploying code.
---

# Security Secret Sentinel: Credential Leak Prevention Protocol

This skill enforces a **Zero Leaked Secrets Policy** across all code, configuration files, and git commits.

---

## Non-Negotiable Invariants

1. **Zero Hardcoded Secrets**:
   - API keys, database passwords, JWT private keys, cloud tokens, and webhooks must **never** be hardcoded in source code or committed to version control.
   - All credentials must be loaded via runtime environment variables (`process.env`, `os.environ`, `IConfiguration`) or external secret managers (AWS Secrets Manager, GCP Secret Manager, HashiCorp Vault).
2. **Mandatory `.env` Git Exclusion**:
   - Any file named `.env`, `.env.local`, `.env.production` containing real values must be listed in `.gitignore`.
   - Provide only `.env.example` with sanitized placeholder values (e.g. `DATABASE_URL=postgresql://user:password@localhost:5432/mydb`).
3. **No Secrets in Logs or Traces**:
   - Sanitization filters must redact authorization headers, tokens, and credentials before logging.

---

## Phase 1: Pre-Execution Scan

Before pushing code or completing tasks touching configuration:
1. Run the automated secret scanner:
   ```powershell
   powershell -File ./skills/security-secret-sentinel/scripts/scan_secrets.ps1
   ```
2. If secrets are detected:
   - Immediately replace the hardcoded token with an environment variable reference.
   - If the secret was already committed to git, instruct the user to rotate the credential immediately.

---

## Phase 2: Evidence Delivery

In your response to the user:
- Show the clean execution output of `scan_secrets.ps1`.
- Confirm that all `.env` files are tracked in `.gitignore`.
- Provide an updated `.env.example` template if new configuration keys were introduced.
