---
name: plan-ceo-review
description: Evaluates implementation plans through a founder/CEO lens. Use when reviewing architecture plans, scoping major features, challenging complexity, verifying customer value, or cutting low-leverage work before writing code.
---

# Founder/CEO Plan Review

## Overview

Before engineering begins, review proposals through a founder and CEO lens. High-performing engineering teams don't just build things right — they ensure they are building the *right things*. This skill stress-tests assumptions, cuts scope creep, and focuses strictly on high-leverage outcomes.

## Founder Review Framework

```
1. LEVERAGE  → Is this the highest-leverage way to solve the customer problem?
2. SIMPLICITY→ Can 80% of the value be delivered with 20% of the code?
3. RISKS     → What are the silent killers (vendor lock-in, migration trap, scale bottleneck)?
4. SEAMS     → Are public API contracts and user-facing workflows clear and minimal?
5. METRICS   → How will we empirically measure success after deployment?
```

## Review Checklist

- [ ] **Problem Clarity**: Is the core problem statement validated with concrete user friction?
- [ ] **Scope Minimization**: What can be removed from V1 without reducing customer value?
- [ ] **Architecture Sanity**: Does this introduce unnecessary microservices, external dependencies, or complex state machines?
- [ ] **Rollback Feasibility**: If this deployment fails at 2:00 AM, is rollback instantaneous and non-destructive?
- [ ] **Non-Negotiables**: Are security, latency, and data integrity guarantees explicit?

