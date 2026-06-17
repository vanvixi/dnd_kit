# US-062 Jaspr Sortable Preset

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_jaspr` gains a single-container sortable preset at parity with the
Flutter adapter: `SortableScope` (item order + pluggable strategy, default
`verticalList`) and `SortableItem` (a draggable + droppable that reports
`SortableMoveDetails` reorder intent through `onMove`). All reorder math is the
shared `dnd_kit` engine, so Jaspr and Flutter compute identical move intent and
Jaspr inherits the vertical/horizontal/grid single-container strategies that the
engine already re-exports. This is additive and adapter-local: the engine and
Flutter packages do not change; `dnd_kit_jaspr` bumps to `0.3.0-dev.1`.
Multi-container sorting (`SortableContainer`/`SortableMultiContainer`) is out of
scope and stays Flutter-only for now. Implements ADR 0019.

## Relevant Product Docs

- `docs/decisions/0019-jaspr-sortable-preset.md`
- `SPEC_JASPR.md`
- `packages/dnd_kit_jaspr/lib/src/sortable/sortable_scope.dart`
- `packages/dnd_kit_jaspr/lib/src/sortable/sortable_item.dart`
- `packages/dnd_kit_jaspr/lib/dnd_kit_jaspr.dart`
- `packages/dnd_kit_jaspr/pubspec.yaml`

## Acceptance Criteria

- `SortableScope` wraps `DndScope`, holds an unmodifiable `itemIds` order and a
  `SortableStrategy` (default `SortableStrategies.verticalList`), and exposes
  `SortableScopeData` via an `InheritedComponent` read through `SortableScope.of`
  / `maybeOf`.
- `SortableScopeData.moveDetailsFor` returns the engine strategy's
  `SortableMoveDetails`, passing measured droppable rects and the active rect; it
  returns null for no over-target, drop-over-self, or out-of-scope active items.
- `SortableItem` composes `DndDroppable` over `DndDraggable`, registers both ids,
  and on drag end forwards a non-null `moveDetailsFor` result to the scope's
  `onMove`. Its optional `builder` receives live `SortableItemDetails`
  (`index`, `isActive`, `isDragging`, `isDropping`, `isOver`, `overId`).
- `dnd_kit_jaspr.dart` exports `sortable_scope.dart` and `sortable_item.dart`.
- `packages/dnd_kit_jaspr` bumps to `0.3.0-dev.1` with a CHANGELOG entry; the
  engine and Flutter packages are unchanged.
- `fvm dart run melos run validate` and `fvm dart pub publish --dry-run`
  (`packages/dnd_kit_jaspr`) pass.

## Design Notes

- Reorder logic is not reimplemented: `SortableScopeData.moveDetailsFor` mirrors
  the Flutter adapter and calls `SortableStrategyInput`/`SortableStrategies` from
  the engine, including `activeTranslatedRect` derived from
  `event.session.transform.offset`.
- Jaspr `DndDraggable` has no `builder` (drag visuals render via
  `DndDragOverlay`), so `SortableItem` surfaces state-aware rendering through the
  droppable layer's builder, which already rebuilds on controller change.
- `SortableScopeData` is replicated in the Jaspr adapter (as in Flutter) rather
  than hoisted into the engine, keeping the change additive and adapter-local
  (ADR 0019).

## Validation

`scripts/bin/harness-cli story update --id US-062 --unit 1 --integration 1 --e2e 0 --platform 1`

| Layer | Expected proof |
| --- | --- |
| Unit | `SortableScopeData.moveDetailsFor` covers null cases, drop-over fallback, vertical up/down geometry, container-id propagation, and `indexOf`; `SortableScope.of`/`maybeOf` provision. |
| Integration | Component tests: `SortableItem` registers its draggable + droppable; its `builder` reflects live `index`/`isOver`/`isActive` as a controlled drag moves over it. |
| E2E | Not required; full pointer pipeline is covered by the existing browser draggable/droppable suites the preset composes. |
| Platform | `fvm dart run melos run validate` + `fvm dart pub publish --dry-run` for `packages/dnd_kit_jaspr` pass. |

## Harness Delta

No Harness process change. Adds the Jaspr sortable preset story under Phase 18.

## Evidence

- Created 2026-06-17 after the owner selected Jaspr sortable parity as the next
  initiative once the `0.3.0-dev.0` family line was published.

## Proof

- Implemented 2026-06-17. New files
  `packages/dnd_kit_jaspr/lib/src/sortable/sortable_scope.dart` and
  `sortable_item.dart`, exported from `dnd_kit_jaspr.dart`; engine and Flutter
  packages unchanged.
- `fvm dart analyze packages/dnd_kit_jaspr`: no issues.
- `fvm dart test packages/dnd_kit_jaspr`: 34 tests pass, including the 12 new
  sortable tests (`SortableScopeData.moveDetailsFor` null/fallback/vertical
  up+down/container-id/`indexOf`, `SortableScope.of`/`maybeOf` provision, and
  `SortableItem` draggable+droppable registration + live builder details).
- `fvm dart run melos run validate`: format clean, analyze clean for all
  members, and all suites pass (engine, jaspr, Flutter adapter, kanban /
  multi-container / gallery examples).
- `fvm dart pub publish --dry-run` (`packages/dnd_kit_jaspr`): one warning, the
  expected dirty-git-tree notice for the `0.3.0-dev.1` bump.
