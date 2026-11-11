# 🚀 Antigravity Polyglot Engineering Guardrails

> **Production-grade skills, active invariants, and migration bridges for Google Antigravity (Gemini).**  
> Enforce Google-quality code across **TypeScript, Python, C#, Java, and Go**, eliminate agent drift, systematically diagnose complex bugs, and transition smoothly from Claude Code without losing project context.

---

## 🎯 The Problems We Solve

### 1. The "Agent Drift" Problem (Say One Thing, Do Another)
When AI coding agents write code without active guardrails, they frequently:
- Leave `// TODO: implement later` or placeholder stubs.
- Suppress type errors with `any`, `@ts-ignore`, `# type: ignore`, or empty `catch` blocks.
- Declare that code is tested and working without actually executing compilers or test suites.

**Our Fix**: Every language guardian includes a **Mandatory Verification Gate**. Gemini is bound by an active contract to run automated compilers and test suites before reporting completion, self-correcting errors internally.

### 2. Guesswork & Leaked Debug Logs During Bug Fixing
When fixing complex or intermittent bugs, agents often guess random changes without reproducing the issue, and leak temporary `console.log` or `print()` statements into production code.

**Our Fix**: The **`bug-hunter`** skill enforces a 6-phase scientific diagnosis loop: build a deterministic pass/fail feedback loop first, test 3–5 falsifiable hypotheses, tag temporary instrumentation (`[DEBUG-xxxx]`), and automatically purge debug statements with `clean_debug_tags.ps1`.

### 3. The Model Handoff Friction (`CLAUDE.md` $\rightarrow$ Antigravity)
When developers switch from Claude Code to Google Antigravity:
- Claude Code's monolithic `CLAUDE.md` dumps all rules, API docs, and bash scripts into every turn, easily exceeding Antigravity's **24 KB per-rule budget**.
- Bash commands written for Unix crash in Windows PowerShell.
- Context is lost, forcing the developer to re-explain the project from scratch.

**Our Fix**: The **`claude-bridge`** skill intelligently parses `CLAUDE.md`, extracting always-on invariants into a token-budgeted `GEMINI.md` and modularizing procedures into Antigravity skills.

---

## 📦 Polyglot Language & Skills Matrix

| Skill | Category / Stack | Verification Runner | Standards & Guarantees Enforced |
| :--- | :--- | :--- | :--- |
| **`bug-hunter`** | Systematic Debugging | `repro_loop.ps1` & `clean_debug_tags.ps1` | Fast pass/fail feedback loops, 3-5 falsifiable hypotheses, zero leaked debug logs. |
| **`antigravity-tdd`** | Polyglot TDD | `run_seam_test.ps1` | Red-Green-Refactor loop, public seam testing, vertical slicing, anti-tautological checks. |
| **`typescript-guardian`** | TypeScript / JS | `verify_ts.ps1` (`tsc --noEmit`) | Zero `any` policy, discriminated unions, explicit return types. |
| **`python-guardian`** | Python | `verify_py.ps1` (`mypy` / `pytest`) | 100% type annotations, no bare `except:`, frozen dataclasses. |
| **`csharp-guardian`** | C# (.NET 8/9) | `verify_csharp.ps1` (`dotnet build --warnaserror`) | Nullable reference types, records, async cancellation tokens. |
| **`java-guardian`** | Java (Maven / Gradle) | `verify_java.ps1` (`mvn test` / `gradle test`) | Google Java Style, records, zero raw types, immutability. |
| **`go-guardian`** | Go | `verify_go.ps1` (`go vet` & `go test -race`) | Explicit error checks, zero panics, table-driven tests, race detection. |
| **`claude-bridge`** | Cross-Agent Migration | `migrate_claude.ps1` | Deconstructs `CLAUDE.md` into token-safe `GEMINI.md` (<24 KB) + skills. |

---

## 🏗️ Architectural Philosophy: Rules vs. Skills

Antigravity uses **Progressive Disclosure** and a multi-tiered hierarchy:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Project / Directory Rules (GEMINI.md / AGENTS.md)        │ ◄── Always-on guardrails
├─────────────────────────────────────────────────────────────┤
│ 2. Project Skills (.agents/skills/<name>/SKILL.md)          │ ◄── Progressive on-demand
├─────────────────────────────────────────────────────────────┤
│ 3. Global Configuration (~/.gemini/config/skills/)          │ ◄── Machine-wide polyglot skills
├─────────────────────────────────────────────────────────────┤
│ 4. Built-in Agent Engine & Tools                            │ ◄── Core system capabilities
└─────────────────────────────────────────────────────────────┘
```

- **Rules (`GEMINI.md`)**: Hard invariants that are always loaded for their directory scope.
- **Skills (`SKILL.md`)**: Runbooks that load into context only when triggered by relevant tasks or commands.

---

## 🚀 1-Click Installation & Setup

### Global Installation (Recommended)
Make all 8 skills active across **every project** on your machine with one command:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### Project-Specific Installation
Check specific skills directly into Git for your team:

```powershell
# In your target project repository:
New-Item -ItemType Directory -Path ".agents\skills" -Force
Copy-Item -Path "path\to\skills\typescript-guardian" -Destination ".agents\skills\" -Recurse
Copy-Item -Path "path\to\GEMINI.md" -Destination "."
```

---

## 🤝 Standing on the Shoulders of Giants

This project incorporates and builds upon architectural insights from:
- **Google Engineering Practices**: Readability, strict testing, and clean module boundaries.
- **[Matt Pocock's Skills](https://github.com/mattpocock/skills)**: Pioneering work on TDD seams, tight feedback loops, and agent ergonomics.
- **Antigravity Customization Architecture**: Progressive disclosure, directory-scoped rules, and multi-agent coordination.

---

## 📄 License
MIT License. Feel free to use, fork, and contribute!
