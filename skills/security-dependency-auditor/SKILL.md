---
name: security-dependency-auditor
description: >-
  Audits third-party dependencies, package manifests, and lockfiles for known CVE vulnerabilities and supply-chain risks.
  Use whenever adding new packages, upgrading libraries, reviewing lockfiles, or preparing release builds.
---

# Security Dependency Auditor: Supply-Chain Protection Protocol

This skill enforces software supply chain security, preventing vulnerable packages and unvetted dependencies from entering production codebases.

---

## Non-Negotiable Invariants

1. **Zero High / Critical CVE Tolerance**:
   - Production builds must have zero unmitigated **High** or **Critical** vulnerabilities.
   - If a vulnerability is discovered, it must be updated to a patched version or replaced with a secure alternative.
2. **Lockfile Integrity**:
   - Never commit `package.json` without its corresponding `pnpm-lock.yaml`, `package-lock.json`, or `yarn.lock`.
   - Never commit Python changes without pinned versions in `uv.lock`, `poetry.lock`, or `requirements.txt`.
3. **No Unpinned Dependencies in Production**:
   - Avoid open-ended wildcard version ranges (e.g., `*` or `>=1.0.0`) that permit automatic ingestion of malicious downstream releases.

---

## Phase 1: Automated Audit Execution

When auditing or modifying dependencies, run the universal audit runner:
```powershell
powershell -File ./skills/security-dependency-auditor/scripts/audit_deps.ps1
```

Supported Package Managers:
- **Node.js**: `pnpm audit`, `yarn audit`, `npm audit --audit-level=high`
- **Python**: `pip-audit`, `safety check`
- **.NET**: `dotnet list package --vulnerable --include-transitive`
- **Rust**: `cargo audit`

---

## Phase 2: Vulnerability Resolution Protocol

If an audit reports vulnerable dependencies:
1. **Direct Update**: Attempt a minor or patch update first (`npm update <pkg>`, `uv lock --upgrade-package <pkg>`).
2. **Transitive Dependency Override**:
   - In Node: Use `pnpm.overrides`, `resolutions`, or `overrides` in `package.json`.
3. **Alternative Replacement**: If an abandoned package has no patched release, locate an active, maintained replacement.
4. **Re-Audit**: Execute `audit_deps.ps1` to prove the vulnerability is resolved with exit code 0.
