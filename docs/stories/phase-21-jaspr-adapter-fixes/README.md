# Phase 21 — Jaspr Adapter Fixes

Phase 20's runnable gallery put more real-browser pressure on
`dnd_kit_jaspr`, and that surfaced follow-up adapter bugs that were not visible
in the original foundation stories. This phase captures those bounded
regressions as adapter work, not example-only work, so the durable record keeps
the root cause and proof in the right layer.

## Principle

Follow-up fixes in this phase must:

- preserve the shared-runtime architecture and keep `DndRuntime` as the only
  drag engine;
- land the smallest adapter-local patch that restores the documented contract;
- strengthen focused package tests so the reproduced regression cannot hide
  behind broader example proof.

## Delivery Sequence

| Story | Scope | Decision |
| --- | --- | --- |
| **US-068** | Rebind `DndDragOverlay` when the nearest `DndScope` controller is replaced | No ADR (adapter-local regression fix) |
