# US-053 Jaspr Modifiers Wiring, Example, And Browser Proof

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_jaspr` must prove that shared-runtime modifiers behave the same way in
real browser-driven Jaspr drags as they do in Flutter and pure-Dart runtime
tests. The repository also needs a small runnable Jaspr example app that shows
the generic drag/drop API, handle usage, overlay usage, application-owned drop
state, and visibly modified motion.

## Relevant Product Docs

- `docs/product/api-principles.md`
- `docs/product/package-architecture.md`
- `docs/ARCHITECTURE.md`
- `docs/decisions/0016-jaspr-adapter-scope-and-runtime-model.md`
- `SPEC_JASPR.md`

## Acceptance Criteria

- `DndController(modifiers: ...)` in `dnd_kit_jaspr` affects pointer-driven
  browser drag movement and collision resolution, not just pure-Dart runtime
  tests.
- Jaspr browser tests prove modifier effects for active drags, including a
  scenario where collision still resolves against the modified transform.
- A runnable `examples/jaspr_basic_drag_drop` Jaspr app demonstrates:
  `DndScope`, `DndDraggable`, `DndDroppable`, `DndDragHandle`,
  `DndDragOverlay`, application-owned drop state, and visibly modified motion.
- Example docs explain how to run the Jaspr app locally, and the package/docs
  surface points users to the example.

## Design Notes

- Commands:
  `fvm dart test packages/dnd_kit_jaspr`
  `cd examples/jaspr_basic_drag_drop && ~/.pub-cache/bin/jaspr build`
  `cd examples/jaspr_basic_drag_drop && ~/.pub-cache/bin/jaspr serve --port 8091`
- Queries:
  `scripts/bin/harness-cli query matrix`
- API:
  `DndController.modifiers`
  `DndModifiers.restrictToHorizontalAxis`
  `DndModifiers.snapToGrid`
  `DndDragOverlay`
- Domain rules:
  Applications still own data; the example may update its own lane assignment
  state on `onDragEnd`, but the library continues reporting intent only.
  Modifiers remain owned by `dnd_kit_core`; Jaspr proof must exercise the same
  shared runtime path as Flutter.
- UI surfaces:
  A single-card browser example with horizontal lane movement, handle-only drag
  activation, live drag status, and overlay visuals.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id <id> --unit 1 --integration 1 --e2e 1 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Shared runtime modifier math remains covered by existing `dnd_kit_core` tests. |
| Integration | `fvm dart test packages/dnd_kit_jaspr` proves Jaspr component/browser modifier flows alongside the existing handle/overlay coverage. |
| E2E | The runnable Jaspr example is exercised in a real browser session with pointer dragging. |
| Platform | `cd examples/jaspr_basic_drag_drop && ~/.pub-cache/bin/jaspr build` succeeds. |
| Release | Example README plus package/docs surfaces mention the Jaspr example and modifier/browser proof completion. |

## Harness Delta

No Harness process change expected; this story closes the deferred browser-proof
gap left by US-049 through US-052.

## Evidence

- Partial progress recorded 2026-06-16.
- Added `examples/jaspr_basic_drag_drop` and local browser-proof instrumentation.
- `fvm dart analyze packages/dnd_kit_jaspr` passed after iterative handle/runtime
  experiments.
- `cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/draggable_browser_test.dart test/drag_overlay_browser_test.dart`
  passed, including extra coverage for controller modifiers and an ancestor
  rebuild case.
- `cd examples/jaspr_basic_drag_drop && dart analyze` passed.
- Follow-up `US-055` fixed the real-browser drag handle regression by keeping
  pointer move/up/cancel tracking alive at the window level after the pointer
  leaves the draggable subtree.
- `fvm dart test packages/dnd_kit_jaspr` passed after the regression fix.
- `cd examples/jaspr_basic_drag_drop && ~/.pub-cache/bin/jaspr build` passed.
- Real-browser verification in the Codex in-app browser on
  `http://localhost:8080` now completes a lane-crossing drag through the live
  example: the session returns to `State: DndIdle`, drag metrics show
  `s:1 m:5 e:1 c:0`, and the example updates app-owned lane state from
  `Brief` to `Ship`.
