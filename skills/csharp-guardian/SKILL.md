---
name: csharp-guardian
description: >-
  Enforces modern C# (.NET) standards, nullable reference types, zero compiler warnings, and automated xUnit/NUnit test validation.
  Use whenever authoring, refactoring, or reviewing C# code (.cs) or modifying .csproj, .sln, or NuGet configurations.
---

# C# Guardian: .NET Engineering Protocol

This skill enforces strict, production-grade C# engineering adhering to modern .NET practices and zero-defect compiler standards.

> **Reference** (load on demand):
> - [Modern C# (.NET) Style & Architecture Reference](./references/csharp_style.md): Type safety and language features, async programming, and dependency injection with service lifetimes.

---

## Phase 1: Environment & Solution Discovery

Before writing or editing C# code:
1. **Locate Solution & Project Files**:
   - Check for `.sln` or `.csproj` files to determine the .NET target framework (e.g. `net8.0`, `net9.0`).
2. **Verify Nullable Reference Settings**:
   - Ensure `<Nullable>enable</Nullable>` and `<ImplicitUsings>enable</ImplicitUsings>` are set in the `.csproj`.
   - Never disable nullable checks with `#nullable disable` without explicit user permission.

---

## Phase 2: Modern C# Style Invariants

When implementing or editing code, enforce these non-negotiable rules:

### 1. Null Safety & Nullable Reference Types
- Every type is assumed non-nullable by default. Append `?` only when `null` is a valid domain state (e.g., `string?`).
- Guard against null at entry points using `ArgumentNullException.ThrowIfNull(param)`.
- Avoid the null-forgiving operator (`!`) unless proven safe by static state.

### 2. Immutability & Value Objects
- Prefer `record` and `record struct` for domain events, DTOs, and value objects:
  ```csharp
  public sealed record UserProfile(Guid Id, string Username, string Email);
  ```
- Use `init`-only setters and `IReadOnlyList<T>` / `IReadOnlyDictionary<TKey, TValue>` for public collection properties.

### 3. Async/Await & Resource Management
- Always pass `CancellationToken cancellationToken = default` down the call stack in asynchronous methods.
- Never use `.Result` or `.Wait()` on asynchronous Tasks (prevents thread pool starvation and deadlocks).
- Use `await using` or `using` declarations for `IDisposable` and `IAsyncDisposable` resources.

### 4. Zero Warning Invariant
- Code must compile with zero warnings: `<TreatWarningsAsErrors>true</TreatWarningsAsErrors>`.

---

## Phase 3: The Mandatory Verification Gate

You must run automated compilation and test validation before reporting completion.

### Execution:
1. Run the verification script:
   ```powershell
   powershell -File ./skills/csharp-guardian/scripts/verify_csharp.ps1
   ```
   Or run the CLI directly:
   ```bash
   dotnet build --warnaserror
   dotnet test --no-build --verbosity normal
   ```
2. **Handle Failures Internally**:
   - Inspect build errors and failed unit test assertions.
   - Fix the code and re-run verification until exit code is 0.
   - Do **NOT** present broken code to the user.

---

## Phase 4: Verification Evidence

In your response to the user, provide:
1. **Summary of Changes**: What classes, records, and endpoints were added or updated.
2. **Verification Evidence**: The exact command executed and the passing output (e.g. `dotnet build: 0 Errors, 0 Warnings; dotnet test: Passed! - Failed: 0, Passed: 12`).

