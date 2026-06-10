# US-026 Sortable Vertical List Strategy Foundation

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_sortable` exposes the first stable sortable strategy contract and a
vertical list strategy that computes reorder intent from measured item
rectangles while keeping application-owned collections outside the library.

## Relevant Product Docs

- `docs/product/overview.md`
- `docs/product/package-architecture.md`
- `docs/product/api-principles.md`
- `docs/product/release-roadmap.md`

## Acceptance Criteria

- `SortableStrategy` and `SortableStrategyInput` are public from
  `dnd_kit_sortable`.
- `SortableStrategies.verticalList` computes `SortableMoveDetails.toIndex`
  from measured item rectangles and the active translated rectangle center.
- `SortableScope` accepts a strategy and defaults to the vertical list strategy.
- Strategy calculation reports intent only and does not mutate application
  item order.
- Missing measurement data falls back to the existing drop-over index behavior.
- Existing `SortableScope`, `SortableItem`, umbrella exports, and move callback
  behavior remain source-compatible.

## Design Notes

- Commands:
  - `fvm dart format .`
  - `fvm flutter test packages/dnd_kit_sortable`
  - `fvm dart analyze`
- Queries:
  - `scripts/bin/harness-cli query matrix`
- API:
  - `SortableStrategy`
  - `SortableStrategyInput`
  - `SortableStrategies.verticalList`
  - `SortableScope.strategy`
- Tables:
  - Harness `story` proof row for `US-026`.
- Domain rules:
  - User data remains external; sortable strategies return move intent only.
  - This slice covers same-container vertical list movement only.
  - Horizontal list, grid, keyboard-specific coordinates, and multi-container
    behavior remain future work.
- UI surfaces:
  - Flutter sortable subtree backed by measured `SortableItem` rectangles.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-026 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | Strategy tests prove vertical list index calculation, fallback behavior, same-item drops, and no external order mutation. |
| Integration | Widget tests prove `SortableScope` uses the configured strategy through `SortableItem` drop callbacks. |
| E2E | Not required for this strategy foundation slice. |
| Platform | Not required for this strategy foundation slice. |
| Release | `fvm dart analyze` and `fvm dart format .` pass. |

## Harness Delta

None expected.

## Evidence

- `fvm dart format .` passed.
- `fvm flutter test packages/dnd_kit_sortable` passed with 15 sortable tests,
  including 6 vertical strategy tests and custom strategy widget integration.
- `fvm dart analyze` passed with no issues.
- `scripts/bin/harness-cli story verify US-026` passed.
