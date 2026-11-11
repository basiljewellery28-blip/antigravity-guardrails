# Google Go Style & Philosophy Reference

This reference distills Google's Go Style Guide and Effective Go.

---

## 1. Package Organization & Naming

- **Package Names**: Short, lowercase, concise (e.g. `user`, `http`, `storage`). Avoid underscores or mixedCaps.
- **Avoid Stutter**: Do not repeat the package name in identifiers (e.g., in package `user`, use `user.Profile`, not `user.UserProfile`).
- **Interfaces Belong to Consumers**: Define interfaces where they are consumed, not where they are implemented. Keep interfaces small (1-2 methods).

---

## 2. Error Wrapping & Handling

- **Error Strings**: Start with lowercase letters, do not end with punctuation (e.g., `fmt.Errorf("connecting to host: %w", err)`).
- **Wrap with `%w`**: Use `%w` when callers need to inspect errors with `errors.Is` or `errors.As`.

---

## 3. Goroutine & Memory Management

- **Zero Unbounded Goroutines**: Always use worker pools or channel rate limiters when spawning tasks.
- **Sync Package**: Prefer channels for ownership passing and communication; prefer `sync.Mutex` for simple shared state protection.

