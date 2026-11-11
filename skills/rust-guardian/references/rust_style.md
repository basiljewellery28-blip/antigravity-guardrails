# Idiomatic Rust Engineering Style Reference

This reference distills the Rust API Guidelines and production Rust best practices.

---

## 1. Type Design & Traits

- **Derive Common Traits**:
  Always derive standard traits on public data types where sensible:
  ```rust
  #[derive(Debug, Clone, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
  pub struct UserSession {
      pub user_id: String,
      pub expires_at: i64,
  }
  ```
- **Newtype Pattern**:
  Use tuple structs to enforce type distinctions (e.g. preventing swapping `UserId` with `OrderId`):
  ```rust
  #[derive(Debug, Clone, PartialEq, Eq, Hash)]
  pub struct UserId(pub String);
  ```

---

## 2. Concurrency & Async

- **Tokio & Channels**: Prefer `tokio::sync::mpsc` or `broadcast` for actor communication; use `tokio::sync::Mutex` only across `.await` points.
- **Send + Sync**: Ensure state shared across async tasks implements `Send + Sync + 'static`.

---

## 3. Performance & Allocations

- **Pass by Reference**: Use `&str` instead of `&String`, `&[T]` instead of `&Vec<T>`.
- **Cow (Clone on Write)**: Use `std::borrow::Cow<'a, str>` when data may either be borrowed or owned, avoiding unnecessary string allocations.

