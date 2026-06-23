# Overview

## Current Behavior

The current multi-container sortable contract is split unevenly across the
package family:

- `dnd_kit_flutter` exposes the experimental pure-Dart helpers
  `SortableContainer` and `SortableMultiContainer` from
  `src/sortable/sortable_container.dart`.
- `dnd_kit_jaspr` already exposes `SortableScope` / `SortableItem` and carries
  `containerId` through `SortableScopeData`, but it has no first-class
  multi-container helper surface.
- `docs/product/package-architecture.md` still documents multi-container
  sorting as a Flutter-only experimental feature.

The remaining gap is architectural rather than algorithmic: the helper types
already depend only on `dnd_kit` value objects, but they were never hoisted out
of the Flutter adapter after ADR 0019 deferred the work.

## Target Behavior

`dnd_kit` becomes the shared home of the experimental multi-container sortable
contract:

- the engine owns `SortableContainer` and `SortableMultiContainer`;
- `dnd_kit_flutter` keeps its current public surface through additive
  compatibility re-exports and unchanged same-container behavior;
- `dnd_kit_jaspr` re-exports the same helper contract so Jaspr apps can compute
  the identical cross-container `SortableMoveDetails` intent as Flutter apps;
- docs and validation prove that multi-container parity now flows through one
  shared engine contract rather than adapter-local duplication.

This keeps the feature experimental while removing the last Flutter-only pure
Dart sortable helper from the adapter boundary.

## Affected Users

- Maintainers evolving the shared engine and package family.
- Flutter applications already using the experimental multi-container helpers.
- Jaspr applications that need first-class cross-container sortable intent
  without hand-rolling their own helper logic.

## Affected Product Docs

- `docs/product/package-architecture.md`
- `docs/product/release-roadmap.md`
- `docs/stories/backlog.md`
- `docs/decisions/0019-jaspr-sortable-preset.md`

## Non-Goals

- Making the experimental multi-container API stable.
- Changing same-container `SortableScope` / `SortableItem` semantics.
- Moving adapter-owned scope plumbing or browser/widget execution into
  `dnd_kit`.
- Designing nested sortable, virtualization, or board-specific UI patterns.
