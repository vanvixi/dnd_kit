# US-033 Diagnostics For Duplicate IDs And Registry Warnings

## Status

implemented

## Lane

normal

## Product Contract

Core registry and Flutter controller diagnostics warn app developers when
duplicate draggable or droppable IDs are registered in the same registry.
Debug mode still fails fast with assertions, while release-mode registry
behavior can report the issue through `DndDiagnosticsConfig.onWarning`.

## Relevant Product Docs

- `docs/product/release-roadmap.md`
- `docs/product/api-principles.md`
- `docs/product/package-architecture.md`

## Acceptance Criteria

- `DndDiagnosticsConfig` exists in the public core API.
- An `onWarning` callback receives actionable duplicate draggable ID warnings.
- An `onWarning` callback receives actionable duplicate droppable ID warnings.
- Debug duplicate registration assertions remain in place.
- `DndController` accepts diagnostics configuration and passes it to its
  registry.

## Design Notes

- Commands:
  - `fvm dart test packages/dnd_kit_core`
  - `fvm flutter test packages/dnd_kit_flutter`
- Queries:
  - `scripts/bin/harness-cli query matrix`
- API:
  - `DndWarning`
  - `DndWarningCallback`
  - `DndDiagnosticsConfig`
  - `DndController(diagnosticsConfig: ...)`
- Tables:
  - Harness `story` proof row for `US-033`.
- Domain rules:
  - IDs remain app-owned and must be unique within a registry by entry type.
  - Diagnostics are non-fatal callbacks; debug assertions still catch duplicate
    IDs during development.
- UI surfaces:
  - None.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-033 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | `fvm dart test packages/dnd_kit_core` covers warning models and duplicate registry warnings. |
| Integration | `fvm flutter test packages/dnd_kit_flutter` covers controller diagnostics flowing through duplicate widgets. |
| E2E | Not required for registry diagnostics. |
| Platform | Not required for pure Dart and Flutter widget diagnostics. |
| Release | Covered later by workspace validation after this story lands. |

## Harness Delta

None expected.

## Evidence

- `fvm dart test packages/dnd_kit_core` passed with 71 tests, including
  `DndWarning` value behavior and duplicate draggable/droppable registry
  warning coverage.
- `fvm flutter test packages/dnd_kit_flutter` passed with 68 tests, including
  controller diagnostics configuration flowing to its registry.
- `fvm dart analyze` passed with no issues.
