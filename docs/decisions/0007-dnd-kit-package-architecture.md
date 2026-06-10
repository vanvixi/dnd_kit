# 0007 dnd_kit Package Architecture

Date: 2026-06-08

## Status

Superseded by `docs/decisions/0008-main-dnd-kit-package.md`

## Context

`SPEC.md` defines `dnd_kit` as a Flutter drag-and-drop toolkit with a pure Dart
core, a Flutter adapter, sortable presets, and an umbrella package. The repo
previously contained Harness files and the seed spec, but no product package
structure.

Phase 0 needs a durable architecture decision before scaffolding source
folders, because package boundaries will shape all later public API work.

## Decision

Use a four-package monorepo:

- `packages/dnd_kit_core`
- `packages/dnd_kit_flutter`
- `packages/dnd_kit_sortable`
- `packages/dnd_kit`

Keep `dnd_kit_core` pure Dart with no Flutter import. Put Flutter widget,
render, gesture, measuring, overlay, auto-scroll, and semantics behavior in
`dnd_kit_flutter`. Put stable sortable presets in `dnd_kit_sortable`. Use
`dnd_kit` as the umbrella package that exports the public APIs of the other
packages.

## Consequences

Positive:

- Core algorithms can be unit tested without the Flutter SDK.
- Flutter adapter behavior can evolve without polluting core geometry and
  state-machine contracts.
- Sortable can remain a preset rather than the foundation of the engine.
- Users may depend on only the core package when they do not need Flutter.

Tradeoffs:

- Package-to-package versioning and local path dependencies must be maintained.
- Early API skeletons must avoid over-promising behavior before stories
  implement it.
- Full validation eventually needs both Dart and Flutter test commands.
