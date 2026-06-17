# US-061 Flutter Upgrade And Jaspr Example Workspace Unification

## Status

implemented

## Lane

normal

## Product Contract

The development Flutter SDK is pinned to 3.44.2, and the previously standalone
Jaspr example (`examples/jaspr_basic_drag_drop`) becomes a member of the pub
workspace, dropping the `dependency_overrides: dnd_kit` workaround it required
outside the workspace. This is a dev-toolchain and monorepo change only: no
published-package API or version change, and no change to consumer-facing SDK
constraints. Implements ADR 0018.

## Relevant Product Docs

- `docs/decisions/0018-flutter-3-44-workspace-unification.md`
- `docs/decisions/0017-core-as-brand-package.md`
- `.fvmrc`
- `pubspec.yaml`
- `examples/jaspr_basic_drag_drop/pubspec.yaml`

## Acceptance Criteria

- `.fvmrc` pins Flutter `3.44.2` (CI uses `flutter-version-file: .fvmrc`, so it
  follows automatically).
- `examples/jaspr_basic_drag_drop` declares `resolution: workspace`, drops its
  `dependency_overrides`, and is listed under `workspace:` in the root pubspec.
- `dart pub get` resolves the whole workspace with the Jaspr example as a member
  (single lockfile; `analyzer 10`, `test 1.31.0`, `matcher 0.12.19`).
- `fvm dart run melos run validate` passes on Flutter 3.44.2 — format, analyze
  for all members (including the Jaspr example), and all package/example tests.
- The Jaspr example builds: `dart run build_runner build` succeeds.
- Published packages keep `sdk >=3.5.0` / `flutter >=3.24.0` (no consumer impact).

## Design Notes

- The `experimental_member_use` warnings the newer analyzer surfaces in
  `examples/multi_container_sortable` (intentional experimental API showcase) are
  suppressed in that example's `analysis_options.yaml`.
- The Jaspr example has no `dart test`/`flutter test` suite (browser app), so
  workspace inclusion adds analyze coverage; its build is verified separately.

## Validation

`scripts/bin/harness-cli story update --id US-061 --unit 0 --integration 0 --e2e 0 --platform 1`

| Layer | Expected proof |
| --- | --- |
| Unit | Not required; no logic change. Existing suites run as regression under the platform gate on the new SDK. |
| Integration | Not required. |
| E2E | Not required. |
| Platform | `dart pub get` + `fvm dart run melos run validate` + Jaspr example `build_runner build` pass on Flutter 3.44.2. |

## Harness Delta

No Harness process change. Documents the toolchain bump that unifies the
workspace.

## Evidence

- Created 2026-06-17 after a non-destructive experiment under Flutter 3.44.2
  confirmed the workspace resolves with the Jaspr example included.

## Proof

- `fvm use 3.44.2` -> Dart 3.12.2 / Flutter 3.44.2.
- `dart pub get`: workspace resolved with `jaspr_basic_drag_drop` as a member;
  no override. Resolved `analyzer 10.2.0`, `test 1.31.0`, `matcher 0.12.19`,
  `test_api 0.7.11`, `jaspr_builder 0.23.1`.
- `fvm dart run melos run validate`: format clean, analyze clean for all 8
  members (incl. the Jaspr example), tests pass — engine 113, jaspr 22, Flutter
  adapter 96, and the kanban / multi-container / gallery examples.
- `dart run build_runner build` in `examples/jaspr_basic_drag_drop`: built 859
  outputs, no errors.
- Only follow-up: suppressed `experimental_member_use` in
  `examples/multi_container_sortable/analysis_options.yaml`.
