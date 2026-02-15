# ADR 0003: CardsProvider DataSource Abstraction

- Status: Accepted
- Date: 2026-02-15
- Deciders: Lexico maintainers
- Technical Area: CardsProvider, previews/tests

## Context

`CardsProvider` directly loaded JSON from `Bundle.main`, which made preview/test scenarios (especially empty decks) cumbersome and required indirect workarounds.

- Current behavior: provider is responsible for both domain filtering and bundle loading.
- Constraints: preserve current API behavior for production.
- Risks: hard-to-test provider, noisy previews, mixed responsibilities.

## Decision

Introduce `CardsDataSource` abstraction and inject it into `CardsProvider`.

- Decision summary: `CardsProvider` depends on `CardsDataSource` for raw cards; production uses bundle source, tests/previews can use custom/empty sources.
- Boundaries affected: `CardsProvider` construction and preview/test setup.
- New rules/conventions introduced:
  - Raw card loading belongs to data source implementations.
  - `CardsProvider` focuses on caching and domain-specific card selection.
  - Provide a default production data source (`BundleCardsDataSource`).

## Consequences

- Positive:
  - Easy empty/custom card sets in previews/tests.
  - Cleaner single responsibility in provider.
  - Better extensibility for future remote/local hybrid sources.
- Negative:
  - One extra abstraction layer.
  - More constructor wiring where custom sources are used.
- Operational impact:
  - Production path remains unchanged via default bundle source.

## Alternatives Considered

1. Keep direct `Bundle` loading and mock `CardsProvider`
- Why rejected: still couples implementation and makes composition less explicit.

2. Move loading logic into static helpers
- Why rejected: does not provide clean injection boundary.

## Migration Plan

1. Add `CardsDataSource` protocol.
2. Add `BundleCardsDataSource` and `EmptyCardsDataSource`.
3. Inject data source into `CardsProvider` with default bundle source.
4. Update previews/tests to use empty/custom data source when needed.

## Validation

How we verify success.

- Tests: provider works with stub/empty data source.
- Metrics/observability: not applicable.
- Rollback criteria: if init surface becomes problematic, provide factory helpers while keeping abstraction.

## References

- Related docs: `/Users/user/Documents/Lexico/AGENTS.md`, `/Users/user/Documents/Lexico/ARCHITECTURE.md`
- Related PRs/commits: `CardsDataSource` introduction and empty session preview simplification.
- Supersedes / Superseded by:
