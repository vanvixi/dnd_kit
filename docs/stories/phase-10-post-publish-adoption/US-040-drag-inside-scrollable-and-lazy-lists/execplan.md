# Exec Plan

## Goal

Make `DndDraggable` and `SortableItem` usable inside vertical/horizontal
scrollables — including lazy `ListView.builder` — so adopters can build
performant, lazily-built sortable lists.

## Scope

In scope:

- Replace the pan `GestureDetector` activation path in `DndDraggable` with an
  arena-winning gesture recognizer (`MultiDragGestureRecognizer` family) via
  `RawGestureDetector`.
- Platform-adaptive default activation: mouse/precise → immediate; touch →
  delayed. Preserve explicit `activationConstraint` and `longPressActivation`.
- Keep drag handles, keyboard drag, disabled handling, and the existing
  `DndPointerSensor` state machine working.
- Make `SortableStrategies.verticalList/horizontalList/grid` produce insertion
  intent from the measured (visible) subset instead of bailing to fallback.
- Persist the active item's registration + measured rect on the controller for
  the whole drag session, surviving lazy recycle.
- Convert at least one example to `ListView.builder`; keep examples building.

Out of scope:

- Sliver sortable APIs, native OS DnD, off-screen virtual measurement.

## Risk Classification

Risk flags:

- Public contracts — gesture activation behavior is client-visible.
- Existing behavior — changes already-implemented and test-covered drag flow.
- Cross-platform — mouse vs touch activation diverges by design.
- Multi-domain — gesture sensor, measuring, and sortable strategy all change.

Hard gates:

- None (no auth, authorization, data loss/migration, audit/security, external
  provider, or validation-weakening).

Classification: high-risk (4 flags, no hard gate). Direction confirmed with the
human: platform-adaptive custom recognizer, fix in `DndDraggable` core.

## Work Phases

1. Discovery — done: reproduced all three problem layers with temporary tests.
2. Design — `design.md`; decision record `0010`.
3. Validation planning — `validation.md` test plan (unit + widget regression
   for each layer, example widget tests, `melos run validate`).
4. Implementation — Layer 1 (gesture) → Layer 2 (strategy) → Layer 3
   (lifecycle), each with regression tests.
5. Verification — run package tests, convert an example to `ListView.builder`,
   run example tests, `melos run validate`, publish dry-run.
6. Harness update — story status/proof, decision record, trace; bump version
   and CHANGELOG.

## Stop Conditions

Pause for human confirmation if:

- Making touch activation delayed-by-default regresses non-scroll touch drag in
  a way the human wants to avoid (revisit default).
- Winning the arena requires changing public `DndDraggable` constructor shape
  beyond additive parameters.
- Partial-measurement insertion cannot be made deterministic without changing
  the core strategy contract.
