# US-028 Sortable Grid Strategy Foundation

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_sortable` exposes a stable grid strategy that computes same-container
reorder intent from measured item rectangles while preserving the
application-owned collection model.

## Relevant Product Docs

- `docs/product/overview.md`
- `docs/product/package-architecture.md`
- `docs/product/api-principles.md`
- `docs/product/release-roadmap.md`

## Acceptance Criteria

- `SortableStrategies.grid` is public from `dnd_kit_sortable`.
- `SortableStrategies.grid` computes `SortableMoveDetails.newIndex` from
  measured item rectangles and the active translated rectangle center in
  row-major order.
- Grid strategy calculation reports intent only and does not mutate
  application item order.
- Missing measurement data falls back to the existing drop-over index behavior.
- Non-grid layouts fall back to the existing drop-over index behavior.
- Existing `SortableScope`, `SortableItem`, umbrella exports, vertical strategy,
  and horizontal strategy behavior remain source-compatible.

## Design Notes

- Commands:
  - `fvm dart format .`
  - `fvm flutter test packages/dnd_kit_sortable`
  - `fvm dart analyze`
- Queries:
  - `scripts/bin/harness-cli query matrix`
- API:
  - `SortableStrategies.grid`
- Tables:
  - Harness `story` proof row for `US-028`.
- Domain rules:
  - User data remains external; sortable strategies return move intent only.
  - This slice covers same-container grid movement only.
  - Keyboard-specific coordinates, multi-container behavior, nested sorting,
    and virtualized grids remain future work.
- UI surfaces:
  - Flutter sortable subtree backed by measured `SortableItem` rectangles.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-028 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | Strategy tests prove grid index calculation, fallback behavior, same-item drops, and no external order mutation. |
| Integration | Widget tests prove `SortableScope` can use the grid strategy through `SortableItem` drop callbacks. |
| E2E | Not required for this strategy foundation slice. |
| Platform | Not required for this strategy foundation slice. |
| Release | `fvm dart analyze` and `fvm dart format .` pass. |

## Harness Delta

None expected.

## Evidence

- `fvm dart format .` passed.
- `fvm flutter test packages/dnd_kit_sortable` passed with 29 sortable tests,
  including 6 grid strategy tests and grid strategy widget integration.
- `fvm dart analyze` passed with no issues.
- `scripts/bin/harness-cli story verify US-028` passed.
