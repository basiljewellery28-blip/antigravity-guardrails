---
name: karpathy-surgical-coder
description: >-
  Enforces Andrej Karpathy's guidelines against common LLM coding pitfalls: surgical edits, zero speculative code, and simplicity first.
  Use whenever modifying existing code, adding targeted features, refactoring, or when you need to avoid overcomplication and unrequested churn.
---

# Karpathy Surgical Coder Protocol

Derived from Andrej Karpathy's foundational observations on LLM coding pitfalls. This skill counters the natural tendency of AI agents to overengineer, mutate adjacent working code, and generate speculative abstractions.

---

## The Three Laws of Surgical Coding

### 1. Think Before Coding
**Don't assume. Don't hide confusion. Surface tradeoffs.**
- State assumptions explicitly before modifying files.
- If multiple interpretations exist, present them to the user—do not guess silently.
- If a simpler approach exists than what was requested, explain why and push back when warranted.
- If something is unclear or contradictory in the codebase, **stop and ask**.

### 2. Simplicity First
**The minimum code that genuinely solves the problem. Nothing speculative.**
- **No speculative features**: Do not add extra flags, config options, or parameters "just in case".
- **No single-use abstractions**: Do not invent helper classes, generic wrappers, or factory patterns for code that is used in only one place.
- **Ruthless conciseness**: If an implementation is 200 lines and could be written clearly in 50 lines, rewrite it.
- Ask: *"Would a senior engineer say this is overcomplicated?"* If yes, simplify immediately.

### 3. Surgical Changes
**Touch only what you must. Clean up only your own mess.**
- **Zero adjacent mutation**: Never refactor neighboring code, change unrelated comments, or reformat untouched functions.
- **Match existing style**: Adhere strictly to the existing codebase patterns, even if you prefer an alternate style.
- **Never delete unrelated dead code silently**: If you notice dead code elsewhere, point it out to the user—do not delete it unilaterally.
- **Clean up your own orphans**: If your change renders an import, variable, or helper unused, delete it.

---

## Verification Gate: Surgical Diff Audit

Before reporting completion, run the automated diff inspector:
```powershell
powershell -File ./skills/karpathy-surgical-coder/scripts/verify_surgical_diff.ps1
```
The script validates that:
1. No unrequested files were modified.
2. No unused imports or orphan variables were introduced.
3. The diff size is strictly proportional to the task requested.

