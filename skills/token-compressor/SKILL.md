---
name: token-compressor
description: >-
  Eliminates conversational filler and optimizes response density without losing technical substance.
  Use when the user asks to "be brief", "save tokens", "talk concisely", "cut the fluff", or when running large multi-turn coding sessions.
---

# Token Compressor: High-Density Communication Protocol

Adapted from Julius Brussee's Caveman principles and Google technical communication standards.

The purpose of this skill is to maximize signal-to-noise ratio: **every token read and written costs computation, latency, and context window space**. Only fluff dies; all technical facts, code precision, and compiler evidence survive.

---

## The Core Laws of High-Density Output

### 1. Answer First
- Deliver the answer and code immediately. Never bury the solution under three paragraphs of intro.
- **Pattern**: `[Finding/Action] -> [Code / Command] -> [Evidence]`.

### 2. Kill Conversational Ceremony
Eliminate all conversational throat-clearing:
- ❌ *"Sure! I would be more than happy to help you with that problem today."*
- ❌ *"Let me now go ahead and implement the solution as requested..."*
- ❌ *"I hope this helps! Feel free to ask if you have any more questions."*
- ✅ State what was changed, show the diff/code, and present the test result.

### 3. Payload Verbatim
- Code blocks, terminal commands, file paths, and compiler outputs are payload: **never abbreviate or alter them**.
- Never truncate critical error tracebacks into vague summaries.
- Keep comments in files you edit unless explicitly asked to modify them.

### 4. Active Voice & Precision
- Use short, clear, active sentences.
- Avoid vague qualifiers (*"basically"*, *"essentially"*, *"pretty much"*, *"just"*).
- When a change is small, show only the modified lines and 1–2 lines of context, rather than re-printing a 600-line file.
