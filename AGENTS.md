# AGENTS.md

This file defines repository-wide rules for AI coding agents and human contributors.

## 1. Core Principles

- Prefer simple, explicit, testable code over clever code.
- Keep responsibilities separated: UI, application logic, domain logic, persistence.
- Make the smallest safe change that solves the task.
- Do not perform hidden behavior changes during refactors.

## 2. Dependency Direction

Use this direction unless explicitly documented otherwise:

`View -> ViewModel -> Service -> Storage`

Rules:
- Views do not access DB context, network clients, or global singletons directly.
- ViewModels coordinate use-cases; they should not contain storage-specific queries.
- Services own business logic and orchestration.
- Persistence details stay in storage/tracker/provider layers.

## 3. Protocol-First Boundaries

- Depend on protocols at module boundaries.
- Use `...Protocol` for primary service contracts at boundaries by default (for example, `CardsProviderProtocol`).
- Short domain protocol names without suffix are allowed when the name is unambiguous (for example, `AudioPlayer`).
- Use capability-style names without `Protocol` for narrow role protocols used as composed slices (for example, `CardsProviderProgressReader`, `SessionMetricsProgressReader`).
- Inject dependencies through initializers.
- Avoid forcing concrete implementations into UI/ViewModel layers.

## 4. State and Reactivity

- UI state must be observable (`@Observable`, `@State`, bindings where needed).
- Favor a single source of truth per feature.
- Event streams/callbacks should be explicit and typed.
- Avoid implicit side effects across modules.

## 5. File and Directory Conventions

Preferred structure for feature code:

- `Scenes/<Feature>/<Feature>View.swift`
- `Scenes/<Feature>/<Feature>ViewModel.swift`
- `Scenes/<Feature>/Views/...` (feature-specific UI components)
- `Scenes/<Feature>/Data/...` (UI-only data models, filters, empty states)

Preferred structure for services:

- `Services/<Service>/<Service>.swift`
- `Services/<Service>/Protocols/...`
- `Services/<Service>/Data/...`

Shared models:

- `Data/...`

Naming:

- Views: `XxxView`
- ViewModels: `XxxViewModel`
- Services: noun + `Service` or domain provider/tracker name
- Protocols: capability-based, concise, no `I` prefix
- File name matches main type name

## 6. Refactor Rules

- Preserve behavior unless task explicitly asks for changes.
- Do not mix large renames with logic changes unless required.
- Remove dead code after replacement is verified.
- Keep migration steps incremental and compilable.

## 7. Testing and Verification

For every non-trivial change:

- Add/update tests for new behavior.
- Validate edge cases and empty states.
- Verify preview/demo setups still work.
- If build/test cannot be run locally, state it explicitly in final report.

## 8. Review Checklist

Before finishing:

- Are boundaries respected?
- Are new dependencies protocol-based?
- Is state flow clear and reactive?
- Is file placement consistent with conventions?
- Are names clear and aligned with existing domain language?

## 9. ADR Requirement

Create an ADR entry for decisions that affect:

- module boundaries,
- naming conventions across multiple files,
- persistence/query strategy,
- cross-feature architecture patterns.

Use template: `docs/adr/0000-template.md`.

## 10. Cards and Settings

- Card progress is keyed by card ID. Treat IDs as stable identifiers, not positions in a bundled JSON file. Never seed ignored or reviewed progress from a numeric ID range; use explicit IDs from the intended set.
- Keep the bundled card source and progress state separate. Replacing a card file must not silently change existing progress or mark new cards ignored.
- Card and sentence IDs are local to a deck. A card ID collision across separate deck directories is valid; before making multiple decks available in one app database, include a deck identifier in persisted progress keys.
- Each deck JSON owns its `categories` map. Every card's `category` key must have nonempty `en` and `ru` names in that map. Choose categories that fit the deck; do not add deck category names to a global string catalog. See `docs/adr/0008-deck-owned-category-localization.md`.
- Keep `Lexico/Resources/Cards/example_cards_en.json` small and representative for deck generation prompts; see `docs/prompts/generate-card-deck.md`.
- Store user preferences through `SettingsStoreProtocol`. Views bind to observable ViewModel state; other features read the same store so changes appear when those features become active.
- The daily goal counts new cards learned today. Keep its default and allowed range consistent between the settings screen and session metrics.
- Schedule reminder notifications through `ReminderSchedulingProtocol`. Request notification permission only when the user enables a reminder, and remove obsolete pending requests when the selected days or time change.
- Represent reminder days using calendar weekday values (`1` = Sunday through `7` = Saturday). An empty selection means reminders are off.
- Test preference persistence, denied notification permission, weekday selection, and rescheduling after time changes. Verify the app builds with all Swift files in the synchronized Xcode target, including previews.

## 11. Audio Utilities and Cloudflare

- Keep local audio generation in `Utilities/tts/` and R2 upload code in `Utilities/cloudflare-upload/`.
- Save generated audio and manifests under `Utilities/tts/output/`; keep that directory and downloaded model files out of Git.
- Keep real R2 credentials only in ignored `Utilities/cloudflare.local.env`. Maintain `Utilities/cloudflare.local.env.example` without secrets, and never log or commit credential values.
- Scope R2 upload credentials to the intended bucket. Make upload tooling reviewable with a dry run and verification of uploaded objects.
