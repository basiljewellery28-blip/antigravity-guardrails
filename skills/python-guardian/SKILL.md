---
name: python-guardian
description: >-
  Enforces Google Python Style standards, strict static type hints (mypy/pyright), and automated test verification.
  Use whenever authoring, refactoring, or reviewing Python code (.py) or configuring pyproject.toml, pytest, or poetry/uv environments.
---

# Python Guardian: Google Engineering Protocol

This skill enforces strict, production-grade Python engineering based on Google Python Style Standards and modern type safety practices.

> **Reference** (load on demand):
> - [Google Python Engineering Style Reference](./references/google_python_style.md): Type annotations and signatures, exception handling, and data structures and classes.

---

## Phase 1: Environment & Tooling Discovery

Before writing or editing Python code:
1. **Identify the Environment & Package Manager**:
   - Check for `uv.lock` (`uv run ...`), `poetry.lock` (`poetry run ...`), `Pipfile` (`pipenv run ...`), or `.venv` virtualenv.
   - Always run commands inside the project's virtual environment or tool wrapper.
2. **Locate Configuration**:
   - Check `pyproject.toml`, `setup.cfg`, or `mypy.ini` for configured Python version targets and linter settings.

---

## Phase 2: Google Python Style Invariants

When implementing or editing code, enforce these non-negotiable rules:

### 1. 100% Type Annotation Coverage
- Every function signature, method parameter, and return value must have explicit type annotations.
- Avoid loose `Any`. Use `Union`, `Optional` (or `X | None` in Python 3.10+), `Protocol`, or `TypeVar` for generics.
- For dictionaries with fixed schemas, use `TypedDict` or `dataclass(frozen=True)` / Pydantic models instead of untyped `dict[str, Any]`.

### 2. Defensive Error Handling
- **Never use bare `except:`**: Always catch explicit exception classes (`except (ValueError, KeyError) as err:`).
- **Fail Fast & Informatively**: Re-raise with context (`raise CustomError("Descriptive error") from err`).
- Never silently swallow exceptions with `pass`.

### 3. Immutability & Clean Data Structures
- Prefer immutable structures: `@dataclass(frozen=True)` or `NamedTuple` for internal data transfer.
- Use list/dict comprehensions for concise, readable transformations; avoid deep nested comprehensions (> 2 loops).

### 4. Explicit Module Boundaries
- Define `__all__` in library modules to make public API surfaces unambiguous.
- Keep imports ordered: Standard library first, third-party packages second, local project imports last.

---

## Phase 3: The Mandatory Verification Gate

You must run automated static analysis and test validation before reporting completion.

### Execution:
1. Run the verification script:
   ```powershell
   powershell -File ./skills/python-guardian/scripts/verify_py.ps1
   ```
   Or run the local toolchain:
   ```bash
   # Type check
   mypy . --strict   # or pyright
   # Test suite
   pytest
   ```
2. **Handle Failures Internally**:
   - If typecheck or pytest reports failures, inspect the traceback and fix the code directly.
   - Re-run verification until the exit code is 0.
   - Do **NOT** present unverified code to the user.

---

## Phase 4: Verification Evidence

In your response to the user, provide:
1. **Summary of Changes**: What classes, types, and logic were introduced or modified.
2. **Verification Evidence**: The exact command executed and the passing output (e.g. `pytest: 18 passed, mypy: Success: no issues found`).

