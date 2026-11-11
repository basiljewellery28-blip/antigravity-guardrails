# 🚀 Antigravity Polyglot Engineering Guardrails

> **Production-grade skills, active invariants, and security sentinels for Google Antigravity (Gemini).**  
> Enforce Google-quality code across **TypeScript, Python, C#, Java, Go, and Rust**, eliminate agent drift, surgically modify code without overengineering, systematically diagnose bugs, secure against OWASP vulnerabilities, automate pre-commit gates, and transition smoothly from Claude Code without losing project context.

---

## 🎯 The Problems We Solve

### 1. The "Agent Drift" Problem (Say One Thing, Do Another)
When AI coding agents write code without active guardrails, they frequently:
- Leave `// TODO: implement later` or placeholder stubs.
- Suppress type errors with `any`, `@ts-ignore`, `# type: ignore`, or empty `catch` blocks.
- Declare that code is tested and working without actually executing compilers or test suites.

**Our Fix**: Every language guardian includes a **Mandatory Verification Gate**. Gemini is bound by an active contract to run automated compilers and test suites before reporting completion, self-correcting errors internally.

### 2. Overengineering & Adjacent Code Vandalism (Karpathy Pitfalls)
Agents naturally invent speculative abstractions, rewrite adjacent working code, and introduce unrequested complexity.

**Our Fix**: The **`karpathy-surgical-coder`** enforces the 3 Laws: Think before coding, minimum code that works (no single-use factories or speculative flags), and surgical edits (touching only the exact lines requested).

### 3. Leaked Secrets & OWASP Security Vulnerabilities
Agents often generate vulnerable code patterns (e.g. string-concatenated SQL queries, exposed credentials, missing input schemas) and leak sensitive `.env` files into Git.

**Our Fix**: Active AppSec sentinels audit code for high-entropy secrets (`scan_secrets.ps1`), test dependencies for CVEs (`audit_deps.ps1`), and block dangerous code patterns (`verify_sast_patterns.ps1`).

### 4. Conversational Fluff & Context Window Waste
Verbose pleasantries ("Sure! I would be more than happy to...") waste tokens, slow down responses, and consume context.

**Our Fix**: The **`token-compressor`** enforces dense, high-signal communication: answer first, zero conversational ceremony, active voice, and payload preservation.

---

## 📦 Complete Skills Catalog (16 Active Skills)

### 🧠 Software Architecture & Code Quality
| Skill | Category | Source Inspiration | Standards & Guarantees Enforced |
| :--- | :--- | :--- | :--- |
| **`karpathy-surgical-coder`** | Surgical Engineering | Andrej Karpathy | Think before coding, zero speculative code, no adjacent file mutations. |
| **`api-interface-design`** | Contract-First API Design | Addy Osmani / Google | Hyrum's Law, deep modules, consistent error semantics, idempotent mutations. |
| **`code-simplification`** | Cognitive Load Reduction | Addy Osmani / Anthropic | Preserve behavior exactly, flatten nesting with guard clauses, clarity over cleverness. |
| **`token-compressor`** | High-Density Communication | Julius Brussee (Caveman) | Answer first, zero fluff/ceremony, token efficiency, code payload exactness. |

### 🛡️ Application Security & Hygiene
| Skill | Category | Verification Runner | Guarantees & Invariants |
| :--- | :--- | :--- | :--- |
| **`security-secret-sentinel`** | Credential Leak Defense | `scan_secrets.ps1` | Zero hardcoded keys (AWS, GitHub, JWT, Google), mandatory `.env` gitignore verification. |
| **`security-dependency-auditor`** | Supply Chain Security | `audit_deps.ps1` | Zero High/Critical CVEs (`npm audit`, `pip-audit`, `dotnet list --vulnerable`, `cargo audit`). |
| **`owasp-secure-coding`** | AppSec / OWASP Top 10 | `verify_sast_patterns.ps1` | Parameterized queries only (SQLi), strict schema validation (Zod/Pydantic), XSS/CSRF defense. |

### 🔬 Reliability & TDD
| Skill | Category | Verification Runner | Guarantees & Invariants |
| :--- | :--- | :--- | :--- |
| **`bug-hunter`** | Scientific Debugging | `repro_loop.ps1` & `clean_debug_tags.ps1` | Fast pass/fail feedback loops, 3–5 falsifiable hypotheses, zero leaked debug logs. |
| **`antigravity-tdd`** | Polyglot TDD | `run_seam_test.ps1` | Red-Green-Refactor loop, public seam testing, vertical slicing, anti-tautological checks. |

### ⚡ Polyglot Language Guardians
| Skill | Language / Stack | Verification Runner | Guarantees & Invariants |
| :--- | :--- | :--- | :--- |
| **`typescript-guardian`** | TypeScript / JS | `verify_ts.ps1` (`tsc --noEmit`) | Zero `any` policy, discriminated unions, explicit return types. |
| **`python-guardian`** | Python | `verify_py.ps1` (`mypy` / `pytest`) | 100% type annotations, no bare `except:`, frozen dataclasses. |
| **`rust-guardian`** | Rust (Cargo) | `verify_rust.ps1` (`cargo clippy` & `test`) | Strict memory safety, zero `unwrap()` in production, zero clippy warnings. |
| **`csharp-guardian`** | C# (.NET 8/9) | `verify_csharp.ps1` (`dotnet build --warnaserror`) | Nullable reference types, records, async cancellation tokens. |
| **`java-guardian`** | Java (Maven / Gradle) | `verify_java.ps1` (`mvn test` / `gradle test`) | Google Java Style, records, zero raw types, immutability. |
| **`go-guardian`** | Go | `verify_go.ps1` (`go vet` & `go test -race`) | Explicit error checks, zero panics, table-driven tests, race detection. |

### 🌉 Cross-Agent Bridge
| Skill | Category | Verification Runner | Guarantees & Invariants |
| :--- | :--- | :--- | :--- |
| **`claude-bridge`** | Model Handoff | `migrate_claude.ps1` | Deconstructs `CLAUDE.md` into token-safe `GEMINI.md` (<24 KB) + skills. |

---

## 🚀 1-Click Installation & Setup

### Global Installation (Recommended)
Install all 16 skills globally into Antigravity with a single command:

**On Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

**On Linux / macOS (Bash):**
```bash
chmod +x ./install.sh && ./install.sh
```

---

## 🛡️ Optional: Install Git Pre-Commit Guardrails
Automatically block any `git commit` that introduces exposed API keys or dangerous OWASP patterns:

**On Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File .\setup-hooks.ps1
```

**On Linux / macOS:**
```bash
chmod +x ./setup-hooks.sh && ./setup-hooks.sh
```

---

## 🤝 Standing on the Shoulders of Giants

This project incorporates and builds upon architectural insights from:
- **Google Engineering Practices**: Readability, strict testing, and clean module boundaries.
- **[Andrej Karpathy's Insights](https://github.com/multica-ai/andrej-karpathy-skills)**: Core discipline on LLM coding pitfalls, surgical edits, and simplicity.
- **[Addy Osmani's Agent Skills](https://github.com/addyosmani/agent-skills)**: Senior engineering practices, API interface design, and code simplification.
- **[Matt Pocock's Skills](https://github.com/mattpocock/skills)**: Pioneering work on TDD seams, tight feedback loops, and agent ergonomics.
- **[Julius Brussee's Caveman](https://github.com/JuliusBrussee/caveman)**: High-density token compression and zero-fluff active voice.
- **[Mukul's Cybersecurity Skills](https://github.com/mukul975/Anthropic-Cybersecurity-Skills)**: Structured threat framework mappings and AppSec sentinels.

---

## 📄 License
MIT License. Feel free to use, fork, and contribute!
