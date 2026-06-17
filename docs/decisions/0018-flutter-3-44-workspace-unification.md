# 0018 Flutter 3.44.2 Unifies The Workspace

Date: 2026-06-17

## Status

Accepted

## Context

After US-060, `examples/jaspr_basic_drag_drop` was the only package outside the
pub workspace. It used `dependency_overrides: dnd_kit: path:` to pin the engine,
because it could not join the workspace: Flutter 3.38.5's `flutter_test` depends
on exactly `matcher 0.12.17` and `test_api 0.7.7`, and `matcher` resolves to a
single version across a workspace. That pin forced the `test` package (a dev
dependency of `dnd_kit` and `dnd_kit_jaspr`) down to a version requiring
`analyzer <9`, which conflicts with `jaspr_builder`'s `analyzer ^10`.

Flutter 3.44.2 (stable, 2026-06-11) relaxes `flutter_test` to `matcher 0.12.19`
/ `test_api 0.7.11`. That allows `test 1.31.0` (which permits `analyzer <13`) and
`analyzer 10`, which `jaspr_builder ^0.23.1` accepts. A single workspace
resolution is therefore possible.

## Decision

Pin the development Flutter SDK to 3.44.2 (`.fvmrc`; CI follows via
`flutter-version-file: .fvmrc`) and make `examples/jaspr_basic_drag_drop` a
workspace member: add `resolution: workspace`, remove its
`dependency_overrides`, and list it under `workspace:` in the root pubspec.

This supersedes the override note in ADR 0017's consequences/follow-up: the
Jaspr example no longer needs a `dependency_overrides` and is now covered by
`melos run analyze`.

Published packages keep their consumer-facing constraints (`sdk >=3.5.0`,
`flutter >=3.24.0`); only the development toolchain pin moves. As today, a
package may declare `sdk >=3.5.0` while the dev-time resolution pulls
`analyzer 10` (which needs Dart 3.9+), because `pub get` resolves against the
actual installed SDK.

## Alternatives Considered

1. Keep the Jaspr example standalone with the override. Rejected once 3.44.2 made
   unification possible: the override was a workaround, and standalone meant the
   example was excluded from `melos run analyze`/`validate`.
2. Stay on Flutter 3.38.5. Rejected: it blocks unification and forgoes ~6 months
   of Flutter fixes; the upgrade validated cleanly.

## Consequences

Positive:

- One workspace, one lockfile; the Jaspr example is analyzed in the gate.
- The override workaround is gone.
- Repository runs on current stable Flutter.

Tradeoffs:

- The newer analyzer surfaces `experimental_member_use` warnings on intentional
  experimental-API use; suppressed per-example in `analysis_options.yaml`.
- Contributors must use Flutter 3.44.2 (enforced via `.fvmrc`).
