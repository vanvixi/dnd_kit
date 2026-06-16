# US-058 Jaspr Diagnostics Alignment With Flutter

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_jaspr` must surface the same practical diagnostics contract as the
Flutter adapter for duplicate and unstable drag/drop ids. The shared
`DndWarning`/`DndDiagnosticsConfig` API already lives in `dnd_kit_core`; this
story makes sure Jaspr uses it with the same owner-aware, deferred duplicate
behavior as Flutter widget registration, so persistent duplicate component ids
warn after reconciliation while transient same-frame handoff does not.

## Relevant Product Docs

- `docs/product/api-principles.md`
- `docs/ARCHITECTURE.md`
- `docs/decisions/0011-owner-aware-registration.md`
- `docs/decisions/0015-shared-runtime-in-core.md`
- `docs/decisions/0016-jaspr-adapter-scope-and-runtime-model.md`
- `docs/stories/phase-8-production-hardening/US-033-diagnostics-duplicate-ids-registry-issues.md`
- `docs/stories/phase-10-post-publish-adoption/US-042-deferred-widget-duplicate-diagnostics.md`
- `SPEC_JASPR.md` (§4.6, §9 Phase C)

## Acceptance Criteria

- Persistent duplicate `DndDraggable` ids in Jaspr emit the same
  `duplicate-draggable-id` warning contract used by Flutter, including the
  deferred "after reconciliation" wording.
- Persistent duplicate `DndDroppable` ids in Jaspr emit the same
  `duplicate-droppable-id` warning contract used by Flutter.
- Owner-aware component handoff in Jaspr does not emit a duplicate warning when
  the duplicate claim resolves by the end of reconciliation, matching the
  Flutter lazy-list tolerance established by US-042.
- No new adapter-local diagnostics API is introduced unless proof shows Flutter
  parity cannot be reached through the shared `DndWarning` contract.
- Empty-id/unstable-id guidance remains aligned with the shared `DndId` and
  product docs; if no new runtime check is needed, the story records that parity
  is achieved through the shared core contract rather than a Jaspr-only warning.

## Design Notes

- Commands:
  `fvm dart test packages/dnd_kit_jaspr`
  `cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/draggable_browser_test.dart`
  `fvm dart analyze packages/dnd_kit_jaspr packages/dnd_kit_core`
- Queries:
  `scripts/bin/harness-cli query matrix`
  `rg -n "duplicate|warning|scheduleDeferredTask|postFrame|microtask" packages/dnd_kit_core packages/dnd_kit_flutter packages/dnd_kit_jaspr`
- API:
  `DndWarning`
  `DndDiagnosticsConfig`
  `DndRegistry`
  `DndController`
  `DndScope`
- Domain rules:
  The shared engine remains the only source of warning codes/messages. Jaspr may
  change only the adapter-side deferral boundary and test coverage needed to
  preserve behavioral parity with Flutter where users observe diagnostics,
  without requiring identical adapter internals.
- UI surfaces:
  `DndDraggable`
  `DndDroppable`
  `DndScope`

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-058 --unit 1 --integration 1 --e2e 1 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Shared core duplicate diagnostics remain green, and Jaspr controller/component tests cover duplicate draggable/droppable warning parity plus the no-warning handoff path. |
| Integration | `jaspr_test` proves duplicate component ids warn after reconciliation using the shared warning codes/messages. |
| E2E | A Chrome browser test proves duplicate diagnostics surface for persistent duplicate components without adapter-only warning drift. |
| Platform | `fvm dart analyze packages/dnd_kit_core packages/dnd_kit_jaspr` clean; SSR-safe posture preserved. |
| Release | `README.md`/`CHANGELOG.md` update only if the public diagnostics story changes materially; otherwise evidence records parity as internal hardening only. |

## Harness Delta

No Harness policy change expected. This is the last Phase 15 hardening slice
before the planned US-059 Jaspr first dev-release story.

## Evidence

- Created 2026-06-16 as the third and final Phase C story.
- Sequenced before US-059 by user direction so the first public Jaspr dev
  release happens only after diagnostics parity is validated.
- Implemented 2026-06-16:
  - `DndRegistry.scheduleDeferredTask` is now reconfigurable so an adapter can
    align owner-aware duplicate warnings with its own frame boundary after
    construction.
  - `DndScope` wires every active Jaspr controller's shared runtime registry to
    `context.binding.addPostFrameCallback`. This makes duplicate warnings settle
    on the Jaspr post-frame boundary instead of a controller-only microtask
    fallback, preserving duplicate-warning parity in actual component usage
    without forcing identical adapter mechanics.
  - Jaspr component tests now cover persistent duplicate draggable/droppable
    warnings plus owner handoff without warning spam.
  - Browser diagnostics proof now covers persistent duplicate draggable warning
    surfacing and no-warning owner handoff in a real browser environment.
  - No new unstable-id warning was added. Parity here comes from the shared core
    contract: `DndId('')` is already rejected in `dnd_kit_core`, and the product
    docs continue to treat whitespace/ephemeral ids as application misuse rather
    than a Jaspr-only diagnostics branch.
- Proof:
  - `fvm dart test packages/dnd_kit_jaspr` -> all tests passed, including new
    duplicate draggable/droppable component diagnostics coverage.
  - `cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/draggable_browser_test.dart`
    -> all tests passed, including new browser diagnostics coverage for
    persistent duplicates and owner handoff.
  - `fvm dart analyze packages/dnd_kit_core packages/dnd_kit_jaspr`
    -> No issues found.
- Release:
  - No `README.md` or `CHANGELOG.md` change was required because this story
    hardened internal parity without changing the public diagnostics API.
