# ADR 0011: Deck Preignored Cards

- Status: Accepted
- Date: 2026-09-29
- Deciders: Lexico maintainers
- Technical Area: Cards, deck configuration, progress tracking

## Context

Some decks contain duplicate cards for the same word across parts of speech. When the senses are closely related, one canonical card should remain available and only its redundant counterpart cards should be ignored. The initial choice must not overwrite progress already saved by a user.

- Current behavior: cards become ignored only through user interaction.
- Constraints: card IDs are explicit and local to a deck; bundled deck configuration lives under `metadata.deck`.
- Risks: seeding by numeric ranges or overwriting saved progress could ignore unrelated cards or erase user choices.

## Decision

- Decision summary: support an optional `preignored_words` array of explicit card IDs on `metadata.deck`. It lists only redundant cards, leaving one canonical card per close-meaning group available. During the first card load for a deck, seed ignored progress only for listed IDs that exist in that deck and have no saved progress record.
- Boundaries affected: `CardsProvider` coordinates deck configuration with a narrow progress seeder capability on `CardsProgressTracker`.
- New rules/conventions introduced: lists must contain explicit IDs from the same deck. The field defaults to an empty list when omitted. Initially, only the `unsure_words` deck uses it.

## Consequences

- Positive: curated duplicate cards are ignored while a canonical card remains available, and existing user progress is preserved.
- Negative: a deck's IDs must be kept in sync with its `preignored_words` list.
- Operational impact: update the explicit list when the curated set changes; existing saved progress is not migrated or overwritten.

## Alternatives Considered

1. Ignore cards by ID ranges or positions in the bundled file.
- Why rejected: IDs are stable identifiers and positions/ranges can include unrelated cards.

2. Store preignored state in each card or seed it unconditionally at app startup.
- Why rejected: card content and user progress stay separate, and unconditional seeding could override a user's later choice.

## Migration Plan

1. Decode `preignored_words` from deck configuration, defaulting to an empty list.
2. Seed only listed IDs present in the loaded deck that have no existing progress.
3. Maintain the curated IDs in `unsure_words_en.json`.

## Validation

- Tests: verify missing-list decoding, deck ID filtering, seeding only absent progress, and preservation of existing ignored or unignored progress.
- Metrics/observability: inspect ignored cards in the `unsure_words` deck after initial load.
- Rollback criteria: remove the deck list to disable future seeding; existing progress remains unchanged.

## References

- Related docs: [ADR 0009: Deck-Scoped Progress](0009-deck-scoped-progress.md)
