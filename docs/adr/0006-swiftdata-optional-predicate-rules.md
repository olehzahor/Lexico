# ADR 0006: SwiftData Optional Predicate Rules

- Status: Accepted
- Date: 2026-02-19
- Deciders: Lexico team
- Technical Area: Persistence / SwiftData query layer

## Context

SwiftData `#Predicate` has strict translation rules for optionals. Some expressions compile but fail at runtime (for example with `unsupportedPredicate`), while others translate differently depending on optional shape.

- Current behavior:
  - Optional handling patterns are inconsistent across services.
- Constraints:
  - Queries must stay database-backed (no client-side filtering fallback for core flows).
  - Predicates must be translatable to SwiftData SQL.
- Risks:
  - Runtime crashes or empty/incorrect fetches from unsupported optional expressions.

## Decision

Standardize optional handling patterns in SwiftData predicates.

- Decision summary:
  - Do not use forced unwrap (`!`) in predicates.
  - Prefer nil-coalescing (`??`) for optional scalar comparisons.
  - Allow optional binding only as a single expression form (`if/else` expression).
  - Prefer direct equality for optional properties when semantics allow.
  - Require integration tests for complex optional chains and optional to-many relationships.
- Boundaries affected:
  - `Data` predicate factories and persistence readers/trackers.
- New rules/conventions introduced:
  - Optional-safe predicate patterns are mandatory for new and modified queries.

## Consequences

- Positive:
  - Fewer runtime predicate translation failures.
  - More predictable store-backed query behavior.
- Negative:
  - Slightly more verbose predicate code in some places.
- Operational impact:
  - Query regressions should be caught earlier by tests.

## Alternatives Considered

1. Keep ad-hoc optional handling
- Why rejected:
  - Produces unstable behavior and runtime-only failures.

2. Shift filtering to client-side Swift arrays
- Why rejected:
  - Violates persistence boundary and does not scale for core flows.

## Migration Plan

1. Update architecture documentation with optional predicate rules.
2. Replace forced unwrap patterns in existing predicates when touched.
3. Add/expand integration tests for time-based and optional-dependent queries.

## Validation

- Tests:
  - Integration tests must confirm expected rows for optional-dependent fetches.
- Metrics/observability:
  - No `unsupportedPredicate` errors during test runs and debug sessions.
- Rollback criteria:
  - If a rule blocks required query expressiveness, define an explicit exception ADR.

## References

- Related docs:
  - `/Users/user/Documents/Lexico/ARCHITECTURE.md`
- Related PRs/commits:
  - Documentation update introducing optional predicate rules.
- Supersedes / Superseded by:
  - None
- External:
  - https://fatbobman.com/en/posts/how-to-handle-optional-values-in-swiftdata-predicates/
