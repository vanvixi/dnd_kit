# Phase 29 - Production-Ready Multi-Container

Phase 28 closed the helper-parity gap by moving the experimental
multi-container contract into `dnd_kit`, but the feature is still not a
production-ready library surface:

- applications still own collision ranking and insertion semantics;
- the Flutter example still uses a two-phase state update workaround for
  cross-container moves;
- Jaspr has helper parity but not a first-class adapter-level production story;
- the feature is still documented as experimental rather than supported.

This phase turns multi-container from a low-level helper surface into a
production-ready capability across the package family without taking over app
presentation:

- the library owns default interaction semantics for target resolution and
  insertion behavior;
- applications keep ownership of rendering, theming, animation, and data
  mutation;
- adapters expose a first-class multi-container surface instead of requiring
  each app to wire raw droppables, collision detectors, and drag-end policies
  by hand;
- applications can still override the default interaction policy when product
  behavior genuinely differs.

## Principle

Production-ready multi-container work in this phase must:

- separate interaction policy from visual presentation;
- provide stable library defaults for drag/drop meaning across containers;
- preserve app-owned rendering, motion, and state mutation;
- allow policy override hooks without forcing every app to rebuild the default
  board behavior from scratch;
- keep Flutter and Jaspr aligned on behavior semantics even when their
  framework wiring differs.

## Delivery Sequence

| Story | Scope | Decision |
| --- | --- | --- |
| **US-077** | Define and deliver the production-ready multi-container contract, default policies, and adapter-level surface across Flutter and Jaspr | Requires a new ADR because the feature graduates from experimental helper semantics to a supported cross-adapter interaction contract |

## Validation Ladder

- Core proof: policy resolution, insertion semantics, and override hooks are
  covered in `packages/dnd_kit`.
- Adapter proof: Flutter and Jaspr package tests prove each adapter exposes the
  same production multi-container contract.
- Example/browser proof: the Flutter and Jaspr board flows exercise the default
  interaction policy and override behavior in real drag scenarios.
