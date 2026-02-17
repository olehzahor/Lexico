# ADR 0004: Protocol Naming with Protocol Suffix

- Status: Accepted
- Date: 2026-02-17
- Deciders: Lexico maintainers
- Technical Area: Cross-feature architecture conventions

## Context

Protocol names were previously mixed between capability-style gerunds and other forms (`CardsProviding`, `CardsProgressTracking`, etc.). This created inconsistent naming across service boundaries and reduced predictability when introducing new interfaces.

- Current behavior: mixed protocol naming styles.
- Constraints: preserve architecture and runtime behavior; keep migration incremental.
- Risks: naming drift and harder discoverability.

## Decision

Adopt `...Protocol` suffix for boundary protocols used across scenes/services.

- Decision summary: rename protocol types to explicit `...Protocol` names and update references.
- Boundaries affected: service and scene protocol dependencies.
- New rules/conventions introduced:
  - Use `...Protocol` naming for boundary protocols (for example, `AudioPlayerProtocol`, `CardsProviderProtocol`).
  - Avoid gerund-based protocol names (`...Providing`, `...Tracking`, `...Reading`) for new APIs.
  - Keep dependency direction unchanged; this is naming-only.

## Consequences

- Positive:
  - Consistent protocol naming and easier symbol search.
  - Clear distinction between protocols and concrete implementations.
- Negative:
  - More verbose type names.
  - One-time migration overhead.
- Operational impact:
  - No runtime behavior change intended.

## Alternatives Considered

1. Keep capability-gerund naming
- Why rejected: inconsistency with preferred explicit interface naming.

2. Use `...Interface` suffix
- Why rejected: less idiomatic in current Swift codebase; `...Protocol` chosen as explicit team standard.

## Migration Plan

1. Rename protocol declarations and files.
2. Update all type references and conformances.
3. Keep implementation logic unchanged.

## Validation

How we verify success.

- Tests: existing tests/build should pass with renamed symbols.
- Metrics/observability: not applicable.
- Rollback criteria: revert naming migration if it causes unacceptable churn.

## References

- Related docs: `docs/adr/0000-template.md`, `docs/adr/0001-protocol-first-service-boundaries.md`
- Related PRs/commits: protocol naming migration introducing `...Protocol` suffix.
- Supersedes / Superseded by: Superseded by `0005-protocol-naming-hybrid-boundary-vs-capability.md`
