# Validation

## Proof Strategy

Each of the three problem layers gets a regression test that fails against the
current code and passes after the fix, plus an example widget test that drives a
real gesture inside a lazy `ListView.builder`. The full workspace validation and
a publish dry-run must pass before the story is done.

## Test Plan

| Layer | Cases |
| --- | --- |
| Unit | Strategies (`verticalList`/`horizontalList`/`grid`) compute correct `toIndex` from a partial (visible-only) `itemRects` subset; still return fallback when no neighbour is measured. |
| Integration (widget) | (1) `DndDraggable` starts and tracks a vertical drag inside `SingleChildScrollView` and `ListView.builder` for mouse (immediate) and touch (delayed). (2) Drag does not start on a too-short touch hold when delayed. (3) Active item keeps registration + rect after its lazy element is recycled. (4) `SortableItem` inside `ListView.builder` reports a correct `SortableMoveDetails`. |
| E2E (example) | Example using `ListView.builder` reorders items via a driven gesture; existing Kanban + multi-container example tests still pass. |
| Platform | `example_gallery` web release build still succeeds. |
| Performance | Existing `performance_smoke_test` still within range (no regression from recognizer change). |
| Logs/Audit | N/A. |

## Fixtures

- Deterministic lists of `DndId`s (`item-0..N`) with fixed `itemExtent` so a
  known subset is visible in a sized viewport.
- `TestPointer`/`tester.startGesture` with explicit `PointerDeviceKind.mouse`
  and `.touch` to exercise both activation paths.

## Commands

```text
fvm flutter test packages/dnd_kit
fvm dart test packages/dnd_kit_core
fvm flutter test examples/<converted-example>
fvm flutter test examples/kanban_board
fvm flutter test examples/multi_container_sortable
fvm dart run melos run validate
```

Plus, for release metadata:

```text
fvm dart pub publish --dry-run    # in packages/dnd_kit
```

## Acceptance Evidence

- `fvm dart run melos run validate` passed (exit 0): `dart format
  --set-exit-if-changed .` clean, all packages analyze with no issues, and all
  test suites pass — `dnd_kit_core` 71 tests, `dnd_kit` 110 tests, and the
  `basic_drag_drop`, `kanban_board`, `multi_container_sortable`, and
  `example_gallery` examples.
- Layer 1 (gesture): new `packages/dnd_kit/test/src/widgets/draggable_in_scrollable_test.dart`
  proves a `DndDraggable` in a lazy `ListView.builder` starts and tracks a mouse
  drag immediately (list does not scroll), and a touch drag only after the hold
  delay.
- Layer 2 (measuring): `sortable_strategy_test.dart` extended/adjusted to cover
  partial (visible-only) measurement producing correct `toIndex`, with fallback
  retained when the drop-over target itself is unmeasured.
- Layer 3 (lifecycle): `draggable_in_scrollable_test.dart` proves an active drag
  survives the source element being recycled (registration + measured rect
  preserved, drag not cancelled, clean release).
- Example proof: `multi_container_sortable` and `kanban_board` converted to
  `ListView.builder` with `findChildIndexCallback`; their move/reorder/gap/
  top-half widget tests pass. The Kanban column keeps the interleaved drop
  indicator via a trailing list slot.
- Several existing widget tests were updated from default-touch immediate drags
  to explicit mouse (or delayed-touch) gestures to reflect the documented
  activation behavior change.

## Known Limitations / Follow-Up

- Resolved: registration is now owner-aware (`dnd_kit_core` 0.1.0-dev.2), so a
  lazy list re-mounting a keyed item before disposing the old element no longer
  trips the duplicate-id debug assertion. This fixed a crash reported while
  auto-scrolling a tall Kanban column during a drag. `findChildIndexCallback` is
  now a performance recommendation, not a correctness requirement. Regression:
  `draggable_in_scrollable_test.dart` › "lazy list rebuild that re-registers an
  id does not crash" (verified failing before the fix, passing after).
- Trade-off: widget-registered ids no longer raise a synchronous duplicate-id
  warning/assertion (owner mode is last-wins). The strict assertion remains for
  direct `DndRegistry` use without an `owner`. A deferred post-frame duplicate
  check could restore widget-level diagnostics for genuinely persistent
  duplicates if needed.
