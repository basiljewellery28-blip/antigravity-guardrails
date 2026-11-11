# Core Refactoring & Simplification Patterns

Adapted from Addy Osmani's engineering skills.

---

## 1. Replace Nested Conditionals with Guard Clauses

```typescript
// ❌ Hard to parse: Nested branching
function getDiscount(user: User, cart: Cart): number {
  let discount = 0;
  if (user) {
    if (user.isMember) {
      if (cart.total > 100) {
        discount = 0.20;
      } else {
        discount = 0.10;
      }
    }
  }
  return discount;
}

// ✅ Easy to parse: Early returns
function getDiscount(user: User, cart: Cart): number {
  if (!user || !user.isMember) return 0;
  return cart.total > 100 ? 0.20 : 0.10;
}
```

---

## 2. Decompose Heavy Chained Pipelines

When `.map()`, `.filter()`, and `.reduce()` chains become longer than 3 lines, name the intermediate steps or use explicit loops with clear accumulators.

