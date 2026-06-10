# US-035 Main Package Rename And Umbrella Collapse

## Status

implemented

## Lane

normal

## Product Contract

The public Flutter package is named `dnd_kit`. The package currently known as
`dnd_kit_flutter` is renamed into `dnd_kit` and becomes the primary package
developers depend on for drag-and-drop widgets, sensors, overlays, measuring,
auto-scroll, diagnostics, and stable sortable presets. The old umbrella-only
`dnd_kit` package is removed as a separate package role before release.

The package history must be preserved through file and directory renames rather
than deleting `packages/dnd_kit_flutter` and adding an unrelated replacement.

## Relevant Product Docs

- `README.md`
- `docs/ARCHITECTURE.md`
- `docs/product/package-architecture.md`
- `docs/product/api-principles.md`
- `docs/product/release-roadmap.md`
- `docs/decisions/0007-dnd-kit-package-architecture.md`
- `docs/decisions/0008-main-dnd-kit-package.md`

## Acceptance Criteria

- `packages/dnd_kit_flutter` is renamed into the primary `packages/dnd_kit`
  package with Git history preserved through rename-aware operations.
- The previous umbrella-only `packages/dnd_kit` role no longer exists as a
  separate public package.
- `package:dnd_kit/dnd_kit.dart` exports the Flutter adapter API and stable
  sortable preset API that application developers are expected to use.
- Workspace, Melos, examples, tests, docs, and package imports no longer direct
  application developers to `package:dnd_kit_flutter/dnd_kit_flutter.dart`.
- Internal package dependencies obey the layering rule: `dnd_kit_core` remains
  pure Dart, sortable remains a preset layer, and no inner package depends on a
  higher-level umbrella package.
- Public docs describe `dnd_kit` as the main Flutter package and explain any
  remaining secondary packages only when they are intentionally public.
- `dnd_kit_sortable` no longer exists as a separate package because sortable is
  part of `dnd_kit`.

## Design Notes

- Commands: use `git mv` or equivalent rename-preserving filesystem operations
  for package directory and library file moves.
- Queries: `scripts/bin/harness-cli query matrix`.
- API: canonical app import becomes `package:dnd_kit/dnd_kit.dart`.
- Tables: story row `US-035`.
- Domain rules: this is a release packaging/API polish story; drag/drop runtime
  semantics should remain unchanged.
- UI surfaces: no user-facing example UI behavior changes are expected.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-035 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | Core and main package sortable tests pass after package rename/import updates. |
| Integration | Flutter adapter, sortable, and example widget tests pass through renamed package imports. |
| E2E | Not required; no browser or app-level journey changes. |
| Platform | Not required; no native shell behavior changes. |
| Release | `fvm dart run melos run validate` passes after docs, workspace, and package references are updated. |

## Harness Delta

No Harness tool changes were required.

## Evidence

- `git mv` was used for the `packages/dnd_kit_flutter` package source and test
  moves into `packages/dnd_kit`, and for sortable source/test moves into the
  main package.
- `fvm flutter pub get` passed and refreshed workspace package resolution.
- `fvm dart run melos run analyze` passed for `dnd_kit`, `dnd_kit_core`,
  and `kanban_board`.
- `fvm dart test packages/dnd_kit_core` passed with 71 tests.
- `fvm flutter test packages/dnd_kit` passed with 104 tests, covering the
  Flutter adapter and sortable preset suite.
- `fvm flutter test examples/kanban_board` passed with 3 tests.
- `fvm dart run melos run validate` passed, covering format, workspace analyze,
  core tests, main package Flutter/sortable tests, and Kanban example tests.
