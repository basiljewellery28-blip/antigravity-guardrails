# Good vs. Bad Tests: Principles & Anti-Patterns

Adapted from Matt Pocock's TDD philosophy and Google Software Engineering standards.

---

## 1. Good Tests: Observable Behavior at Public Seams

A good test reads like an executable specification. It verifies observable behavior through public interfaces without caring about internal implementation details.

```typescript
// ✅ GOOD: Tests observable behavior through public seam
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(testProduct);
  
  const result = await checkout(cart, mockPaymentGateway);
  
  expect(result.status).toBe("confirmed");
  expect(result.orderId).toBeDefined();
});
```

### Characteristics of Good Tests:
1. **Behavioral**: Tests what the user or caller cares about, not *how* it was achieved.
2. **Refactor-Resistant**: If you completely refactor the internal data structures, the test remains green.
3. **Deterministic**: Never flaky; independent of network availability or system clock drift.
4. **Single Logical Assertion**: Verifies one cohesive outcome per test case.

---

## 2. Bad Tests: Coupled to Implementation Details

```typescript
// ❌ BAD: Tightly coupled to internal method calls and collaborator mocks
test("checkout calls paymentService.process with exact parameters", async () => {
  const mockPayment = jest.spyOn(paymentService, "process");
  await checkout(cart, paymentService);
  
  expect(mockPayment).toHaveBeenCalledTimes(1);
  expect(mockPayment).toHaveBeenCalledWith(cart.total);
});
```

### Red Flags:
- Spying on private methods or asserting call counts instead of returned state.
- Bypassing the public API to check database rows directly when a public query method exists.
- The test breaks immediately during a harmless refactoring.

---

## 3. Anti-Pattern: Tautological Tests

A tautological test recalculates the expected value using the exact same formula or logic as the code under test, meaning it passes by construction and can never detect a regression.

```typescript
// ❌ BAD: Tautological assertion (re-computes logic)
test("calculateDiscount applies 15%", () => {
  const price = 200;
  const expected = price * 0.15;
  expect(calculateDiscount(price)).toBe(expected);
});

// ✅ GOOD: Expected value is an independent, known literal truth
test("calculateDiscount applies 15%", () => {
  expect(calculateDiscount(200)).toBe(30);
});
```
