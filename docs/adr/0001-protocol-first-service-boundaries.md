# ADR 0001: Protocol-First Service Boundaries

- Status: Accepted
- Date: 2026-02-15
- Deciders: Lexico maintainers
- Technical Area: Services, Scenes

## Context

The codebase had growing coupling between presentation code and concrete service implementations. ViewModels and views often depended on concrete classes directly, which made testing and migration harder.

- Current behavior: direct dependencies on concrete service/provider types.
- Constraints: keep SwiftUI architecture simple, avoid over-engineering, preserve behavior.
- Risks: rigid dependencies, harder mocking, expensive refactors.

## Decision

Adopt protocol-first boundaries between clients and services.

- Decision summary: clients depend on capabilities (protocols), services conform to protocols.
- Boundaries affected: Scenes -> Services, Services interop.
- New rules/conventions introduced:
  - Use capability-oriented protocol names (e.g. `CardsProviderProtocol`, `CardsProgressTrackerProtocol`).
  - Inject dependencies through initializers.
  - Avoid concrete storage/provider types in View/ViewModel fields unless strictly required.

## Consequences

- Positive:
  - Easier test doubles and preview setup.
  - Lower coupling between UI/application layers and implementations.
  - Safer incremental refactors.
- Negative:
  - More surface area (extra protocol files and wiring).
  - Slightly more type verbosity (`any ProtocolName`).
- Operational impact:
  - No runtime behavior change expected.

## Alternatives Considered

1. Keep concrete dependencies and rely on subclassing/mocks only in tests
- Why rejected: weaker boundaries and harder long-term evolution.

2. Introduce a full DI container
- Why rejected: unnecessary complexity for current project size.

## Migration Plan

1. Introduce protocol per client capability.
2. Conform existing implementations.
3. Migrate clients one by one to protocol dependencies.
4. Remove obsolete aliases/compositions when no longer needed.

## Validation

How we verify success.

- Tests: unit tests can inject stubs/fakes without concrete service classes.
- Metrics/observability: not applicable.
- Rollback criteria: if migration blocks development, temporarily allow concrete type on affected boundary.

## References

- Related docs: `/Users/user/Documents/Lexico/AGENTS.md`, `/Users/user/Documents/Lexico/ARCHITECTURE.md`
- Related PRs/commits: protocol migration around `CardsProvider`, `SessionMetricsService`, `ViewModel` dependencies.
- Supersedes / Superseded by:
