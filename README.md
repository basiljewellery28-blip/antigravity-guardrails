# 🚀 Antigravity Polyglot Engineering Guardrails

> **Production-grade skills, active invariants, modular suites, and security sentinels for Google Antigravity (Gemini).**  
> Enforce Google-grade standards across **TypeScript, Python, C#, Java, Go, and Rust**, eliminate agent drift, surgically modify code without overengineering, systematically diagnose bugs, secure against OWASP vulnerabilities, automate pre-commit gates, prevent runaway agent loops, and manage specialized Office, Cloud, and Founder workflows without context bloat.

---

## 🎯 The Problems We Solve

### 1. The "Agent Drift" Problem (Say One Thing, Do Another)
When AI coding agents write code without active guardrails, they frequently:
- Leave `// TODO: implement later` or placeholder stubs.
- Suppress type errors with `any`, `@ts-ignore`, `# type: ignore`, or empty `catch` blocks.
- Declare that code is tested and working without actually executing compilers or test suites.

**Our Fix**: Every language guardian includes a **Mandatory Verification Gate**. Gemini is bound by an active contract to run automated compilers and test suites before reporting completion, self-correcting errors internally.

### 2. Context Starvation & The "300-Skill Trap"
Naive agent repositories dump 300+ skills into a single directory. In Antigravity, every skill's `name` and `description` are loaded into system prompts on turn 1. 300 skills consume 25,000+ tokens on every turn before you even speak!

**Our Fix**: A **Two-Tier Architecture**:
- **Core Engineering Skills (21)**: Loaded into `skills/` for everyday polyglot coding, AppSec, Git hygiene, and architecture.
- **Modular Domain Suites (3 Suites / 11 Skills)**: Packaged into `suites/` (`document-suite`, `founder-suite`, `cloud-suite`) and installed on-demand via `install-suite.ps1`.

### 3. Overengineering & Codebase Slop (Karpathy & Garry Tan Pitfalls)
Agents naturally invent speculative abstractions, rewrite adjacent working code, generate duplicate wrappers, and enter runaway infinite loops.

**Our Fix**: 
- **`karpathy-surgical-coder`**: Think before coding; minimum code that works; surgical line edits only.
- **`deslop-codebase`**: Ruthlessly purges dead wrappers, empty exception catches, and hallucinated boilerplate.
- **`runaway-stopper`**: Automated circuit breaker halting infinite retry loops and process leakage.

### 4. Leaked Secrets & OWASP Security Vulnerabilities
Agents often generate vulnerable patterns (SQL injection, unsafe innerHTML, unvalidated schemas) and accidentally leak `.env` files into Git.

**Our Fix**: Active AppSec sentinels audit code for high-entropy secrets (`scan_secrets.ps1`), test dependencies for CVEs (`audit_deps.ps1`), and block dangerous code patterns (`verify_sast_patterns.ps1`) before commits land.

---

## 📦 Complete Catalog (32 Production Skills)

### 🧠 Software Architecture, Simplicity & Hygiene (Core)
| Skill | Category | Verification Runner | Standards & Guarantees Enforced |
| :--- | :--- | :--- | :--- |
| **`karpathy-surgical-coder`** | Surgical Engineering | `verify_surgical_diff.ps1` | Think before coding, zero speculative code, zero adjacent file mutations. |
| **`api-interface-design`** | Contract-First API Design | `verify_api_surface.ps1` | Hyrum's Law, deep modules, consistent error semantics, idempotent mutations. |
| **`code-simplification`** | Cognitive Load Reduction | `verify_cognitive_complexity.ps1` | Preserve behavior exactly, flatten nesting with guard clauses, reduce complexity. |
| **`deslop-codebase`** | Anti-Boilerplate & Slop | `verify_codebase_slop.ps1` | Zero empty catches, zero placeholder stubs, removal of trivial wrappers. |
| **`runaway-stopper`** | Circuit Breaker & Safety | `check_circuit_breaker.ps1` | Detects and halts runaway subagent loops, oversized logs, and process leakage. |
| **`token-compressor`** | High-Density Communication | Markdown Invariant | Answer first, zero conversational fluff, maximum signal density. |

### ⚡ Polyglot Language Guardians (Core)
| Skill | Language / Stack | Verification Runner | Guarantees & Invariants |
| :--- | :--- | :--- | :--- |
| **`typescript-guardian`** | TypeScript / JS | `verify_ts.ps1` (`tsc --noEmit`) | Zero `any` policy, discriminated unions, explicit return types. |
| **`python-guardian`** | Python | `verify_py.ps1` (`mypy` / `pytest`) | 100% type annotations, no bare `except:`, frozen dataclasses. |
| **`rust-guardian`** | Rust (Cargo) | `verify_rust.ps1` (`cargo clippy` & `test`) | Strict memory safety, zero `unwrap()` in production, zero clippy warnings. |
| **`csharp-guardian`** | C# (.NET 8/9) | `verify_csharp.ps1` (`dotnet build --warnaserror`) | Nullable reference types, records, async cancellation tokens. |
| **`java-guardian`** | Java (Maven / Gradle) | `verify_java.ps1` (`mvn test` / `gradle test`) | Google Java Style, records, zero raw types, immutability. |
| **`go-guardian`** | Go | `verify_go.ps1` (`go vet` & `go test -race`) | Explicit error checks, zero panics, table-driven tests, race detection. |

### 🛡️ Application Security & Delivery (Core)
| Skill | Category | Verification Runner | Guarantees & Invariants |
| :--- | :--- | :--- | :--- |
| **`security-secret-sentinel`** | Credential Leak Defense | `scan_secrets.ps1` | Zero hardcoded keys (AWS, GitHub, JWT, Google), mandatory `.env` gitignore verification. |
| **`security-dependency-auditor`** | Supply Chain Security | `audit_deps.ps1` | Zero High/Critical CVEs (`npm audit`, `pip-audit`, `dotnet list --vulnerable`, `cargo audit`). |
| **`owasp-secure-coding`** | AppSec / OWASP Top 10 | `verify_sast_patterns.ps1` | Parameterized queries only (SQLi), strict schema validation (Zod/Pydantic), XSS defense. |
| **`git-workflow-and-versioning`** | Version Control Hygiene | `verify_git_hygiene.ps1` | Trunk-based git hygiene, Conventional Commits (`feat:`, `fix:`), SemVer 2.0.0. |
| **`browser-testing-with-devtools`** | Frontend / E2E Testing | `verify_browser_suite.ps1` | Zero console errors, DOM layout inspection, network latency assertions. |
| **`performance-optimization`** | Web Vitals & Profiling | `verify_performance.ps1` | Enforces LCP ($\le 2.5\text{s}$), INP ($\le 200\text{ms}$), CLS ($\le 0.1$), zero N+1 queries. |
| **`bug-hunter`** | Scientific Debugging | `repro_loop.ps1` & `clean_debug_tags.ps1` | Fast pass/fail feedback loops, 3–5 falsifiable hypotheses, zero leaked debug logs. |
| **`antigravity-tdd`** | Polyglot TDD | `run_seam_test.ps1` | Red-Green-Refactor loop, public seam testing, vertical slicing, anti-tautological checks. |
| **`claude-bridge`** | Model Handoff | `migrate_claude.ps1` | Deconstructs `CLAUDE.md` into token-safe `GEMINI.md` (<24 KB) + skills. |

---

## 📂 Modular Domain Suites (`suites/`)

### 📄 Document Suite (`suites/document-suite`)
Cross-platform manipulation and programmatic generation of enterprise documents (adapted from Anthropic):
- **`docx`**: Create, edit, style, and redline Word documents (`.docx`).
- **`pdf`**: Inspect, split, merge, and extract structured forms and tables from PDF files.
- **`pptx`**: Build and design PowerPoint presentations with clean layouts and visual themes.
- **`xlsx`**: Financial modeling, cell styling, formulas, and data recalculation in Excel.
- **`mcp-builder`**: Design, scaffold, and test Model Context Protocol (MCP) servers.

### 👔 Founder Suite (`suites/founder-suite`)
High-leverage product, QA, and release management (adapted from Garry Tan's gstack):
- **`plan-ceo-review`**: Founder-mode plan review: eliminate scope bloat, verify customer leverage, stress-test risks.
- **`qa-audit`**: Exhaustive QA matrices, happy-path and boundary verification, real-world user journey simulations.
- **`ship-release`**: Pre-flight release readiness checklist, SemVer bump, automated CHANGELOG generation (`verify_release_readiness.ps1`).

### ☁️ Cloud Suite (`suites/cloud-suite`)
Production operational patterns for Google Cloud (adapted from Google skills):
- **`cloud-run-deploy`**: Container buildpacks, autoscaling, zero-downtime canary deployments, and revision rollbacks.
- **`gcs-storage`**: Bucket provisioning, uniform bucket-level access, signed URLs, and lifecycle retention policies.
- **`bigquery-ops`**: Cost-conscious schema design, daily partitioning, clustering, and dry-run query cost validation.

---

## 🚀 1-Click Installation & Usage

### 1. Install Core Engineering Skills (Global)
Install all 21 core engineering skills directly into your global Antigravity environment (`~/.gemini/config/skills/`):

**On Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

**On Linux / macOS (Bash):**
```bash
chmod +x ./install.sh && ./install.sh
```

### 2. Install Domain Suites (On-Demand)
Install specific domain suites or all suites without polluting your context window:

**On Windows:**
```powershell
# Install all suites (Document, Founder, Cloud):
powershell -ExecutionPolicy Bypass -File .\install-suite.ps1 -Suite all

# Or install only specific suites:
powershell -ExecutionPolicy Bypass -File .\install-suite.ps1 -Suite document
powershell -ExecutionPolicy Bypass -File .\install-suite.ps1 -Suite founder
powershell -ExecutionPolicy Bypass -File .\install-suite.ps1 -Suite cloud
```

**On Linux / macOS:**
```bash
chmod +x ./install-suite.sh
./install-suite.sh all         # or document / founder / cloud
```

---

## 🛡️ Optional: Install Git Pre-Commit Guardrails
Automatically block any `git commit` in your project that introduces leaked API keys or dangerous OWASP patterns:

**Inside this project or any other project on your machine:**
```powershell
powershell -ExecutionPolicy Bypass -File .\setup-hooks.ps1 -TargetDirectory "C:\path\to\your-project"
```

**On Linux / macOS:**
```bash
./setup-hooks.sh /path/to/your-project
```

The hook blocks the commit when PowerShell or the scanner scripts cannot be found; `git commit --no-verify` bypasses it deliberately.

---

## 🤝 Standing on the Shoulders of Giants

This project incorporates and builds upon architectural insights from:
- **Google Engineering Practices**: Readability, strict testing, and clean module boundaries.
- **[Andrej Karpathy's Insights](https://github.com/multica-ai/andrej-karpathy-skills)**: Core discipline on LLM coding pitfalls, surgical edits, and simplicity.
- **[Addy Osmani's Agent Skills](https://github.com/addyosmani/agent-skills)**: Senior engineering practices, API interface design, browser testing, and code simplification.
- **[Garry Tan's gstack](https://github.com/garrytan/gstack)**: Founder-mode CEO reviews, release gating, and runaway thread controls.
- **[Anthropic's Skills](https://github.com/anthropics/skills)**: Enterprise document engines (`docx`, `pdf`, `pptx`, `xlsx`) and MCP architecture.
- **[Matt Pocock's Skills](https://github.com/mattpocock/skills)**: Pioneering work on TDD seams, tight feedback loops, and agent ergonomics.
- **[Julius Brussee's Caveman](https://github.com/JuliusBrussee/caveman)**: High-density token compression and zero-fluff active voice.
- **[Mukul's Cybersecurity Skills](https://github.com/mukul975/Anthropic-Cybersecurity-Skills)**: Structured threat framework mappings and AppSec sentinels.

---

## 📄 License
MIT License. Feel free to use, fork, and contribute!
