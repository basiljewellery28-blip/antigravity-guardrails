# Google Antigravity Engineering Constitution (GEMINI.md)

This ruleset defines the mandatory engineering standards for all work executed by Gemini in this project and any child directory. It is always active.

---

## 1. Zero-Defect Code Invariants

1. **No Incomplete Implementations or Placeholders**:
   - Never generate comments like `// TODO: implement later`, `/* logic goes here */`, or `pass # fill in`.
   - Every file modified must be completely implemented, syntactically valid, and functional.
2. **Preserve Documentation & Context**:
   - Never delete unrelated comments, docstrings, or architectural notes when making edits.
3. **Defensive Design & Explicit Typing**:
   - Explicitly type all function signatures, public interfaces, and class properties (no untyped `any` or ambiguous dictionaries where strict contracts exist).
   - Validate boundaries, input parameters, and external data at entry points.

---

## 2. Mandatory Verification Gate (Definition of Done)

Before declaring any coding task complete or reporting success to the user, Gemini **MUST** complete this 4-step loop:

1. **Build & Syntax Verification**:
   - Ensure the code compiles, typechecks, or passes static analysis without syntax errors or missing imports.
2. **Automated Testing**:
   - Run relevant unit or integration tests for modified files. If no tests exist for the newly introduced behavior, create unit tests covering happy paths and boundary conditions.
3. **Automated Self-Correction**:
   - If a build, typecheck, or test command fails, do **not** deflect the error or ask the user for help. Read the stack trace, locate the root cause, apply the fix, and re-run verification.
4. **Transparent Evidence**:
   - In your final response, explicitly provide the command executed and its passing result (e.g., `All 14 tests passing`, `tsc --noEmit clean`).

---

## 3. Idiomatic Style & Philosophy

- **Clarity Over Cleverness**: Code must be readable by any junior engineer without explanation. Avoid obscure one-liners and complex regexes when explicit logic is cleaner.
- **Single Source of Truth**: Do not duplicate types, constants, or business logic across modules.
- **Fail Fast & Informatively**: Throw or return structured, descriptive errors rather than silently swallowing exceptions with empty `catch` or `except` blocks.

