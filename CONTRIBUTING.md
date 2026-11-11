# Contributing to Antigravity Skills

Thank you for your interest in contributing! This repository provides production-grade skills, active invariants, and migration bridges for **Google Antigravity (Gemini)**.

Our mission is to **eliminate AI agent drift** and enforce **Google-quality engineering standards** across every major language and framework.

---

## The Core Philosophy: Active Guardrails vs. Passive Prompts

In traditional agent prompt engineering, developers write instructions like *"Please write clean code and test it"*. Agents frequently ignore these instructions during long conversations.

In this repository, **every skill must provide active, verifiable enforcement**:
1. **Clear Semantic Trigger**: A well-crafted YAML frontmatter `description` that tells Antigravity exactly *when* to load the skill.
2. **Deterministic Verification Gate**: A script (`scripts/verify_<stack>.ps1`) that executes the compiler, linter, or test runner. The agent must run this script before declaring completion.
3. **Progressive Disclosure**: Keep `SKILL.md` concise. Deep documentation, language specifications, and style guides belong in `references/` and are loaded on-demand.

---

## Directory Structure for a New Skill

Every skill lives inside `skills/<skill-name>/`:

```text
skills/<skill-name>/
├── SKILL.md                          # Required: Frontmatter + 4-phase protocol
├── scripts/                          # Required: Automated verification runner
│   └── verify_<skill>.ps1            # Cross-platform / PowerShell execution script
└── references/                       # Optional: Detailed architectural & style guides
    └── <topic>_style.md              # Loaded on-demand via progressive disclosure
```

---

## `SKILL.md` Specification

Every `SKILL.md` file must start with valid YAML frontmatter:

```markdown
---
name: my-new-skill
description: >-
  Describe precisely what this skill does and what triggers it.
  Use third person (e.g. "Use whenever authoring, refactoring, or reviewing Rust code (.rs) or configuring Cargo.toml").
---

# Skill Title: Protocol Name

## Phase 1: Environment & Tooling Discovery
Instructions for discovering compiler, package manager, and config files.

## Phase 2: Core Engineering Invariants
Non-negotiable coding standards, type safety requirements, and defensive rules.

## Phase 3: The Mandatory Verification Gate
Instructions commanding the agent to run `./scripts/verify_<skill>.ps1` and self-correct any failures internally.

## Phase 4: Verification Evidence
Instructions requiring the agent to display the passing command and output in its final response.
```

---

## Verification Script Guidelines

1. **Self-Contained & Deterministic**: The script must return exit code `0` on success and non-zero on failure.
2. **Cross-Platform Awareness**: Handle Windows PowerShell paths safely; prefer cross-platform runners (`npx`, `uv`, `mvnw`, `gradlew`, `cargo`, etc.) where available.
3. **Clean Output**: Provide readable terminal output so the agent can parse error line numbers and repair defects autonomously.

---

## Submitting a Pull Request

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/rust-guardian`).
3. Run `.\install.ps1` to test local installation into Antigravity.
4. Verify that your verification scripts run cleanly.
5. Commit your changes (`git commit -m "feat: add rust-guardian skill with cargo test verification"`).
6. Open a Pull Request with a clear description and sample verification output!
