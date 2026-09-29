# ADR 0010: Deck Level Completion Metadata

- Status: Accepted
- Date: 2026-09-29
- Deciders: Lexico maintainers
- Technical Area: Cards, session metrics

## Context

Session metrics currently show completion for the current CEFR level. Some decks are organized into levels and others are not, so the session header needs to choose a meaningful completion scope from deck configuration.

- Current behavior: the session header always shows current-level completion.
- Constraints: deck configuration is bundled with each card deck; missing `leveled` values must remain safe to decode.
- Risks: counting ignored cards as incomplete would distort both level and whole-deck completion.

## Decision

- Decision summary: store `leveled` on `metadata.deck`, decode it as `false` when absent, and set it to `true` only for the `default` deck. Session metrics obtain the active `Deck` through the cards provider. The session header shows current-level completion for leveled decks and whole-deck completion for other decks.
- Boundaries affected: the cards data source and cards provider expose active deck metadata to session metrics.
- New rules/conventions introduced: completion percentages exclude ignored cards from both numerator eligibility and denominator.

## Consequences

- Positive: session progress follows the structure declared by each deck and does not rely on hard-coded deck IDs.
- Negative: card data source implementations must provide deck metadata.
- Operational impact: each bundled deck should declare `leveled`; omitted values decode as `false` for compatibility.

## Alternatives Considered

1. Infer level support from deck ID or available CEFR levels.
- Why rejected: deck identity and presence of level labels do not express how the session should summarize progress.

2. Always show whole-deck progress.
- Why rejected: the default deck is explicitly structured by CEFR level and should retain level completion.

## Migration Plan

1. Add the `leveled` property to `Deck` and bundled deck metadata.
2. Expose active deck metadata through the cards provider.
3. Select level or whole-deck completion in session metrics presentation.

## Validation

- Tests: verify deck decoding defaults and session completion selection for leveled and non-leveled decks.
- Metrics/observability: inspect the session header with both deck types and ignored cards.
- Rollback criteria: if bundled deck metadata cannot be read, default to whole-deck progress.

## References

- Related docs: [ADR 0009: Deck-Scoped Progress](0009-deck-scoped-progress.md)
