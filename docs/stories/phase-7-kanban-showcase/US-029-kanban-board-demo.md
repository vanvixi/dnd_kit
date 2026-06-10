# US-029 Kanban Board Demo

## Status

implemented

## Lane

normal

## Product Contract

`examples/kanban_board` demonstrates that the generic Flutter drag-and-drop
APIs can power a realistic Kanban board without requiring experimental
multi-container sortable APIs.

## Relevant Product Docs

- `docs/product/overview.md`
- `docs/product/package-architecture.md`
- `docs/product/api-principles.md`
- `docs/product/release-roadmap.md`

## Acceptance Criteria

- The `kanban_board` example includes multiple columns and multiple task cards.
- Users can drag cards within the same column and to another column.
- The demo uses `DndScope`, `DndDraggable`, `DndDroppable`, and
  `DndDragOverlay`.
- The demo uses application-owned drag and drop data to mutate task placement
  from `DndDragEndEvent`.
- The active drag renders an overlay and the source item fades while dragging.
- Droppable columns and task cards expose drag-over visual state.
- Columns support vertical auto-scroll, and the board supports horizontal
  drag-driven auto-scroll.
- The demo uses a custom collision detector tuned for Kanban targets.
- The first Kanban demo does not depend on experimental multi-container
  sortable APIs.

## Design Notes

- Commands:
  - `fvm flutter pub get`
  - `fvm dart format .`
  - `fvm flutter test examples/kanban_board`
  - `fvm dart analyze`
- Queries:
  - `scripts/bin/harness-cli query matrix`
- API:
  - Generic Flutter adapter APIs from the umbrella `dnd_kit` package.
- Tables:
  - Harness `story` proof row for `US-029`.
- Domain rules:
  - User data remains external to the library.
  - The example mutates its own task collection after drop intent is reported.
  - Experimental multi-container sortable APIs remain future work.
- UI surfaces:
  - `examples/kanban_board` Flutter app.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-029 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | Custom Kanban collision detector is covered through example tests. |
| Integration | Widget tests prove rendering, same-column reorder, and cross-column movement. |
| E2E | Not required for this first showcase slice. |
| Platform | Deferred to production hardening; generated web, iOS, Android, and macOS shells exist. |
| Release | `fvm dart analyze` and `fvm dart format .` pass. |

## Harness Delta

None expected.

## Evidence

- `fvm flutter pub get` passed.
- `fvm dart format .` passed.
- `fvm flutter test examples/kanban_board` passed with 3 widget tests covering
  render, cross-column movement, and same-column reorder.
- `fvm dart analyze` passed with no issues.
- `scripts/bin/harness-cli story verify US-029` passed.
