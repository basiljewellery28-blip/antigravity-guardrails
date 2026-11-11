# Google Python Engineering Style Reference

This reference synthesizes core guidelines from the Google Python Style Guide for agentic coding.

---

## 1. Type Annotations & Signatures

- **Mandatory Annotations**: All public APIs and module interfaces must declare explicit parameter types and return types.
- **Type Aliases**: Use descriptive type aliases for complex structures:
  ```python
  from typing import TypeAlias, Mapping, Sequence

  UserId: TypeAlias = int
  UserMetadata: TypeAlias = Mapping[str, str | int]
  ```
- **Avoid Ambiguous Containers**:
  Prefer `Sequence[T]` for read-only iterables instead of mutable `list[T]`. Prefer `Mapping[K, V]` over `dict[K, V]` for function parameters.

---

## 2. Exception Handling

- **Catch Specific Exceptions**:
  Never catch `Exception` or `BaseException` unless writing a top-level crash handler.
- **Raise with Context**:
  Use `raise NewException(...) from original_err` to preserve traceback chains.
- **Clean Cleanup**:
  Use context managers (`with` statements) for all file handles, locks, database connections, and network sessions.

---

## 3. Data Structures & Classes

- **Data Holders**: Use `@dataclass(frozen=True)` or `NamedTuple` when defining classes that only store state without heavy business logic.
- **Composition over Inheritance**: Prefer composition and Python protocols (`typing.Protocol`) over deep multiple inheritance hierarchies.
- **Properties over Getters/Setters**: Expose public attributes directly; convert to `@property` if computed logic becomes necessary later.

