---
name: qa-audit
description: Generates exhaustive QA test matrices, simulates end-to-end user journeys, and validates edge-case coverage across happy paths and error boundaries. Use before shipping features, cutting releases, or certifying code changes.
---

# Quality Assurance (QA) Audit & Journey Testing

## Overview

Automated unit tests check that isolated functions return expected outputs, but QA audits verify that the entire product functions as a cohesive system under adverse real-world conditions. This skill guides the construction of systematic test plans and manual/automated scenario execution.

## QA Matrix Dimensions

| Dimension | Scope | Verification Focus |
| :--- | :--- | :--- |
| **Happy Path** | Core user journey | Golden path completes smoothly with optimal ergonomics |
| **Boundary Conditions** | Min/max values, empty states | Null, zero, empty arrays, maximum payload limits, long strings |
| **Error Recovery** | Network drops, 500 errors | Informative user alerts, retry idempotency, no stuck loading spinners |
| **State Transitions** | Concurrency & race conditions | Rapid double clicks, tab switching, stale token expiration |
| **Cross-Platform** | Device & browser variants | Mobile viewport, responsive breakpoints, light/dark themes |

## QA Execution Loop

1. **MAP**: Identify every entry point and decision branch in the feature.
2. **MATRIX**: Generate a table of specific test cases covering each dimension.
3. **EXECUTE**: Run automated tests or execute scenarios via browser tools.
4. **DOCUMENT**: Record test artifacts, screenshots, and response times.
5. **CERTIFY**: Issue formal QA sign-off only when all critical and blocker items pass.
