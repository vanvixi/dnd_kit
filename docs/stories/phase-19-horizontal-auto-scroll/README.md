# Phase 19 — Cross-Adapter Horizontal Auto-Scroll

This phase explores the next parity gap after `US-062`: the shared auto-scroll
math and both adapter surfaces are still vertical-only, even though the Flutter
Kanban example already contains app-owned horizontal board auto-scroll logic.

## Principle

Horizontal auto-scroll must follow the same reuse posture as the existing
vertical path:

- axis math belongs in `dnd_kit`;
- Flutter and Jaspr only execute scrolling on their own platforms;
- no adapter forks the edge-threshold or velocity curve;
- Jaspr stays SSR-safe.

The phase starts with discovery/design, then lands the implementation in thin
package slices so the shared API direction is proven before adapters adopt it.

## Delivery Sequence

| Story | Scope | Decision |
| --- | --- | --- |
| **US-063** | Feasibility and design for horizontal auto-scroll across `dnd_kit`, `dnd_kit_flutter`, and `dnd_kit_jaspr` | ADR 0020 |
| **US-064** | Add axis-aware auto-scroll math to `dnd_kit`, preserving vertical default behavior | ADR 0020 |

## Follow-Up

With the discovery story and the core contract slice now complete, subsequent
implementation work should continue along package boundaries:

- Flutter execution layer adoption;
- Jaspr execution layer adoption.

The discovery story closed with those slices recommended and with these
explicit deferrals:

- document-viewport horizontal auto-scroll;
- simultaneous bi-directional auto-scroll in one surface;
- nested-scroll policy.

## Validation Ladder

- Discovery proof: current-code audit confirms where auto-scroll is vertical
  only, where app-owned horizontal logic already exists, and what the shared
  API would need to own.
- Design proof: the story packet records the recommended API shape, scope
  boundaries, and follow-up slices without weakening existing validation.
- Core implementation proof now exists in `US-064` (`dart test` + `dart analyze`
  for `packages/dnd_kit`), and later stories will extend the ladder to Flutter
  widget tests and Jaspr browser tests.
