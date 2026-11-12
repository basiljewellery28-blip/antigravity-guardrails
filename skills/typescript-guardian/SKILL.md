---
name: typescript-guardian
description: >-
  Enforces Google TypeScript standards, strict type safety, and zero-defect compilation.
  Use whenever authoring, refactoring, or reviewing TypeScript code (.ts, .tsx) or configuring tsconfig.json.
---

# TypeScript Guardian: Google Engineering Protocol

This skill enforces strict, production-grade TypeScript engineering. When writing or refactoring TypeScript, you must adhere to the 4 phases below.

> **Reference** (load on demand):
> - [Google TypeScript Engineering Style Reference](./references/google_ts_style.md): Type system philosophy, nullability and optionals, and function and module boundaries.

---

## Phase 1: Environment & Tooling Discovery

Before writing any TypeScript code:
1. **Locate `tsconfig.json`**:
   - Check compiler options (`strict`, `noImplicitAny`, `exactOptionalPropertyTypes`).
   - If `strict` is false or missing, do NOT disable checks—write code to satisfy the strictest standard.
2. **Identify Package Manager**:
   - Check for `pnpm-lock.yaml`, `package-lock.json`, `bun.lockb`, or `yarn.lock`.
   - Never mix package managers (e.g., do not run `npm install` in a `pnpm` repo).

---

## Phase 2: Google TypeScript Style Invariants

When implementing or editing code, enforce these non-negotiable rules:

### 1. Zero `any` Policy
- **Never use `any`**: Use `unknown` for values of uncertain type, and narrow with type guards or assertion functions before use.
- **Never suppress errors**: Do not add `@ts-ignore` or `@ts-nocheck` without an explicit, documented reason approved by the user.

### 2. Discriminated Unions Over Optional Soup
Instead of an interface with multiple optional properties:
```typescript
// ❌ Anti-pattern: Optional field explosion
interface ApiResponse {
  data?: User;
  error?: string;
  isLoading: boolean;
}

// ✅ Google Standard: Discriminated Union
type ApiResponse =
  | { status: 'loading' }
  | { status: 'success'; data: User }
  | { status: 'error'; error: Error };
```

### 3. Explicit Return Types for Public Boundaries
- All exported functions, class methods, and public API interfaces **must declare explicit return types**.
- Do not let TypeScript infer `any` or loose union types at public module boundaries.

### 4. Safe Type Assertions
- Avoid unsafe `as Type` casts.
- If narrowing is needed, write a type predicate:
  ```typescript
  function isUser(val: unknown): val is User {
    return typeof val === 'object' && val !== null && 'id' in val;
  }
  ```

---

## Phase 3: The Mandatory Verification Gate

You must run automated static analysis before reporting completion.

### Execution:
1. Run the verification script:
   ```powershell
   powershell -File ./skills/typescript-guardian/scripts/verify_ts.ps1
   ```
   Or run the local compiler directly:
   ```bash
   npx tsc --noEmit
   ```
2. **Handle Failures Internally**:
   - If `tsc` outputs errors, read the file and line number.
   - Fix the type errors directly.
   - Re-run verification until exit code is 0.
   - Do **NOT** present uncompiled code to the user.

---

## Phase 4: Verification Evidence

In your response to the user, provide:
1. **Summary of Changes**: What types/interfaces were introduced or modified.
2. **Verification Evidence**: The exact command executed and the clean compiler output (e.g. `npx tsc --noEmit: 0 errors`).

