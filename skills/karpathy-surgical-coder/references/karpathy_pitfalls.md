# Andrej Karpathy's LLM Coding Pitfalls & Antidotes

A catalog of the most frequent mistakes AI coding assistants make, and the concrete rules to eliminate them.

---

## 1. The Over-Engineering Trap

- **The Pitfall**: The user asks for a simple utility function. The agent generates 3 interfaces, an abstract base factory, a singleton configuration registry, and 150 lines of boilerplate.
- **The Antidote**: Write the smallest amount of code that satisfies the prompt. Single-use code requires zero abstractions.

---

## 2. Silent Assumption Making

- **The Pitfall**: The user gives an ambiguous instruction. The agent silently picks one interpretation, writes 500 lines of code, and only reveals the chosen approach after completing the task.
- **The Antidote**: When multiple interpretations exist, stop and ask before coding. Present the tradeoffs clearly.

---

## 3. Adjacent Code Vandalism

- **The Pitfall**: The agent edits line 45 of a file, but simultaneously reformats indentation across lines 1-120, changes variable names in unrelated functions, and alters comment wording.
- **The Antidote**: Touch only the exact lines required for the change. Preserve all neighboring formatting and comments verbatim.

---

## 4. Speculative Error Handling

- **The Pitfall**: Writing complex error fallback logic for internal conditions that can never occur in reality.
- **The Antidote**: Validate boundaries at system entry points. Inside trusted code, fail fast without speculative wrapping.
