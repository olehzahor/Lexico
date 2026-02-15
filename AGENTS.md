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
- Keep protocol names capability-oriented (`CardsProviding`, `CardsProgressTracking`).
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
