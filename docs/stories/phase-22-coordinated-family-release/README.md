# Phase 22 — Coordinated Family Release Publication

After the shared engine and both adapters shipped their post-rename dev line,
the repository accumulated additive unpublished package changes across all
three publishable packages:

- `dnd_kit` added the axis-aware shared auto-scroll contract.
- `dnd_kit_flutter` adopted that contract for horizontal auto-scroll.
- `dnd_kit_jaspr` adopted horizontal auto-scroll and later fixed overlay
  rebinding after a controlled scope/controller swap.

This phase captures the next coordinated pub.dev publication so release order,
version constraints, changelog truth, and dry-run proof stay auditable in one
place instead of being inferred from scattered package metadata.

## Principle

Release work in this phase must:

- publish in dependency order: `dnd_kit` -> `dnd_kit_flutter` ->
  `dnd_kit_jaspr`;
- keep version bumps as small as the implemented contract changes allow;
- prove the release locally with full workspace validation and package dry-runs
  before any irreversible pub.dev publish;
- record the exact publish order, versions, and any human-gated final publish
  outcome.

## Delivery Sequence

| Story | Scope | Decision |
| --- | --- | --- |
| **US-069** | Publish the current engine + Flutter + Jaspr development line with aligned changelogs and dependency constraints | No ADR (release execution under existing package topology decisions) |
