---
name: rust-guardian
description: >-
  Enforces idiomatic Rust standards, strict memory safety, zero-warning clippy verification, and automated cargo test execution.
  Use whenever authoring, refactoring, or reviewing Rust code (.rs) or configuring Cargo.toml.
---

# Rust Guardian: Idiomatic Rust Engineering Protocol

This skill enforces strict, production-grade Rust engineering following official Rust API Guidelines and zero-defect compiler standards.

> **Reference** (load on demand):
> - [Idiomatic Rust Engineering Style Reference](./references/rust_style.md): Type design and traits, concurrency and async, and performance and allocations.

---

## Phase 1: Environment & Workspace Discovery

Before writing or editing Rust code:
1. **Locate `Cargo.toml`**:
   - Check if this is a single package or a multi-crate Cargo workspace (`[workspace]`).
   - Check edition (e.g. `edition = "2021"`).
2. **Review Dependencies**:
   - Prefer standard ecosystem crates (`serde`, `tokio`, `thiserror`, `anyhow`, `tracing`).

---

## Phase 2: Idiomatic Rust Invariants

When implementing or editing code, enforce these non-negotiable rules:

### 1. Robust Error Handling (No `unwrap()` in Production)
- **Zero Raw Panics**: Never call `.unwrap()` or `.expect()` in library or application business logic.
- Propagate errors using the `?` operator and return structured `Result<T, E>` types.
- Use `thiserror` for custom domain error enums in libraries; use `anyhow` for top-level application binary error handling:
  ```rust
  #[derive(Debug, thiserror::Error)]
  pub enum StorageError {
      #[error("item not found with id: {0}")]
      NotFound(String),
      #[error("database I/O failure: {0}")]
      Io(#[from] std::io::Error),
  }
  ```

### 2. Memory Safety & Unsafe Policy
- **Zero `unsafe` Policy**: Never introduce `unsafe` blocks unless interfacing with external FFI boundaries. Any `unsafe` block must be accompanied by a formal `// SAFETY:` comment explaining the invariants.

### 3. Borrowing & Immutability
- Prefer borrowed references (`&str`, `&[T]`) over owned allocations (`String`, `Vec<T>`) in function arguments.
- Keep data immutable by default; use `mut` only where in-place mutation provides measurable performance benefits.

### 4. Zero Warning Invariant
- Code must pass `cargo clippy` with zero warnings: `#![deny(clippy::all)]`.

---

## Phase 3: The Mandatory Verification Gate

You must run automated static analysis, clippy, and unit/integration tests before reporting completion.

### Execution:
1. Run the verification script:
   ```powershell
   powershell -File ./skills/rust-guardian/scripts/verify_rust.ps1
   ```
   Or run the toolchain directly:
   ```bash
   cargo check --all-targets
   cargo clippy --all-targets --all-features -- -D warnings
   cargo test
   ```
2. **Handle Failures Internally**:
   - Read compiler error codes (`E0382`, `E0502`, etc.) and borrow-checker messages.
   - Fix the code and re-run verification until exit code is 0.
   - Do **NOT** present unverified code to the user.

---

## Phase 4: Verification Evidence

In your response to the user, provide:
1. **Summary of Changes**: What structs, enums, traits, and functions were added or updated.
2. **Verification Evidence**: The exact command executed and the passing output (e.g. `test result: ok. 14 passed; 0 failed; finished in 0.42s`).

