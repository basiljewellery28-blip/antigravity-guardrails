---
name: browser-testing-with-devtools
description: Executes and validates web application behavior in live or headless browsers using Chrome DevTools MCP, Playwright, or Puppeteer. Use whenever building or modifying frontend UI components, debugging DOM layouts, diagnosing console errors or network failures, measuring runtime Web Vitals, or verifying visual regressions before merging.
---

# Browser Testing with DevTools

## Overview

Static analysis and unit tests cannot see CSS layout bugs, hydration mismatches, network race conditions, or unhandled runtime script exceptions. This skill provides a disciplined browser verification protocol to inspect live DOM trees, trap console errors, monitor network payloads, and ensure client-side robustness.

## Verification Protocol

```
1. SERVE   → Launch local dev server or static preview
2. ATTACH  → Connect via Chrome DevTools MCP or Headless Runner
3. INSPECT → Verify DOM tree, responsive layout, and visual fidelity
4. TRAP    → Gate on zero console errors, zero unhandled rejections
5. PROBE   → Verify API network requests, status codes, and latency
6. CLEANUP → Terminate background headless sessions
```

## Mandatory Gates

- **Zero Console Errors**: Any `console.error` or unhandled promise rejection fails verification.
- **Visual Stability**: No unexpected Cumulative Layout Shift (`CLS > 0.1`).
- **Network Integrity**: All assets (`200 OK`) and API responses (`2xx`) must succeed without CORS or 404 errors.
- **Accessibility Baselines**: Standard ARIA landmark verification and accessible keyboard navigation.

## Automation Helper

Run the verification script before declaring UI tasks complete:

```powershell
powershell -ExecutionPolicy Bypass -File .\skills\browser-testing-with-devtools\scripts\verify_browser_suite.ps1 -Url "http://localhost:3000"
```

POSIX Bash:
```bash
./skills/browser-testing-with-devtools/scripts/verify_browser_suite.sh --url "http://localhost:3000"
```

