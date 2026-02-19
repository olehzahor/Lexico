# ARCHITECTURE.md

## Purpose

This document defines architectural boundaries and code organization rules for the project.

## Layers

1. Presentation (`Scenes`)
- Views render state and forward user actions.
- ViewModels own presentation state and call services.
- No direct DB/network logic in Views.

2. Application/Domain Services (`Services`)
- Encapsulate business logic and use-case orchestration.
- Expose narrow capabilities through protocols.
- Hide persistence/data-source internals.

3. Persistence and External Data
- Trackers/providers/data-sources interact with DB/files/network.
- Query optimization belongs here, not in UI layers.

4. Shared Models (`Data`)
- Domain entities and persistence models.

## Dependency Rules

Allowed:
- `Scenes -> Services`
- `Services -> Data`
- `Services -> storage/data-source implementations`

Not allowed:
- `Scenes -> DB context`
- `Views -> concrete storage implementations`
- Circular dependencies across features/services

## State Flow

- User action originates in View.
- View forwards action to ViewModel.
- ViewModel calls Service protocol methods.
- Service mutates persistence and emits updates.
- ViewModel/service refreshes observable state.
- View re-renders from observable state.

## Protocol Segregation

Split protocols by usage context when useful:
- Tracking/mutation capabilities
- Read capabilities for specific clients

Then keep client dependencies minimal to what they use.

## File Layout Standard

- `Scenes/<Feature>/<Feature>View.swift`
- `Scenes/<Feature>/<Feature>ViewModel.swift`
- `Scenes/<Feature>/Views/<Component>/<Component>.swift`
- `Scenes/<Feature>/Views/<Component>/<Component>+Data.swift` (UI model namespace extensions)
- `Scenes/<Feature>/Data/...`
- `Services/<Service>/<Service>.swift`
- `Services/<Service>/Protocols/...`
- `Services/<Service>/Data/...`
- `Data/...`
- `docs/adr/...`

## View Modeling Rules

- A view must not directly depend on domain models from other modules/domains.
- Each non-trivial view should define its own UI model in the view namespace:
  - `NameView.Data`
  - `NameView.Style` (optional, when style configuration is non-trivial)
- UI models for a view are stored in a separate file: `NameView+Data.swift` (and `NameView+Style.swift` if needed).
- UI model may provide mapping constructors in extensions from global/domain models.
- View-scoped support types (for example `UserAction`, `State`, `Event`, constants/config groups) should be stored in separate extension files like `NameView+UserAction.swift`, `NameView+State.swift`, etc., instead of being declared inline in `NameView.swift`.

Exception:

- For primitive highly abstract views (typically one or two simple fields, e.g. a generic header), dedicated `Data`/`Style` is optional.
- For primitive views with minimal logic, a tiny inline helper type is acceptable if extraction would add noise.

## Type Member Order

- Keep initializers as the last methods in a type declaration (C-style convention used in this project).

## SwiftData Optional Predicates

When building `#Predicate` for SwiftData, treat optional handling as part of query design.

- Never use forced unwrap (`!`) inside predicates. It can compile but fail at runtime with `unsupportedPredicate`.
- Prefer nil-coalescing for optional scalars in boolean conditions:
  - `(progress.lastReviewed ?? .distantPast) >= dayStart`
  - `(progress.dueAt ?? .distantFuture) <= now`
- Optional binding is allowed, but keep predicate body as a single expression (`if/else` expression only; no extra trailing `return`).
- Direct equality on optionals is supported and preferred when it matches semantics:
  - `$0.optionalName == "value"`
  - `$0.optionalRelation?.name == "value"`
- Keep optional chains shallow and test SQL-backed behavior for complex chains/relationships.
- For optional to-many relationships, validate with integration tests before relying on predicate translation.

Query safety rule:
- If a predicate compiles but behavior is critical, add a test that verifies fetched rows from the store (not only in-memory evaluation).

## Naming Rules

- Prefer domain names over generic names.
- Avoid ambiguous names like `Manager` unless domain-specific.
- For list filters/states, use names reflecting semantics (`Unseen`, `Ignored`, `Review`).
- Protocol naming:
  - Use `...Protocol` for primary service contracts consumed across module boundaries by default (for example, `CardsProviderProtocol`).
  - Short domain names without suffix are allowed when the contract is unambiguous and concise (for example, `AudioPlayer`).
  - Use capability-style names without `Protocol` for narrow role interfaces and composed read/write slices (for example, `CardsProviderProgressReader`, `SessionMetricsProgressReader`).
  - Do not use `I` prefix.

## Change Management

When changing architecture:

1. Update/introduce protocol boundary.
2. Migrate one client at a time.
3. Keep app buildable after each step.
4. Record final decision in ADR.

## ADR Index

ADR files live in `docs/adr` and are named:

`NNNN-short-title.md`

Start from `0001-...`.
