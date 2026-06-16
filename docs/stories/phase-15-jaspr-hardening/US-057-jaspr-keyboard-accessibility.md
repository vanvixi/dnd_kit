# US-057 Jaspr Keyboard And Accessibility Hardening

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_jaspr` must give drag-and-drop a usable, configurable accessibility
story on the web: screen-reader users hear drag lifecycle changes through an
ARIA live region, draggables/handles expose configurable labels and usage
instructions, and keyboard drags keep predictable focus. This builds on the
baseline keyboard pickup/move/drop/cancel from US-051 without forking the shared
runtime or copying Flutter semantics literally (SPEC_JASPR §7).

## Relevant Product Docs

- `docs/product/api-principles.md`
- `docs/product/package-architecture.md`
- `docs/ARCHITECTURE.md`
- `docs/decisions/0016-jaspr-adapter-scope-and-runtime-model.md`
- `SPEC_JASPR.md` (§7, §9 Phase C)
- `docs/stories/phase-14-jaspr-foundation/US-051-jaspr-drag-handle-input-kinds.md`

## Acceptance Criteria

- A `DndLiveRegion` component renders a visually-hidden, polite/assertive ARIA
  live region that announces drag start, drag-over target changes, drop, and
  cancel, derived from the shared controller's state transitions (works for
  pointer, mouse, and keyboard drags alike).
- Announcement text is configurable via a `DndAnnouncements` value with sensible
  English defaults; it is provided through `DndScope` and overridable per
  `DndLiveRegion`.
- `DndDraggable` and `DndDragHandle` accept a configurable accessible `label`
  (and role description) instead of only the hardcoded defaults; when omitted,
  the existing defaults are kept (no breaking change).
- `DndDraggable` can expose keyboard usage instructions to assistive tech (a
  visually-hidden description referenced via `aria-describedby`) when a
  description is provided.
- Keyboard drags keep focus on the activator: starting, moving, dropping, and
  cancelling a keyboard drag does not move focus away from the draggable/handle.
- The package stays SSR-safe: all DOM access guarded by `kIsWeb`, no top-level
  `dart:js_interop`; importing from a server entrypoint stays safe.

## Design Notes

- Commands:
  `fvm dart test packages/dnd_kit_jaspr`
  `cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/accessibility_browser_test.dart`
  `fvm dart analyze packages/dnd_kit_jaspr`
- Queries:
  `scripts/bin/harness-cli query matrix`
  `rg -n "aria-|role|tabindex|live|announce|describedby" packages/dnd_kit_jaspr`
- API:
  `DndLiveRegion`
  `DndAnnouncements`
  `DndScope(announcements: ...)`
  `DndDraggable(label:, description:)`
  `DndDragHandle(label:)`
- Domain rules:
  Announcements are derived from the shared `DndRuntime` state via the
  controller; no Jaspr-only drag state machine. Applications still own data.
  The live region is adapter-specific (web a11y), not shared.
- UI surfaces:
  A visually-hidden live region in the component tree; focusable, labelled drag
  handles with optional `aria-describedby` instructions.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-057 --unit 0 --integration 1 --e2e 1 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Default `DndAnnouncements` message builders produce the expected strings for start/over/end/cancel (pure-Dart). |
| Integration | `jaspr_test` proves `DndLiveRegion` text updates across drag lifecycle transitions and that draggable/handle label/description attributes render. |
| E2E | A Chrome browser test drives a real drag and asserts live-region text changes and that keyboard drag keeps focus on the activator. |
| Platform | `fvm dart analyze packages/dnd_kit_jaspr` clean; no Flutter dep, no top-level `dart:js_interop`/`package:web`. |
| Release | Public exports, `README.md`, and `CHANGELOG.md` mention the accessibility surface. |

## Harness Delta

No Harness process change expected; this is the second Phase 15 (Phase C)
hardening slice and extends the Jaspr adapter story trail only.

## Evidence

- Created 2026-06-16 as the second Phase C story after US-056 (auto-scroll)
  landed and verified.
- Implemented 2026-06-16:
  - Added `DndAnnouncements` (`lib/src/a11y/announcements.dart`): configurable
    start/over/end/cancel message builders with English defaults.
  - Added `DndLiveRegion` (`lib/src/a11y/live_region.dart`): a visually-hidden
    `role=status` `aria-live` region that derives announcements from the shared
    controller's state transitions (start, over-target change, drop, cancel) for
    pointer/mouse/keyboard drags alike.
  - `DndScope` now provides `announcements` (default `DndAnnouncements()`) via the
    inherited provider, read with `DndScope.announcementsOf`; no DOM change, no
    breaking change.
  - `DndDraggable` gains `label` (`aria-label`) and `description` (visually-hidden
    element referenced via `aria-describedby`); `DndDragHandle` gains `label`.
  - Keyboard drags keep focus on the activator (no focus-moving code; verified).
  - Barrel exports `DndAnnouncements` + `DndLiveRegion`. SSR-safe (no top-level
    `dart:js_interop`; DOM behind `kIsWeb`).
- Proof:
  - `fvm dart test packages/dnd_kit_jaspr` -> 18 passed (incl. 5 new
    `DndAnnouncements` default/custom-builder unit tests).
  - `cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/accessibility_browser_test.dart`
    -> 3 passed: live-region text across start/over/drop; configurable
    label + `aria-describedby` description element; keyboard drag keeps focus on
    the activator.
  - Full browser regression: `fvm dart test -p chrome test/draggable_browser_test.dart
    test/drag_overlay_browser_test.dart test/auto_scroll_browser_test.dart
    test/accessibility_browser_test.dart` -> 16 passed.
  - `fvm dart analyze packages/dnd_kit_core packages/dnd_kit_jaspr packages/dnd_kit_flutter`
    -> No issues found.
- Release: barrel, `README.md`, and `CHANGELOG.md` updated for the accessibility
  surface.
