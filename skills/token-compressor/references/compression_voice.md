# High-Density vs. Verbose Response Reference

Adapted from Caveman token efficiency standards.

---

## Example 1: Bug Fix

### ❌ Verbose & Low Signal (185 tokens):
> *"Hello! Thank you for sharing the error log with me. I took a very close look at your code and after analyzing the stack trace, I think I have identified the root cause of the issue you are facing. The error occurs because on line 42, the token expiry check is using the wrong operator. Let me now go ahead and provide you with the fix for this function. Below is the updated code..."*

### ✅ High Density & High Signal (45 tokens):
> **Root Cause**: Token expiry comparison on line 42 used `<=` instead of `<`.  
> **Fix**:
> ```typescript
> if (token.expiresAt < Date.now()) return null;
> ```
> **Verification**: `npm test auth.test.ts` passed (12/12).

---

## Example 2: Architecture Advice

Deliver the trade-off matrix directly rather than writing multiple paragraphs of introductory conversational transitions.
