# Google TypeScript Engineering Style Reference

This reference distills the core conventions from Google's TypeScript style guide.

---

## 1. Type System Philosophy

- **Nominal vs. Structural Typing**: TypeScript is structural. When distinction between identical structures is needed (e.g., `UserId` vs `OrderId`), use branded types:
  ```typescript
  type Brand<K, T> = K & { readonly __brand: T };
  export type UserId = Brand<string, 'UserId'>;
  export type OrderId = Brand<string, 'OrderId'>;
  ```

- **Readonly by Default**:
  Mark array properties and objects as `readonly` unless mutation is explicitly required:
  ```typescript
  interface Config {
    readonly host: string;
    readonly ports: readonly number[];
  }
  ```

---

## 2. Nullability and Optionals

- **Prefer `undefined` over `null`**:
  Standardize on `undefined` for missing values, optional parameters, and uninitialized state. Only use `null` when interfacing with external libraries (e.g., DOM APIs or JSON schemas) that strictly demand it.
- **Nullish Coalescing & Optional Chaining**:
  Use `??` and `?.` instead of verbose boolean logic (`foo && foo.bar ? foo.bar : default`).

---

## 3. Function & Module Boundaries

- **Single Responsibility Principle**:
  A file should export one cohesive primary class, interface, or set of related utility functions.
- **No Side Effects on Import**:
  Importing a module must never execute top-level network requests, mutate global state, or start servers. All execution must be contained within callable functions.
- **Error Handling**:
  Functions that can fail should either throw structured custom `Error` classes or return a `Result<T, E>` type rather than returning untyped strings or `null`.

