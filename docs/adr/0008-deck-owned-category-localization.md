# ADR 0008: Deck-Owned Category Localization

- Status: Accepted
- Date: 2026-09-27
- Deciders: Lexico maintainers
- Technical Area: Card data and localization

## Context

What problem are we solving?

- Current behavior: Card JSON stores category keys, while visible names live in a global `Category.xcstrings` file.
- Constraints: New decks should define categories that fit their own words without an app update for every new name.
- Risks: A category key absent from the global table appears untranslated.

## Decision

What we decided and why.

- Decision summary: Each deck JSON has a top-level `categories` map from category key to localized `en` and `ru` names. Each card keeps one category key. The bundle data source attaches the matching names to decoded cards.
- Boundaries affected: Localization data stays in the deck; the data source performs the lookup and views use the card's display name.
- New rules/conventions introduced: Category keys use `card.category.<slug>`. Every used key must exist in the deck's map. Names are localized per deck, with English and then the key as display fallbacks.

## Consequences

Expected outcomes and tradeoffs.

- Positive: Decks can use their own meaningful categories and translations without modifying app localization files.
- Negative: Each deck stores its own category names, even when another deck uses the same labels.
- Operational impact: Existing deck JSON files need a `categories` map. `Category.xcstrings` is retired.

## Alternatives Considered

1. Keep the global string catalog
- Why rejected: New deck categories would require an app localization change.

2. Repeat translated names on every card
- Why rejected: It duplicates the same names across many card records.

## Migration Plan

How to adopt safely.

1. Add category maps to existing decks, preserving current English and Russian names.
2. Load the map with cards and use it for display.
3. Remove the global category catalog after validating existing deck keys.

## Validation

How we verify success.

- Tests: Check every deck's used keys have nonempty English and Russian names; verify localization fallback and build the iOS target.
- Metrics/observability: None.
- Rollback criteria: Category names regress to raw keys or card loading fails.

## References

- Related docs: `AGENTS.md`, `docs/prompts/generate-card-deck.md`
- Related PRs/commits: pending
- Supersedes / Superseded by: N/A
