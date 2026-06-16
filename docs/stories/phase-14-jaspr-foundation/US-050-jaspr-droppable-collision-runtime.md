# US-050 Jaspr DndDroppable And Collision Runtime Wiring

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_jaspr` must expose a first `DndDroppable` component that mirrors the
family API shape, registers droppable metadata with the shared runtime, and
lets Jaspr drag sessions resolve `controller.overId` from measured droppable
targets.

## Relevant Product Docs

- `docs/product/api-principles.md`
- `docs/product/package-architecture.md`
- `docs/ARCHITECTURE.md`
- `docs/decisions/0016-jaspr-adapter-scope-and-runtime-model.md`

## Acceptance Criteria

- `dnd_kit_jaspr` exports `DndDroppable`, `DndDroppableDetails`, and a
  droppable builder typedef aligned with the existing Flutter family naming.
- `DndDroppable` registers, updates, and unregisters a
  `DndDroppableRegistration` with owner semantics against the nearest
  `DndScope` controller.
- `DndDroppable` marks a DOM measurer for its id so the shared `DndRuntime`
  can resolve `controller.overId` and drag-end `overId` from collision results.
- Disabled droppables remain registered metadata but are ignored by collision
  resolution.
- Jaspr tests prove registry lifecycle, builder state, and collision wiring.

## Design Notes

- Commands:
  `fvm dart test packages/dnd_kit_jaspr`
  `fvm dart analyze packages/dnd_kit_jaspr`
- Queries:
  `scripts/bin/harness-cli query matrix`
- API:
  `DndDroppable`
  `DndDroppableDetails`
  `DndDroppableBuilder`
- Domain rules:
  Library reports drag/drop intent only; applications keep owning data.
  Browser-specific pointer proof remains deferred to US-053.
- UI surfaces:
  Jaspr component tree under `DndScope`.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id <id> --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | Shared runtime collision behavior remains pure-Dart and is exercised through the Jaspr controller contract. |
| Integration | `jaspr_test` proves `DndDroppable` registers/unregisters, updates builder state, and drives `controller.overId`/drag-end `overId` when measured rects are present. |
| E2E | Deferred to US-053 browser proof. |
| Platform | `dart analyze` is clean for `packages/dnd_kit_jaspr`. |
| Release | Public exports, README, and changelog mention the new surface. |

## Harness Delta

No Harness process change expected; this story only extends the Phase 14 Jaspr
adapter surface.

## Evidence

- Verified 2026-06-16.
- `fvm dart test packages/dnd_kit_jaspr` -> 11 passed, including new
  `DndDroppable` lifecycle, builder-state, and disabled-collision coverage.
- `fvm dart analyze packages/dnd_kit_jaspr` -> No issues found.
- Public package surface updated in `packages/dnd_kit_jaspr/lib/dnd_kit_jaspr.dart`,
  `README.md`, and `CHANGELOG.md`.
