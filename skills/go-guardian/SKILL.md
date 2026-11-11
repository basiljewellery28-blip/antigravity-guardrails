---
name: go-guardian
description: >-
  Enforces Google Go standards, idiomatic error handling, table-driven unit tests, race detector verification, and go vet static analysis.
  Use whenever authoring, refactoring, or reviewing Go code (.go) or configuring go.mod or go.work.
---

# Go Guardian: Idiomatic Go Engineering Protocol

This skill enforces strict, production-grade Go engineering based on Google's Go Style Decisions and Effective Go standards.

---

## Phase 1: Environment & Module Discovery

Before writing or editing Go code:
1. **Locate `go.mod`**:
   - Check the Go version and declared dependencies.
   - Run `go mod tidy` if adding or updating third-party packages.

---

## Phase 2: Idiomatic Go Style Invariants

When implementing or editing code, enforce these non-negotiable rules:

### 1. Explicit Error Handling
- **Never ignore errors**: Every `error` return must be explicitly checked:
  ```go
  res, err := client.Do(req)
  if err != nil {
      return nil, fmt.Errorf("executing request to %s: %w", req.URL, err)
  }
  ```
- Never use the blank identifier `_` to suppress an error return.
- Never use `panic` for normal control flow or expected runtime errors. Only panic during unrecoverable initialization failures.

### 2. Table-Driven Tests
- All unit tests should follow the canonical table-driven pattern:
  ```go
  func TestValidateEmail(t *testing.T) {
      tests := []struct {
          name    string
          input   string
          wantErr bool
      }{
          {name: "valid email", input: "user@example.com", wantErr: false},
          {name: "missing domain", input: "user@", wantErr: true},
      }
      for _, tt := range tests {
          t.Run(tt.name, func(t *testing.T) {
              err := ValidateEmail(tt.input)
              if (err != nil) != tt.wantErr {
                  t.Errorf("ValidateEmail() error = %v, wantErr %v", err, tt.wantErr)
              }
          })
      }
  }
  ```

### 3. Concurrency & Goroutine Safety
- Never start a goroutine without knowing how and when it will stop (avoid goroutine leaks).
- Pass `context.Context` as the first parameter to functions performing I/O.

---

## Phase 3: The Mandatory Verification Gate

You must run automated static checks and the race detector before reporting completion.

### Execution:
1. Run the verification script:
   ```powershell
   powershell -File ./skills/go-guardian/scripts/verify_go.ps1
   ```
   Or run the toolchain directly:
   ```bash
   go vet ./...
   go test -race ./...
   ```
2. **Handle Failures Internally**:
   - Fix lint or race conditions immediately.
   - Re-run verification until exit code is 0.
   - Do **NOT** present broken code to the user.

---

## Phase 4: Verification Evidence

In your response to the user, provide:
1. **Summary of Changes**: What packages, structs, and interfaces were updated.
2. **Verification Evidence**: The exact command executed and passing test output (e.g. `ok github.com/user/pkg 0.241s [PASS]`).

