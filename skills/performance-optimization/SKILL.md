---
name: performance-optimization
description: Diagnoses, measures, and enforces performance thresholds across Web Vitals (LCP, INP, CLS), API latency, query budgets (N+1 queries), and bundle size limits. Use when optimizing frontend or backend code, reducing memory footprints, fixing slow endpoints, or establishing automated performance budgets.
---

# Performance Optimization & Budget Gating

## Overview

Measure before optimizing. Speculative performance improvements often introduce unnecessary complexity without solving the true bottleneck. This skill enforces an empirical 5-stage optimization loop: Measure, Identify, Fix, Verify, and Guard.

## Optimization Workflow

```
1. MEASURE  → Establish verifiable baseline metrics (LCP, TTFB, query count, memory)
2. IDENTIFY → Profile flamegraphs and query logs to locate the true bottleneck
3. FIX      → Apply minimal surgical fix targeted specifically at the hot path
4. VERIFY   → Benchmark again under identical conditions to confirm improvement
5. GUARD    → Automate budget assertions in CI to prevent performance regression
```

## Core Web Vitals Baselines

| Metric | Target (Good) | Warning | Failure Threshold |
| :--- | :--- | :--- | :--- |
| **LCP** (Largest Contentful Paint) | $\le 2.5\text{ s}$ | $2.5 - 4.0\text{ s}$ | $> 4.0\text{ s}$ |
| **INP** (Interaction to Next Paint) | $\le 200\text{ ms}$ | $200 - 500\text{ ms}$ | $> 500\text{ ms}$ |
| **CLS** (Cumulative Layout Shift) | $\le 0.1$ | $0.1 - 0.25$ | $> 0.25$ |
| **TTFB** (Time to First Byte) | $\le 800\text{ ms}$ | $800 - 1800\text{ ms}$ | $> 1800\text{ ms}$ |

## Backend & Query Invariants

- **Zero N+1 Queries**: Never issue queries inside loops; use batch fetching, `JOIN` queries, or dataloaders.
- **Payload Compression**: Enforce gzip/brotli compression and pagination on list endpoints.
- **Bundle Size Budget**: Set max initial JS bundle size ($\le 150\text{ KB}$ gzipped).

## Verification Script

Run the automated performance gate:

```powershell
powershell -ExecutionPolicy Bypass -File .\skills\performance-optimization\scripts\verify_performance.ps1
```

POSIX Bash:
```bash
./skills/performance-optimization/scripts/verify_performance.sh
```

