# ADR 0007: Settings Storage and Reminder Scheduling

- Status: Accepted
- Date: 2026-09-27
- Deciders: Lexico maintainers
- Technical Area: Settings architecture

## Context

The settings tab needs a persistent daily goal and weekly reminder schedule. The session screen must read the same daily goal, and notification requests must reflect the selected days and time.

## Decision

- Persist typed values behind `SettingsStoreProtocol` using `UserDefaults`.
- Keep settings UI state in `SettingsViewModel`; the session reads the goal through the same store when it appears.
- Schedule one repeating local notification per selected weekday behind `ReminderSchedulingProtocol`. An empty day selection removes all reminder requests.
- Ask for notification authorization when the first reminder is selected.

## Consequences

Settings persist across launches. Notification delivery still depends on iOS authorization and scheduling. The existing screen model types remain available for future settings but the current screen uses direct controls.

## Alternatives Considered

1. Put `@AppStorage` directly in each view: rejected because session and settings would have separate UI ownership of the same preference.
2. Schedule one notification per date: rejected because a repeating weekday trigger directly models the requested schedule.

## Migration Plan

How to adopt safely.

1. Add typed preference storage and the settings screen.
2. Read the daily goal from the store in the session.
3. Add local reminder scheduling and reschedule when preferences change.

## Validation

How we verify success.

- Build the iOS target and verify goal persistence, weekday toggles, permission denial, and time changes on a device or simulator.

## References

- Related docs: `AGENTS.md`
- Related PRs/commits: pending
- Supersedes / Superseded by: N/A
