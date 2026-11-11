---
name: claude-bridge
description: >-
  Analyzes and migrates existing Claude Code projects (CLAUDE.md) into native Antigravity rules and skills.
  Use whenever opening a repository that contains a CLAUDE.md or when transitioning an ongoing project from Claude Code to Google Antigravity.
---

# Claude-to-Antigravity Migration Bridge

This skill provides a structured method to import tribal knowledge, build commands, and rules from a `CLAUDE.md` file into an Antigravity-native workspace without hitting context limits or syntax incompatibilities.

---

## The Migration Protocol

When triggered in a project with an existing `CLAUDE.md`:

### Step 1: Ingest & Categorize
Read `CLAUDE.md` and decompose its contents into 3 distinct categories:

1. **Invariants & Safety Rules**:
   - Style requirements, prohibited patterns, commit conventions, branch rules.
   - *Destination*: `GEMINI.md` in the repository root.
2. **Build, Test & Lint Commands**:
   - Package manager conventions, test runners, build flags.
   - *Destination*: `GEMINI.md` (Quick Command Matrix) and verification scripts.
3. **Multi-Step Workflows**:
   - Deployment sequences, database migration checklists, custom slash commands.
   - *Destination*: Modular Antigravity skills in `.agents/skills/<workflow-name>/SKILL.md`.

---

### Step 2: Translate Platform Differences
Claude Code often relies on POSIX/Bash assumptions. In Antigravity on Windows:
- Ensure scripts use cross-platform node commands (`npm run ...`, `npx ...`) or PowerShell equivalents rather than raw bash builtins (e.g., replace `export VAR=val` with proper environment handling).
- Retain exact package manager lockfile parity (`pnpm`, `npm`, `yarn`, `bun`).

---

### Step 3: Enforce Antigravity Size & Token Limits
- Ensure the generated `GEMINI.md` is strictly under **24 KB** (Antigravity's per-rule limit).
- Move large reference docs, API specifications, and long prose out of `GEMINI.md` into markdown files inside `docs/` or skill `references/` folders.

---

### Step 4: Verification
Run the migration script to automate the initial extraction:
```powershell
powershell -File ./skills/claude-bridge/scripts/migrate_claude.ps1
```
Verify that:
1. `GEMINI.md` is generated at the project root.
2. Any extracted skills in `.agents/skills/` have valid YAML frontmatter (`name` and `description`).
3. Project build and test commands run cleanly.

