# ADR Guide

Use ADRs (Architecture Decision Records) for significant technical decisions.

## When to add ADR

- Layering and dependency rules
- Protocol boundaries and ownership changes
- Storage/query strategy changes
- Naming decisions that affect multiple modules

## Naming

- `0001-short-title.md`
- `0002-short-title.md`
- Increment monotonically

## Process

1. Copy `0000-template.md`.
2. Fill context, decision, consequences, alternatives.
3. Reference implementation PR/commit if available.
4. Keep ADR immutable; create a new ADR to supersede.
