# Building Tight Pass/Fail Feedback Loops

Adapted from Matt Pocock's bug diagnosis discipline.

The feedback loop is the foundation of debugging. Without a tight, deterministic, red-capable feedback loop, diagnosing complex software defects is slow and error-prone.

---

## 10 Ways to Construct a Tight Feedback Loop

In rough order of preference:

1. **Failing Unit/Integration Test**:
   - Write a test at the closest public seam that reproduces the exact failure mode.
   - Ideal execution speed: < 2 seconds.

2. **HTTP / Curl Script Against Dev Server**:
   - Capture the failing request payload into a local JSON fixture.
   - Run a single curl command diffing response status and body against the expected schema.

3. **CLI Invocation with Fixture**:
   - Invoke the CLI entrypoint directly with targeted arguments.
   - Compare stdout/stderr against a known-good snapshot.

4. **Headless Browser Test**:
   - Use Playwright or Puppeteer to drive the UI to the failing state and assert on network/DOM events.

5. **Captured Trace Replay**:
   - Save a production trace, event stream, or HAR file to disk.
   - Feed the captured payload into the business logic in total isolation.

6. **Throwaway Minimal Harness**:
   - Spin up a minimal script that imports only the target module, mocks out external network dependencies, and invokes the function with the problematic input.

7. **Property / Fuzzing Loop**:
   - If the bug is "intermittent" or "only happens with some inputs", generate 1,000 randomized inputs in a loop until the invariant breaks.

8. **Git Bisection Harness**:
   - When the bug is a regression between two commits, write an automated test script and run:
     ```bash
     git bisect start <bad-commit> <good-commit>
     git bisect run powershell -File ./test_script.ps1
     ```

9. **Differential Loop**:
   - Run the identical input against both the previous working version (or alternate implementation) and the broken version, diffing outputs.

10. **Stress & Timing Loop**:
    - For race conditions, run the repro loop 50x in parallel or inject small artificial delays to widen the concurrency window.

