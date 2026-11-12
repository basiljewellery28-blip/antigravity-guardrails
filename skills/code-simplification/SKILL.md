---
name: code-simplification
description: >-
  Simplifies code for clarity, reducing cognitive load while preserving exact behavior.
  Use when refactoring working code that is dense, overcomplicated, deeply nested, or difficult to comprehend.
---

# Code Simplification Protocol

Adapted from Addy Osmani's engineering skills and modern refactoring disciplines.

The goal of simplification is not fewer lines of code—it is code that is **faster to read, understand, modify, and debug**. Every simplification must pass this test: *"Would a new engineer understand this faster than the original?"*

> **Reference** (load on demand):
> - [Core Refactoring & Simplification Patterns](./references/refactoring_patterns.md): Replacing nested conditionals with guard clauses, and decomposing heavy chained pipelines.

---

## The Five Principles of Simplification

### 1. Preserve Behavior Exactly
- All inputs, outputs, side effects, error behavior, and edge cases must remain identical.
- Existing tests must pass without any modifications.

### 2. Follow Project Conventions
- Match existing naming, import ordering, and error handling patterns.
- Do not introduce foreign syntax or external libraries just to save two lines.

### 3. Prefer Clarity Over Cleverness
- Explicit code beats dense one-liners:
  - Replace nested ternary chains (`a ? b : c ? d : e`) with readable `switch` or `if/else` statements.
  - Replace complex chained `.reduce()` operations with clear, named loops.

### 4. Flatten Deep Nesting
- Use **Guard Clauses** and early returns:
  ```typescript
  // ❌ Dense nesting
  function processOrder(order) {
    if (order) {
      if (order.items.length > 0) {
        if (order.isPaid) {
          // logic
        }
      }
    }
  }

  // ✅ Flattened with Guard Clauses
  function processOrder(order) {
    if (!order || order.items.length === 0 || !order.isPaid) return;
    // logic
  }
  ```

### 5. Maintain Balance (Avoid Over-Simplification)
- Do not inline a helper function if removing it obscures a domain concept.
- Do not merge two independent functions into one just to reduce file count.

---

## Verification Gate: Cognitive Complexity Audit

Before concluding a simplification task, run the complexity scanner:
```powershell
powershell -File ./skills/code-simplification/scripts/verify_cognitive_complexity.ps1
```
The script flags functions with excessive nesting depth (> 4 levels) or extreme line length.

