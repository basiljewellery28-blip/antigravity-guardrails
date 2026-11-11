# Modern C# (.NET) Style & Architecture Reference

This reference covers modern C# 12+ / .NET 8+ patterns for agentic coding.

---

## 1. Type Safety & Language Features

- **Primary Constructors**:
  Use primary constructors for dependency injection and immutability:
  ```csharp
  public sealed class UserService(IUserRepository userRepository, ILogger<UserService> logger) : IUserService
  {
      public async Task<User> GetByIdAsync(Guid id, CancellationToken ct) =>
          await userRepository.FindByIdAsync(id, ct) ?? throw new KeyNotFoundException($"User {id} not found");
  }
  ```

- **Pattern Matching**:
  Prefer modern switch expressions over verbose `if/else` ladders:
  ```csharp
  public static decimal CalculateDiscount(Customer customer) => customer switch
  {
      { IsVip: true, TotalOrders: > 50 } => 0.20m,
      { IsVip: true } => 0.10m,
      { TotalOrders: > 20 } => 0.05m,
      _ => 0.0m
  };
  ```

---

## 2. Asynchronous Programming

- **ConfigureAwait**: In application code (ASP.NET Core / Console), avoid `.ConfigureAwait(false)` unless writing a reusable general-purpose NuGet library.
- **Task.WhenAll**: When running concurrent independent operations, use `Task.WhenAll` instead of sequential `await`s.

---

## 3. Dependency Injection & Service Lifetimes

- **Transient**: Lightweight, stateless services.
- **Scoped**: Per-request services (e.g. Entity Framework `DbContext`, user identity).
- **Singleton**: Thread-safe global caches or configuration singletons.
- **Never inject Scoped services into Singletons** (causes captive dependency memory leaks).

