# ADR 0009: Deck-scoped progress

- Status: Accepted
- Date: 2026-09-27
- Deciders: Lexico maintainers
- Technical Area: cards, persistence, settings

## Context

Card IDs are unique only within a deck. Progress previously used the card ID alone, and the bundle loader selected one file prefix.

## Decision

Each deck JSON declares an ID, language, and localized names in metadata. The active deck ID is stored through `SettingsStoreProtocol`. Cards load from the selected deck file. Progress and history carry a deck ID; all progress reads and writes use the active deck.

Audio object keys use `<deckID>/words/<cardID>.m4a` and `<deckID>/sentences/<sentenceID>.m4a`. The card view passes its deck ID through the playback service to the media URL provider, so identical numeric IDs in separate decks resolve to separate audio.

## Consequences

Existing progress stays with the default deck. Deck files can reuse card IDs. Bundle metadata is the source for the settings list.
Legacy audio under root `words/` and `sentences/` is moved to `default/` with verified copies before deleting the old keys.

## Alternatives Considered

A combined numeric card ID would require rewriting existing progress and would make IDs depend on the set of installed decks.

## Migration Plan

The new SwiftData field is optional to permit lightweight migration. At startup, records with no deck ID receive `default` and are saved. New records always receive the active deck ID.

## Validation

Build the app, verify both bundled decks appear in settings, and check that matching card IDs retain separate progress after switching decks.
