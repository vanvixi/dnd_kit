# US-068 Jaspr Drag Overlay Controller Rebind Fix

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_jaspr` must keep `DndDragOverlay` bound to the currently effective
controller when the nearest `DndScope` swaps controllers without remounting the
overlay component. Replacing a scope controller is a supported lifecycle path
for controlled `DndScope` usage, so the overlay must resume following the new
active drag session instead of staying subscribed to the previous controller and
rendering nothing.

## Relevant Product Docs

- `docs/product/api-principles.md`
- `docs/product/package-architecture.md`
- `docs/ARCHITECTURE.md`
- `docs/decisions/0016-jaspr-adapter-scope-and-runtime-model.md`
- `docs/stories/phase-14-jaspr-foundation/US-052-jaspr-drag-overlay.md`
- `docs/stories/phase-20-jaspr-example-gallery/US-067-jaspr-example-feature-gallery.md`

## Acceptance Criteria

- `DndDragOverlay` listens to the current effective controller, whether it came
  from `component.controller` or the nearest `DndScope`.
- If a controlled `DndScope` replaces its controller and the overlay instance
  stays mounted, the overlay detaches from the old controller and rebinds to
  the new one.
- A new drag started on the replacement controller renders overlay content and
  exposes the new session details to the builder.
- Focused component and browser regression tests cover the controller-rebind
  path so example flows that recreate controllers cannot silently lose the
  overlay.

## Design Notes

- Commands:
  `fvm dart test packages/dnd_kit_jaspr/test/src/widgets/drag_overlay_test.dart`
  `cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/drag_overlay_browser_test.dart`
  `fvm dart analyze packages/dnd_kit_jaspr`
- Queries:
  `scripts/bin/harness-cli query matrix`
  `rg -n "DndDragOverlay|controller|DndScope.of" packages/dnd_kit_jaspr`
- API:
  `DndDragOverlay`
  `DndScope`
  `DndController`
- Domain rules:
  The fix stays adapter-local and does not change the shared runtime or public
  overlay API. The overlay still resolves its controller from the nearest scope
  by default and only owns listener rebinding.
- UI surfaces:
  `DndDragOverlay` inside controlled Jaspr `DndScope` trees, including the
  modifiers demo in `examples/jaspr_example_gallery` that rebuilds controllers
  when switching modifier modes.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-068 --unit 1 --integration 1 --e2e 0 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Focused component coverage proves the overlay follows a replacement scope controller and surfaces the new session details. |
| Integration | Chrome browser coverage proves a still-mounted overlay rebinds after a scope-controller swap and renders during the next drag. |
| E2E | Not required; the regression is isolated with package-level proof. |
| Platform | `fvm dart analyze packages/dnd_kit_jaspr` stays clean. |
| Release | No release-surface doc change required because the public API and documented contract stay the same. |

## Harness Delta

No Harness process change expected. This story keeps the example-discovered
bug attached to the adapter layer so later proof and maintenance stay aligned
with the actual root cause.

## Evidence

- Created 2026-06-19 after real-browser exercise of the Phase 20 modifiers demo
  revealed that controller state kept changing after a modifier-mode swap while
  the overlay stopped rendering.
- Root cause: `DndDragOverlay` cached the old scope controller and kept its
  listener after the surrounding `DndScope` replaced controllers, so the still-
  mounted overlay never observed the new drag session.
- Fix: remove the stale scope-controller cache and always resolve the effective
  controller from `component.controller ?? DndScope.of(context)` before
  listener synchronization.
- Regression proof added in
  `packages/dnd_kit_jaspr/test/src/widgets/drag_overlay_test.dart` and
  `packages/dnd_kit_jaspr/test/drag_overlay_browser_test.dart`.
- `scripts/bin/harness-cli story verify US-068` passed on 2026-06-19.
- `fvm dart test packages/dnd_kit_jaspr/test/src/widgets/drag_overlay_test.dart`
  -> 3 passed.
- `cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/drag_overlay_browser_test.dart`
  -> 3 passed.
- `fvm dart analyze packages/dnd_kit_jaspr` -> No issues found.
