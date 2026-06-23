# Phase 28 - Cross-Adapter Multi-Container Parity

Phase 18 gave `dnd_kit_jaspr` a single-container sortable preset, but the
remaining experimental multi-container helpers (`SortableContainer` and
`SortableMultiContainer`) still live only in the Flutter adapter even though
they are framework-neutral pure Dart.

This phase closes that parity gap without introducing a second move-intent
algorithm:

- move the experimental multi-container contract into `dnd_kit`;
- keep Flutter and Jaspr as thin adapter layers over the shared contract;
- preserve additive public imports for existing Flutter consumers;
- add focused proof that both adapters compute identical cross-container move
  intent from the same engine helper.

## Principle

Cross-adapter multi-container work in this phase must:

- keep the multi-container surface explicitly experimental;
- move only framework-neutral contract code into `dnd_kit`;
- avoid introducing Flutter, Jaspr, DOM, or widget/component concerns into the
  engine;
- preserve current same-container sortable behavior in both adapters;
- keep application-owned container and item mutation outside the library.

## Delivery Sequence

| Story | Scope | Decision |
| --- | --- | --- |
| **US-076** | Hoist the experimental multi-container helpers into `dnd_kit`, preserve Flutter compatibility, and expose the same shared contract to Jaspr | Existing ADR 0019 direction; new ADR only if API or boundary direction changes materially |

## Validation Ladder

- Core proof: `packages/dnd_kit` owns the experimental multi-container helper
  tests.
- Adapter proof: Flutter and Jaspr package tests prove the shared helper stays
  reachable from both adapter barrels.
- Example/browser proof: the Flutter multi-container demo and a Jaspr
  multi-container flow both report the same move intent over the shared engine.
