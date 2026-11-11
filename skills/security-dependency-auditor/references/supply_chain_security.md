# Software Supply Chain Security Reference

Guidelines for maintaining dependency hygiene and integrity.

---

## 1. Threat Vectors in Modern Packaging

1. **Dependency Confusion**: An internal proprietary package name is registered publicly on npm or PyPI, hijacking internal builds.
2. **Typosquatting**: Malicious packages named similarly to popular libraries (e.g., `cross-env` vs `crossenv`).
3. **Compromised Maintainer Accounts**: Legitimate packages updated with malicious payloads in minor/patch releases.

---

## 2. Defensive Controls

- **Always Commit Lockfiles**: Lockfiles contain cryptographic hashes (`integrity: sha512-...`) of the exact tarball downloaded during installation.
- **Automated Dependabot / Renovate**: Regularly update dependencies in small increments rather than waiting for annual bulk upgrades.
- **Minimal Dependencies Policy**: Prefer standard library capabilities before pulling in multi-megabyte third-party packages for simple utilities.
