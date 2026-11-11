# When and How to Mock at System Boundaries

Mock at **system boundaries** only:
- External Third-Party APIs (Stripe, Twilio, SendGrid)
- External cloud storage (S3, GCS, Blob Storage)
- Current time & random number generators
- Hardware devices / operating system signals

**Never mock:**
- Your own internal classes or modules
- Internal collaborators within the same domain boundary
- In-memory data structures
- Anything you control (prefer real test databases or in-memory fixtures)

---

## 1. Design for Mockability via Dependency Injection

Pass external dependencies in rather than constructing them internally:

### TypeScript Example:
```typescript
// ❌ Hard to mock: Hidden external dependency
function processPayment(order: Order): Promise<PaymentResult> {
  const client = new StripeClient(process.env.STRIPE_KEY!);
  return client.charge(order.total);
}

// ✅ Easy to mock: Explicit dependency injection at public seam
interface PaymentClient {
  charge(amountCents: number): Promise<PaymentResult>;
}

function processPayment(order: Order, paymentClient: PaymentClient): Promise<PaymentResult> {
  return paymentClient.charge(order.total);
}
```

### Python Example:
```python
# ❌ Hard to mock: Global instantiation
import requests

def fetch_weather(city: str) -> dict:
    return requests.get(f"https://api.weather.com/{city}").json()

# ✅ Easy to mock: Protocol / Interface injection
from typing import Protocol

class WeatherFetcher(Protocol):
    def get_weather(self, city: str) -> dict: ...

def fetch_weather(city: str, fetcher: WeatherFetcher) -> dict:
    return fetcher.get_weather(city)
```

---

## 2. Prefer SDK-Style Interfaces Over Generic Fetchers

Create dedicated methods for specific operations rather than a single catch-all function:

```typescript
// ✅ GOOD: Each method is independently typed and mockable
interface UserApi {
  getUser(id: string): Promise<User>;
  listOrders(userId: string): Promise<Order[]>;
  createOrder(data: OrderRequest): Promise<Order>;
}

// ❌ BAD: Mocking requires conditional URL inspection inside test setup
interface UserApi {
  request(endpoint: string, options?: RequestInit): Promise<unknown>;
}
```

Why the SDK approach wins:
1. Each mock returns an explicit, type-safe shape.
2. No nested `if (url === '/api/user')` logic inside mock handlers.
3. Tests make it immediately obvious which business endpoints are being exercised.

