# US-041 Default haptic on touch drag activation

## Status

implemented

## Lane

normal

## Product Contract

When a drag starts on a **touch** pointer, the library emits a single haptic
pulse at the moment the drag activates, so picking up an item feels physical on
mobile. This applies to any touch activation path (the default delayed
hold-to-drag from US-040 and an explicit `longPressActivation`). Mouse /
precise-pointer drags emit no haptic.

Haptic is a single cross-cutting setting, resolved most-specific-first:

```text
DndDraggable.enableHapticFeedback  (bool?, null = inherit)
  -> DndScope default          (bool, default true)
    -> library default = true  (only actually fires on touch)
```

There is exactly one authority for the outcome — no per-place conflicts. Haptic
is **not** configured through `activationConstraint` (which only decides _when_
to activate), and the existing `DndLongPressActivation.hapticFeedback` field is
**removed** in favor of this resolution.

This closes the gap noted in US-040: today haptic only fires for the explicit
`longPressActivation` path, so the default touch hold gives no tactile cue.

## Relevant Product Docs

- `docs/product/api-principles.md` (Activation Principles)
- `docs/product/overview.md`
- Decision `docs/decisions/0010-draggable-arena-gesture.md` (platform-adaptive
  activation this builds on)

## Acceptance Criteria

- A drag activated on a touch pointer fires exactly one haptic pulse (e.g.
  `HapticFeedback.selectionClick`) when the drag starts — for both the default
  delayed-touch path and an explicit `longPressActivation`.
- Mouse / trackpad activations fire no haptic.
- Resolution is `DndDraggable.enableHapticFeedback` → `DndScope` default → library
  default (`true`): a non-null widget value overrides the scope; the scope
  value is non-null and defaults to `true`. Setting it to `false` at either
  level disables haptic without affecting drag behavior.
- `DndLongPressActivation.hapticFeedback` is removed; long-press haptic is now
  governed by the unified resolution above.
- Exactly one pulse per activation (no double-firing across paths).
- Firing haptics is safe on platforms without a haptic engine (web/desktop):
  it is a no-op, never throws, and does not block the drag.
- Keyboard drag activation fires no haptic.

## Design Notes

- Commands: none (UI feedback only).
- Queries: none.
- API (decided):
  - `DndDraggable.enableHapticFeedback` — `bool?`, default `null` (inherit).
  - `DndScope` gains an `enableHapticFeedback` default — `bool`, default
    `true`, exposed to the subtree (alongside the controller, e.g. via the
    existing inherited scope data).
  - Library default when no scope exists: `true`.
  - **Remove** `DndLongPressActivation.hapticFeedback` (breaking, pre-1.0).
  - Do **not** add haptic to `DndSensorActivationConstraint`.
  - Reuse `HapticFeedback` from `package:flutter/services`.
- Domain rules:
  - On drag start, resolve haptic via widget → scope → `true`. Emit one pulse
    only when the activation pointer is touch (and the resolved value is true).
    Non-touch pointers never emit. Trigger in `_handleDragStart`; remove the old
    `widget.longPressActivation?.hapticFeedback` branch. Track the activation
    pointer kind so the touch gate is accurate.
  - Ensure a single pulse per activation regardless of path (default delayed,
    long-press).
  - Out of scope: tactile patterns other than a single selection-style pulse.
- UI surfaces: `DndDraggable` (and therefore `SortableItem`, Kanban/sortable
  examples). No example must change; the Kanban/multi-container demos get the
  haptic for free on touch.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-041 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer       | Expected proof                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Unit        | n/a (behavior is platform-channel feedback)                                                                                                                                                                                                                                                                                                                                                                                                             |
| Integration | `flutter test` widget tests asserting (haptic calls captured via a `SystemChannels.platform` mock handler): default touch hold-then-drag fires exactly one `HapticFeedback.selectionClick`; explicit long-press touch fires exactly one; mouse drag fires none; keyboard drag fires none; `enableHapticFeedback: false` at the widget disables it; a scope default of `false` disables it with no widget value, and a widget value overrides the scope. |
| E2E         | Existing Kanban / multi-container example widget tests still pass.                                                                                                                                                                                                                                                                                                                                                                                      |
| Platform    | Manual confirmation on a physical iOS/Android device that pickup vibrates; no crash on web/desktop.                                                                                                                                                                                                                                                                                                                                                     |
| Release     | `melos run validate` passes; publish dry-run clean.                                                                                                                                                                                                                                                                                                                                                                                                     |

## Harness Delta

- New story; no template or policy change.
- Requires a durable decision (`docs/decisions/0012-touch-activation-haptics.md`)
  because it changes public API shape and default behavior: removes
  `DndLongPressActivation.hapticFeedback` (breaking), adds
  `DndDraggable.enableHapticFeedback` and a `DndScope` default, and turns haptic on by
  default for touch with a widget → scope → default resolution.
- CHANGELOG: note the breaking removal and the new default under both
  `dnd_kit` (and `dnd_kit_core` only if any shared type changes — expected to
  stay Flutter-side, so likely `dnd_kit` only).

## Evidence

- Implemented unified haptic resolution in `DndDraggable` and `DndScope`.
- Removed `DndLongPressActivation.hapticFeedback`; long-press haptics now use
  `DndDraggable.enableHapticFeedback` -> `DndScope.enableHapticFeedback` ->
  library default `true`, with `DndScope.enableHapticFeedback` defaulting to
  `true`.
- Added widget tests capturing `SystemChannels.platform` haptic calls for:
  default delayed touch activation, explicit long-press touch activation,
  mouse activation, keyboard activation, widget override, scope default, and
  widget-over-scope override.
- Added decision `docs/decisions/0012-touch-activation-haptics.md` and updated
  API principles plus `packages/dnd_kit/CHANGELOG.md`.
- `fvm flutter test packages/dnd_kit/test/src/widgets/draggable_test.dart`
  passed with 38 tests.
- `fvm flutter test packages/dnd_kit` passed with 118 tests.
- `fvm dart analyze` passed with no issues.
- `fvm dart run melos run validate` passed; it covered format check, workspace
  analyze, `dnd_kit_core` tests, `dnd_kit` tests, and Kanban,
  multi-container sortable, and example gallery widget tests.
- `scripts/bin/harness-cli story verify US-041` passed with the configured
  `fvm dart run melos run validate` command.
- Physical iOS/Android haptic confirmation was not run in this agent session.
