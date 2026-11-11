# Google Java Style & Engineering Reference

This reference distills the Google Java Style Guide into actionable agentic rules.

---

## 1. Naming & Formatting Conventions

- **Indentation**: 2 spaces per indentation level. Never use tab characters.
- **Package Names**: All lowercase, consecutive words concatenated (e.g. `com.example.deepspace`).
- **Class Names**: UpperCamelCase (e.g. `AccountService`, `HttpRequestHandler`).
- **Method Names**: lowerCamelCase (e.g. `sendMessage()`, `calculateTotalTax()`).
- **Constants**: UPPER_SNAKE_CASE (e.g. `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT_MS`).

---

## 2. Modern Java Best Practices

- **Avoid Raw Types**: Use parameterization (`List<String>`, not `List`).
- **Immutable State**: Mark fields `final` wherever possible.
- **Records**: Use `record` for all pure data transfer objects.
- **Streams & Lambdas**: Prefer streams for readable data manipulation, but avoid multi-level nested streams that hurt readability.
- **Exception Discipline**: Do not catch `Throwable` or `Exception` indiscriminately. Catch specific checked/unchecked exceptions and preserve the cause.

