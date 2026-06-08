# US-003 Core Value Primitives

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_core` must expose the first stable pure Dart primitives used by later
drag state, measuring, collision, modifier, and sortable stories. The primitives
must not depend on Flutter or `dart:ui`.

## Relevant Product Docs

- `docs/product/overview.md`
- `docs/product/package-architecture.md`
- `docs/product/api-principles.md`
- `docs/product/release-roadmap.md`

## Acceptance Criteria

- `dnd_kit_core` exports `DndId`, `DndPoint`, `DndSize`, `DndRect`, and
  `DndTransform`.
- Geometry primitives are immutable value objects with predictable equality,
  hash codes, and readable `toString` output.
- `DndRect` supports common edge, center, containment, overlap, translation,
  and inflation helpers needed by collision and measuring work.
- `DndSize`, `DndRect`, and `DndTransform.scale` reject invalid negative values
  in debug mode.
- The implementation remains pure Dart and imports no Flutter or `dart:ui`
  types.
- Unit tests cover the public behavior introduced by this story.

## Design Notes

- Commands: `fvm dart format .`, `fvm dart analyze`, `fvm dart test`, and
  `scripts/bin/harness-cli story verify US-003`.
- Queries: none.
- API: value primitives only; no drag state machine, registry, collision, or
  sensor behavior in this story.
- Tables: none.
- Domain rules: core remains pure Dart and applications still own user data.
- UI surfaces: none.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-003 --unit 1 --integration 0 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | `fvm dart test packages/dnd_kit_core` passes. |
| Integration | Not required; this story introduces only one package's pure Dart values. |
| E2E | Not required; no user-facing UI exists. |
| Platform | Not required; no Flutter/platform code exists. |
| Release | `fvm dart analyze` passes from the repository root. |

## Harness Delta

- Adds the first Phase 1 story packet and durable matrix row.

## Evidence

- `fvm dart format .` completed with no changes needed.
- `fvm dart analyze` passed with no issues.
- `fvm dart test packages/dnd_kit_core` passed with 17 tests.
- `fvm dart run melos run test` passed for `dnd_kit_core` with 17 tests.
- `scripts/bin/harness-cli story verify US-003` passed with
  `fvm dart test packages/dnd_kit_core`.
