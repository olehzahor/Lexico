# ADR 0005: Hybrid Protocol Naming (Boundary vs Capability)

- Status: Accepted
- Date: 2026-02-17
- Deciders: Lexico maintainers
- Technical Area: Cross-feature architecture conventions

## Context

Using `...Protocol` for every protocol improved explicitness but added noise for narrow capability slices used only for protocol composition.

- Current behavior: broad use of `...Protocol` including small read-only role protocols.
- Constraints: keep protocol-first boundaries and avoid behavior changes.
- Risks: naming bloat and reduced readability in composed type constraints.

## Decision

Adopt a hybrid naming convention:

- Use `...Protocol` for primary service contracts crossing module boundaries.
- Use capability names without `Protocol` for narrow role/slice protocols.

- Decision summary: keep explicit suffix for main contracts, keep capability names for composable internal roles.
- Boundaries affected: service protocol naming across scenes/services.
- New rules/conventions introduced:
  - `...Protocol` remains the default for primary boundary contracts (`CardsProviderProtocol`).
  - Short unambiguous domain contracts may omit suffix (`AudioPlayer`).
  - `CardsProviderProgressReader`, `SessionMetricsProgressReader` use capability naming.
  - Maintain protocol-first dependency injection and separation of concerns.

## Consequences

- Positive:
  - Better readability in composed constraints.
  - Clear separation between primary API contracts and role capabilities.
- Negative:
  - Mixed naming style requires a clear rule in docs.
- Operational impact:
  - No runtime behavior change.

## Alternatives Considered

1. Keep `...Protocol` everywhere
- Why rejected: over-verbose for narrow capability slices.

2. Remove `...Protocol` everywhere
- Why rejected: less explicit for key cross-module contracts.

## Migration Plan

1. Rename narrow `...ReaderProtocol` roles to concise `...Reader`.
2. Update all references and protocol compositions.
3. Document the convention in architecture docs.

## Validation

- Tests: build/tests should compile with renamed symbols.
- Metrics/observability: not applicable.
- Rollback criteria: revert renaming if migration causes unacceptable churn.

## References

- Related docs: `ARCHITECTURE.md`, `AGENTS.md`, `docs/adr/0004-protocol-naming-protocol-suffix.md`
- Related PRs/commits: protocol naming refinement migration.
- Supersedes / Superseded by: Supersedes `0004-protocol-naming-protocol-suffix.md`
