---
name: ship-release
description: Executes release readiness checklists, verifies build artifacts, runs automated test suites, bumps semantic versions, updates changelogs, and creates clean release PRs or tags. Use when preparing to ship changes to production.
---

# Ship & Release Automation

## Overview

Shipping software is an operational discipline. Rushing a release without pre-flight checks leads to broken main branches, regressed migrations, and customer downtime. The `ship-release` skill provides a checklist and automated pre-flight runner to guarantee release confidence.

## Pre-Flight Release Checklist

```
[ ] 1. TESTS      → 100% automated test suites passing cleanly
[ ] 2. BUILD      → Zero compiler warnings, zero linter/typecheck errors
[ ] 3. SECURITY   → Zero high/critical CVEs; zero leaked secrets
[ ] 4. MIGRATION  → Schema migrations verified backwards-compatible
[ ] 5. VERSION    → SemVer bumped appropriately (patch/minor/major)
[ ] 6. CHANGELOG  → User-facing release notes documented with issue links
[ ] 7. TAG/PR     → Release commit tagged or pull request opened
```

## Release Automation Script

Execute the pre-flight release gate:

```powershell
powershell -ExecutionPolicy Bypass -File .\suites\founder-suite\ship-release\scripts\verify_release_readiness.ps1
```

POSIX Bash:
```bash
./suites/founder-suite/ship-release/scripts/verify_release_readiness.sh
```
