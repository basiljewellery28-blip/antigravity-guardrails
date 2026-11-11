---
name: deslop-codebase
description: Detects and eliminates AI slop, redundant pass-through wrappers, empty exception handlers, unused helper utilities, bloated boilerplate, and duplicate code blocks. Use whenever refactoring, auditing pull requests, reviewing AI-generated code, or preparing release candidates.
---

# Deslop Codebase & Boilerplate Elimination

## Overview

AI models often generate "slop" — unnecessary abstraction layers, trivial one-line wrappers around standard library functions, empty exception swallowers (`catch (e) {}`), duplicate utility functions, and overly defensive dead branches. The `deslop-codebase` skill ruthlessly identifies and strips away accidental complexity so code remains lean, maintainable, and readable.

## Slop Anti-Patterns

| Anti-Pattern | Example | Remedy |
| :--- | :--- | :--- |
| **Pass-Through Wrappers** | `function add(a, b) { return a + b; }` | Inline directly; delete the wrapper. |
| **Empty Catch Blocks** | `catch (err) { /* ignore */ }` | Log, handle explicitly, or allow error to propagate. |
| **Tautological Comments** | `// Set name to name`<br>`this.name = name;` | Delete redundant comments. |
| **Duplicate String Constants** | Same magic string used in 5 files | Extract to single typed constant or enum. |
| **Unused Stubs** | `TODO: implement later` | Implement fully or delete until needed. |

## Verification Gate

Run the automated slop analyzer across the repository:

```powershell
powershell -ExecutionPolicy Bypass -File .\skills\deslop-codebase\scripts\verify_codebase_slop.ps1
```

POSIX Bash:
```bash
./skills/deslop-codebase/scripts/verify_codebase_slop.sh
```

