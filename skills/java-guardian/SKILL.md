---
name: java-guardian
description: >-
  Enforces Google Java Style standards, modern Java 17/21+ features (records, pattern matching), and automated Maven/Gradle build and test verification.
  Use whenever authoring, refactoring, or reviewing Java code (.java) or configuring pom.xml or build.gradle.
---

# Java Guardian: Google Java Engineering Protocol

This skill enforces strict, production-grade Java engineering following the official Google Java Style Guide and modern Java standards.

> **Reference** (load on demand):
> - [Google Java Style & Engineering Reference](./references/google_java_style.md): Naming and formatting conventions, and modern Java best practices.

---

## Phase 1: Build Tool & Environment Discovery

Before writing or editing Java code:
1. **Identify the Build System**:
   - Check for Maven (`pom.xml`, `./mvnw`) or Gradle (`build.gradle`, `build.gradle.kts`, `./gradlew`).
   - Always prefer the project's wrapper script (`mvnw` or `gradlew`) to ensure matching build tool versions.
2. **Target Java Version**:
   - Check Java version compliance (prefer Java 17 LTS / Java 21 LTS features where configured).

---

## Phase 2: Google Java Style Invariants

When implementing or editing code, enforce these non-negotiable rules:

### 1. Immutability & Modern Data Models
- Use `record` for immutable data carriers and DTOs (Java 16+):
  ```java
  public record UserSummary(UUID id, String email, Instant createdAt) {}
  ```
- Use `final` on fields in classes to guarantee thread safety.
- Prefer immutable collection factories: `List.of()`, `Set.of()`, `Map.of()`.

### 2. Null Safety & Optional Handling
- Use `Optional<T>` as a **return type only** when a method may legitimately return no value.
- Never use `Optional<T>` for method parameters or class fields.
- Never call `.get()` on an `Optional` without checking `.isPresent()` first; prefer `.orElseThrow()`, `.orElse()`, or `.map()`.

### 3. Generics & Raw Types
- **Zero Raw Types**: Never declare raw collections like `List list = new ArrayList()`. Always specify type arguments: `List<String> list = new ArrayList<>()`.

### 4. Google Code Formatting
- Block indentation: exactly 2 spaces (no tabs).
- Imports: Never use wildcard imports (`import java.util.*`). Import individual classes explicitly.

---

## Phase 3: The Mandatory Verification Gate

You must run automated compilation and test suites before reporting completion.

### Execution:
1. Run the verification script:
   ```powershell
   powershell -File ./skills/java-guardian/scripts/verify_java.ps1
   ```
   Or run the wrapper directly:
   ```bash
   # Maven
   ./mvnw test-compile test
   # Gradle
   ./gradlew test
   ```
2. **Handle Failures Internally**:
   - Parse compilation errors or failing JUnit test assertions.
   - Fix the code and re-run verification until exit code is 0.
   - Do **NOT** present unverified code to the user.

---

## Phase 4: Verification Evidence

In your response to the user, provide:
1. **Summary of Changes**: What classes, records, and test cases were added or updated.
2. **Verification Evidence**: The exact command executed and the passing output (e.g. `[INFO] Tests run: 8, Failures: 0, Errors: 0, Skipped: 0`).

