# US-055 Jaspr Real-Browser Drag Handle Activation Regression

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_jaspr` must start a real browser drag from `DndDragHandle` reliably in
the runnable Jaspr example and through the same shared-runtime path used by the
package browser tests. When a user presses and drags the visible handle in the
live app, the controller must leave `DndIdle`, emit drag lifecycle callbacks,
and update overlay/collision state instead of staying inert.

## Relevant Product Docs

- `docs/product/api-principles.md`
- `docs/product/package-architecture.md`
- `docs/ARCHITECTURE.md`
- `docs/decisions/0016-jaspr-adapter-scope-and-runtime-model.md`
- `SPEC_JASPR.md`
- `docs/stories/phase-14-jaspr-foundation/US-051-jaspr-drag-handle-input-kinds.md`
- `docs/stories/phase-14-jaspr-foundation/US-053-jaspr-modifiers-example-browser-proof.md`

## Acceptance Criteria

- The regression is reproducible and documented against
  `examples/jaspr_basic_drag_drop` on `http://localhost:8080`, including the
  observed idle state and zero drag counters.
- A real browser drag from the example's visible `DndDragHandle` transitions
  the controller away from `DndIdle` and produces non-zero start/move metrics.
- The root cause is isolated to the correct layer: Jaspr package runtime,
  example wiring, hydration/browser event behavior, or automation mismatch.
- Automated proof is strengthened so the failing real-browser path is covered
  by focused Jaspr browser validation and cannot silently regress while still
  passing the current synthetic flow.
- `US-053` remains open until this regression is resolved and its browser-proof
  evidence is updated to match the verified real-browser result.

## Design Notes

- Commands:
  `scripts/bin/harness-cli query matrix`
  `cd examples/jaspr_basic_drag_drop && ~/.pub-cache/bin/jaspr serve --port 8080`
  `cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/draggable_browser_test.dart`
  `fvm dart test packages/dnd_kit_jaspr`
- Queries:
  `rg -n "DndDragHandle|DndIdle|pointerdown|pointermove|pointerup" packages/dnd_kit_jaspr examples/jaspr_basic_drag_drop`
- API:
  `DndDragHandle`
  `DndDraggable`
  `DndController.state`
  `DndController.active`
  `DndController.overId`
- Domain rules:
  The shared `DndRuntime` remains the only drag engine; the fix must preserve
  application-owned drop state and must not replace the browser path with a
  Jaspr-specific second state machine. When auto-test and real-browser behavior
  disagree, the durable proof must be expanded until the real-browser path is
  explained.
- UI surfaces:
  `examples/jaspr_basic_drag_drop` running on localhost with the visible drag
  handle, live state panel, drag counters, and lane collision indicator.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id <id> --unit 0 --integration 1 --e2e 1 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | No new pure-Dart proof required unless the shared runtime contract changes during the fix. |
| Integration | Focused Jaspr browser tests fail on the reproduced regression path before the fix and pass after it. |
| E2E | The live example on `http://localhost:8080` is exercised in a real browser session and visibly leaves `DndIdle` during handle drag. |
| Platform | `fvm dart test packages/dnd_kit_jaspr` stays green, and any touched example/package analyze or build command remains clean. |
| Release | `US-053` evidence and example docs are updated so the browser-proof story no longer over-claims success. |

## Harness Delta

No Harness process change expected. This story strengthens the Jaspr
browser-proof trail so manual browser regressions cannot hide behind narrower
automation coverage.

## Evidence

- Created 2026-06-16 as the blocker follow-up for `US-053`.
- Root cause: the Jaspr draggable relied on element-local `pointermove` /
  `pointerup` / `pointercancel` handlers after activation. Browser tests passed
  because they dispatched synthetic events back onto the draggable subtree, but
  a real drag could leave that subtree before drop, losing later pointer events
  and leaving the session unable to continue or finish reliably.
- Fix: `DndDraggable` now attaches capture-phase window pointer listeners for
  the active gesture and cleans them up at gesture end/dispose, while keeping
  the shared `DndRuntime` as the only drag engine.
- Added browser regression coverage in
  `packages/dnd_kit_jaspr/test/draggable_browser_test.dart` for a handle drag
  that starts inside the draggable and continues on a different DOM target.
- `cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/draggable_browser_test.dart`
  passed with the new regression.
- `fvm dart test packages/dnd_kit_jaspr` passed.
- `fvm dart analyze packages/dnd_kit_jaspr` passed.
- `cd examples/jaspr_basic_drag_drop && dart analyze` passed.
- `cd examples/jaspr_basic_drag_drop && ~/.pub-cache/bin/jaspr build` passed.
- Real-browser verification after reload on `http://localhost:8080` now ends
  cleanly with `State: DndIdle`, `Drag: s:1 m:5 e:1 c:0`, and the example lane
  moving from `Brief` to `Ship`.
