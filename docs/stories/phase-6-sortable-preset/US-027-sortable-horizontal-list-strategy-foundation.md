# US-027 Sortable Horizontal List Strategy Foundation

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_sortable` exposes a stable horizontal list strategy that computes
same-container reorder intent from measured item rectangles while preserving the
application-owned collection model.

## Relevant Product Docs

- `docs/product/overview.md`
- `docs/product/package-architecture.md`
- `docs/product/api-principles.md`
- `docs/product/release-roadmap.md`

## Acceptance Criteria

- `SortableStrategies.horizontalList` is public from `dnd_kit_sortable`.
- `SortableStrategies.horizontalList` computes `SortableMoveDetails.newIndex`
  from measured item rectangles and the active translated rectangle center.
- Horizontal strategy calculation reports intent only and does not mutate
  application item order.
- Missing measurement data falls back to the existing drop-over index behavior.
- Non-horizontal layouts fall back to the existing drop-over index behavior.
- Existing `SortableScope`, `SortableItem`, umbrella exports, and default
  vertical strategy behavior remain source-compatible.

## Design Notes

- Commands:
  - `fvm dart format .`
  - `fvm flutter test packages/dnd_kit_sortable`
  - `fvm dart analyze`
- Queries:
  - `scripts/bin/harness-cli query matrix`
- API:
  - `SortableStrategies.horizontalList`
- Tables:
  - Harness `story` proof row for `US-027`.
- Domain rules:
  - User data remains external; sortable strategies return move intent only.
  - This slice covers same-container horizontal list movement only.
  - Grid, keyboard-specific coordinates, and multi-container behavior remain
    future work.
- UI surfaces:
  - Flutter sortable subtree backed by measured `SortableItem` rectangles.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-027 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | Strategy tests prove horizontal list index calculation, fallback behavior, same-item drops, and no external order mutation. |
| Integration | Widget tests prove `SortableScope` can use the horizontal strategy through `SortableItem` drop callbacks. |
| E2E | Not required for this strategy foundation slice. |
| Platform | Not required for this strategy foundation slice. |
| Release | `fvm dart analyze` and `fvm dart format .` pass. |

## Harness Delta

None expected.

## Evidence

- `fvm dart format .` passed.
- `fvm flutter test packages/dnd_kit_sortable` passed with 22 sortable tests,
  including 6 horizontal strategy tests and horizontal strategy widget
  integration.
- `fvm dart analyze` passed with no issues.
- `scripts/bin/harness-cli story verify US-027` passed.
