---
name: antigravity-tdd
description: >-
  Enforces strict Test-Driven Development (TDD) at public seams across TypeScript, Python, Go, C#, and Java.
  Use whenever adding a new feature, fixing a bug test-first, refactoring, or when the user mentions TDD, unit tests, or red-green-refactor.
---

# Antigravity TDD: Seam-Driven Development Protocol

This skill enforces disciplined Test-Driven Development (TDD) across all supported programming languages. It ensures every feature or bug fix begins with a verifiable, failing test at a **public seam** before any implementation code is written.

---

## What a Good Test Is

Tests verify **behavior through public interfaces (seams)**, not internal implementation details:
- If you refactor internal code without changing observable behavior, tests must not break.
- Avoid **tautological tests** (tests that pass trivially by recalculating results the exact same way as the code).
- Work in **vertical slices** (one test $\rightarrow$ one minimal implementation $\rightarrow$ repeat).

> 📖 **Deep References**:
> - [Good vs. Bad Tests](./references/good_vs_bad_tests.md): Observable behavior vs implementation coupling.
> - [When and How to Mock](./references/mocking.md): Mocking only at external system boundaries.
> - [Seams and Public Interfaces](./references/tdd_seams.md): Vertical slicing and interface vocabulary.

---

## The 3-Step Seam Loop

```
  ┌────────────────────────────────────────────────────────┐
  │ 1. RED: Write failing test at public interface seam     │
  │    └─► Run test runner: PROVE it fails for expected reason
  ├────────────────────────────────────────────────────────┤
  │ 2. GREEN: Write minimal code to pass test               │
  │    └─► Run test runner: PROVE it passes                │
  ├────────────────────────────────────────────────────────┤
  │ 3. REFACTOR & HARDEN: Clean up code & verify invariants │
  │    └─► Run full suite: ZERO regressions                │
  └────────────────────────────────────────────────────────┘
```

---

## Multi-Stack Test Runner Automation

Use the automated seam runner to execute only the targeted test file:
```powershell
powershell -File ./skills/antigravity-tdd/scripts/run_seam_test.ps1 -TestFile <path-to-test>
```

Supported test environments:
- **TypeScript / JavaScript**: Vitest, Jest, Mocha (`npm test`, `pnpm test`, `npx vitest run`)
- **Python**: Pytest (`pytest <test-file>`)
- **Go**: Go test (`go test -v <package>`)
- **C#**: `dotnet test --filter <TestName>`
- **Java**: Maven / Gradle test filters (`./mvnw test -Dtest=<TestClass>`)

---

## Anti-Patterns Strictly Prohibited

1. **Horizontal Slicing**: Writing 20 tests upfront before writing any code. Always build vertical slices one tracer bullet at a time.
2. **Mocking Everything**: Never mock the unit under test. Mock only external, slow, or non-deterministic boundaries (network, clock, filesystem).
3. **Skipping the Red Phase**: Never write implementation code before proving that the test genuinely fails.
