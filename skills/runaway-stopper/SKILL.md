---
name: runaway-stopper
description: Detects and stops runaway agent execution loops, excessive subagent spawning, background task leakage, and runaway token burn. Use whenever managing long-running agent workflows, debugging agent recursion, inspecting active background tasks, or applying safety circuit breakers.
---

# Runaway Stopper & Circuit Breaker

## Overview

Autonomous coding agents can enter infinite loops, repeatedly retry failing commands, spawn deep trees of subagents, or leak background processes that consume API quota and machine resources. The `runaway-stopper` provides a deterministic circuit-breaker mechanism to detect, halt, and clean up runaway execution.

## Circuit Breaker Thresholds

| Vector | Normal Operation | Warning Threshold | Emergency Trip Condition |
| :--- | :--- | :--- | :--- |
| **Active Background Tasks** | $0 - 2$ | $3 - 5$ | $> 5$ unmonitored tasks |
| **Command Retry Depth** | $1 - 2$ | $3$ retries | $> 3$ consecutive identical failures |
| **Subagent Hierarchy** | Depth $1$ | Depth $2$ | Depth $> 2$ recursive delegation |
| **Output Log Growth** | $< 1\text{ MB}$ | $1 - 5\text{ MB}$ | $> 10\text{ MB}$ single tool output |

## Circuit Breaker Actions

1. **TRIP**: Immediately stop further tool invocations or loop iterations.
2. **AUDIT**: Query active tasks via `manage_task` (Action: `list`) or `manage_subagents` (Action: `list`).
3. **TERMINATE**: Kill orphaned background tasks via `manage_task` (Action: `kill`).
4. **ISOLATE**: Write the failure state to a local crash summary before restarting cleanly.

## Automated Circuit Breaker Script

Run the circuit breaker check to inspect and prune orphaned background processes:

```powershell
powershell -ExecutionPolicy Bypass -File .\skills\runaway-stopper\scripts\check_circuit_breaker.ps1
```

POSIX Bash:
```bash
./skills/runaway-stopper/scripts/check_circuit_breaker.sh
```
