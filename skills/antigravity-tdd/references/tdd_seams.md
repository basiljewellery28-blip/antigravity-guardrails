# Seams & Public Interface Testing Reference

Adapted and elevated from TDD practices and architectural principles.

---

## 1. What is a Seam?

A **seam** is a place where you can alter behavior or observe state without editing the code behind it. In software testing, a seam is the public boundary of a module:
- An exported function or class method.
- An HTTP API route handler.
- A public message/event consumer.

**The Golden Rule**: Never test private methods or internal collaborator states. If private logic is too complex to test via the public seam, that logic belongs in its own deep module with its own public seam.

---

## 2. Vertical Slices vs. Horizontal Slicing

- **Horizontal Slicing (Anti-pattern)**:
  - Day 1: Write all 15 tests.
  - Day 2: Write all database tables.
  - Day 3: Write business logic.
  - *Result*: Imagined behavior, tight coupling, and painful refactoring.

- **Vertical Slicing (Google / Antigravity Standard)**:
  - Cycle 1: Write 1 test for the simplest happy path $\rightarrow$ Implement minimal working code $\rightarrow$ Pass.
  - Cycle 2: Write 1 test for the primary error condition $\rightarrow$ Implement defensive check $\rightarrow$ Pass.
  - Cycle 3: Refactor common logic, verify all tests remain green.
  - *Result*: Continuous verification, zero unvalidated assumptions.

