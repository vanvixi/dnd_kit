# Validation

## Proof Strategy

The story is done only when multi-container is validated as a supported feature
rather than a helper-level experiment: the library provides stable default
interaction semantics, adapter-level surfaces expose them consistently, and apps
retain presentation ownership plus policy override hooks.

## Test Plan

| Layer | Cases |
| --- | --- |
| Unit | Core tests cover default target resolution, before/after insertion, empty-container insertion, same-container reorder, cross-container move intent, and override-hook branching. |
| Integration | Flutter and Jaspr package tests prove each adapter exposes the same multi-container contract and callback semantics without app-owned low-level wiring for the default case. |
| E2E | Flutter and Jaspr production examples cover realistic board flows: same-container reorder, cross-container move, drop into empty container, ambiguous target resolution, and one custom-policy override. |
| Platform | `fvm dart analyze`, targeted package tests, browser proof for Jaspr, and workspace validation all pass on the release line that first ships the supported feature. |
| Performance | Multi-container default policy does not regress current sortable smoke baselines beyond an agreed tolerance. |
| Logs/Audit | Harness intake, story, decision, and trace records capture the promotion from experimental helper to supported feature. |

## Fixtures

- A deterministic board with at least three containers, including one empty
  container.
- A shared set of stable `DndId` fixtures reused across Flutter and Jaspr.
- At least one custom policy fixture to prove override hooks without replacing
  the whole adapter surface.

## Commands

```text
fvm dart analyze packages/dnd_kit
fvm dart analyze packages/dnd_kit_flutter
fvm dart analyze packages/dnd_kit_jaspr
cd examples/multi_container_sortable && fvm dart analyze
fvm dart test packages/dnd_kit
fvm flutter test packages/dnd_kit_flutter
fvm dart test packages/dnd_kit_jaspr
cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/multi_container_browser_test.dart
cd examples/multi_container_sortable && fvm flutter test test/widget_test.dart
```

## Acceptance Evidence

- Implemented 2026-06-24 as the first production-ready multi-container slice.
- `dnd_kit` now owns the default multi-container collision detector and
  move-intent policy, including empty-container handling and adaptive
  before/after insertion around an over-item target.
- `dnd_kit_flutter` and `dnd_kit_jaspr` now expose
  `SortableMultiScope` / `SortableMultiContainerArea` / `SortableMultiItem`.
- Flutter example proof now uses the supported adapter surface instead of raw
  `DndDroppable` + custom collision detector + item-level `onDragEnd`.
- Validation passed with:
  - `fvm dart analyze packages/dnd_kit`
  - `fvm dart analyze packages/dnd_kit_flutter`
  - `fvm dart analyze packages/dnd_kit_jaspr`
  - `cd examples/multi_container_sortable && fvm dart analyze`
  - `fvm dart test packages/dnd_kit`
  - `fvm flutter test packages/dnd_kit_flutter`
  - `fvm dart test packages/dnd_kit_jaspr`
  - `cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/multi_container_browser_test.dart`
  - `cd examples/multi_container_sortable && fvm flutter test test/widget_test.dart`
