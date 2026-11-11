---
name: bug-hunter
description: >-
  Disciplined scientific diagnosis loop for complex bugs, flaky test failures, and performance regressions.
  Use whenever the user asks to diagnose, debug, investigate broken behavior, or fix an intermittent or hard-to-reproduce bug.
---

# Bug Hunter: Scientific Diagnosis Protocol

Adapted from Matt Pocock's bug diagnosis discipline and Google Site Reliability Engineering standards.

When a bug is difficult or non-obvious, **guessing and staring at code is strictly prohibited**. You must follow this 6-phase scientific loop.

---

## 🔒 Secret Redaction Requirement
Before displaying terminal outputs or trace files to the user:
- Replace all credentials, API keys, tokens, and private identifiers with `<REDACTED>`.
- Use environment variables so credentials remain in the environment, not in chat artifacts.

---

## Phase 1: Build a Tight, Red-Capable Feedback Loop

**This is 90% of debugging.** If you have a tight pass/fail signal that goes red on *this* bug, finding the cause is mechanical. Without one, no amount of guessing will solve it.

### Criteria for the Loop Command:
- [ ] **Red-Capable**: Drives the actual bug code path and asserts the user's exact symptom.
- [ ] **Deterministic**: Returns the same verdict every run (or high repro rate for intermittent bugs).
- [ ] **Fast**: Runs in seconds, not minutes.
- [ ] **Agent-Runnable**: Can be executed without manual GUI clicking.

### Constructing the Loop:
1. **Failing Unit / Integration Test** at the public seam.
2. **CLI / API Invocation**: A script with fixture data diffing output against expected state.
3. **Flaky Bug Repetition**: If the bug is intermittent, run the reproduction script:
   ```powershell
   powershell -File ./skills/bug-hunter/scripts/repro_loop.ps1 -Command "<test-command>" -Iterations 25
   ```

> 🛑 **STOP**: Do NOT read code to form theories until you have executed this command and watched it go RED.

---

## Phase 2: Reproduce & Minimise

1. **Verify the Symptom**: Confirm that the failure matches what the user described, not an unrelated error.
2. **Minimise the Repro**: Cut inputs, config options, headers, and steps **one by one**, re-running the loop after each cut.
3. **Done when every remaining element is load-bearing**: Removing any one element causes the test to pass.

---

## Phase 3: Rank 3 to 5 Falsifiable Hypotheses

Generate **3 to 5 ranked hypotheses** before testing any of them. Never anchor on the first plausible idea.

Every hypothesis must be **falsifiable**:
> Format: *"If [X] is the cause, then [changing Y] will make the bug disappear, and [changing Z] will make it worse."*

If you cannot state a falsifiable prediction, the hypothesis is a vibe. Discard or sharpen it.

---

## Phase 4: Targeted Instrumentation

1. **Change One Variable at a Time**.
2. **Tag Every Debug Log**: Prefix every temporary debug statement with a unique ID:
   ```typescript
   console.log('[DEBUG-e8f1] Payload received:', payload);
   ```
   ```python
   print(f"[DEBUG-e8f1] Cache lookup result: {cached_val}")
   ```
   *Why*: Unique tags prevent temporary debug logs from leaking into production.
3. For performance regressions, never guess: use high-resolution timers (`performance.now()`) or profilers.

---

## Phase 5: Regression Test & Targeted Fix

1. Turn the minimised reproduction into a permanent regression test at the public seam.
2. Verify that the regression test is **RED**.
3. Apply the minimal fix to address the root cause.
4. Verify that the regression test turns **GREEN**.
5. Re-run the full project verification suite to ensure zero regressions.

---

## Phase 6: Automated Cleanup

Before declaring the task complete:
1. Run the debug cleanup script to ensure zero temporary logs survive:
   ```powershell
   powershell -File ./skills/bug-hunter/scripts/clean_debug_tags.ps1
   ```
2. Verify that the original Phase 1 loop passes cleanly.
3. Summarize the confirmed root cause and the evidence in your response.
