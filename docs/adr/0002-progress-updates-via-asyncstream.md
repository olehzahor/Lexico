# ADR 0002: Progress Updates via AsyncStream

- Status: Accepted
- Date: 2026-02-15
- Deciders: Lexico maintainers
- Technical Area: Progress tracking, metrics synchronization

## Context

Progress change notifications were callback-based. This made ownership and lifecycle management fragile and reduced composability.

- Current behavior: callback notifications from progress tracker.
- Constraints: stay on MainActor-safe model, keep update flow explicit.
- Risks: callback leaks, accidental overwrite of single callback, implicit coupling.

## Decision

Use `AsyncStream<Void>` as the progress change channel exposed by tracker protocols.

- Decision summary: tracker emits events into stream, consumers observe stream in tasks and refresh state.
- Boundaries affected: `CardsProgressTrackerProtocol`, `SessionMetricsService` subscription logic.
- New rules/conventions introduced:
  - Emit progress-change events from mutation points.
  - Consumers subscribe once and refresh derived state on each event.
  - Keep refresh idempotent and safe for repeated triggers.

## Consequences

- Positive:
  - Better lifecycle control than ad-hoc callback assignment.
  - Supports multiple consumers naturally.
  - Clearer reactive contract between modules.
- Negative:
  - Requires task management and actor-safety discipline.
  - Slightly higher conceptual cost than a simple callback.
- Operational impact:
  - No product behavior change intended; internal reliability improvement.

## Alternatives Considered

1. Keep a callback property
- Why rejected: limited to single subscriber and easy to misuse.

2. Introduce Combine publishers
- Why rejected: extra framework complexity not required for current needs.

## Migration Plan

1. Replace callback with `progressChanges: AsyncStream<Void>` in protocol.
2. Yield events after progress mutations.
3. Migrate consumers to stream subscription tasks.
4. Remove legacy callback code.

## Validation

How we verify success.

- Tests: mutation should produce stream event; metrics refresh follows event.
- Metrics/observability: verify UI metrics update after review/ignore actions.
- Rollback criteria: if actor/lifecycle issues emerge, temporarily wrap stream behind adapter.

## References

- Related docs: `/Users/user/Documents/Lexico/AGENTS.md`, `/Users/user/Documents/Lexico/ARCHITECTURE.md`
- Related PRs/commits: callback-to-stream migration in progress tracker and metrics service.
- Supersedes / Superseded by:
