---
name: git-workflow-and-versioning
description: Enforces trunk-based git hygiene, conventional commit formats (feat, fix, refactor, chore), semantic versioning (SemVer 2.0.0), automated changelog updates, and clean branch management without uncommitted clutter or merge conflicts. Use whenever creating commits, branching, rebasing, tagging releases, or structuring version history.
---

# Git Workflow, Hygiene & Semantic Versioning

## Overview

Version control is your project's primary audit trail and safety net. This skill enforces disciplined Git hygiene: small atomic commits, Conventional Commits formatting, trunk-based continuous integration, and clean release versioning.

## Conventional Commits Invariants

All commit messages must adhere to the Conventional Commits specification:

```
<type>(<optional scope>): <imperative subject>

[optional body explaining motivation and context]

[optional footer(s), e.g., BREAKING CHANGE: or Closes #123]
```

### Standard Types

| Type | Purpose | SemVer Impact |
| :--- | :--- | :--- |
| `feat` | New feature or capability | Minor (`0.x.0` / `1.x.0`) |
| `fix` | Bug fix or error resolution | Patch (`0.0.x` / `1.0.x`) |
| `refactor` | Code change that neither fixes a bug nor adds a feature | Patch or None |
| `perf` | Performance improvement | Patch |
| `test` | Adding or correcting automated tests | None |
| `chore` | Build process, tooling, or dependency updates | None |
| `docs` | Documentation updates only | None |

## Branching & Commit Discipline

1. **Atomic Commits**: Each commit represents exactly one logical increment with passing tests. Never mix refactorings with behavioral changes.
2. **Short-Lived Branches**: Branches should live less than 48 hours. Integrate into `main` continuously.
3. **No Machine Artifacts**: Never commit `.env`, `node_modules`, IDE settings, or OS-generated files (`Thumbs.db`, `.DS_Store`).
4. **Clean Rebase**: Rebase feature branches on top of `main` before merging to maintain linear history.

## Verification Gate

Run the Git hygiene verification script before pushing or committing:

```powershell
powershell -ExecutionPolicy Bypass -File .\skills\git-workflow-and-versioning\scripts\verify_git_hygiene.ps1
```

POSIX Bash:
```bash
./skills/git-workflow-and-versioning/scripts/verify_git_hygiene.sh
```

