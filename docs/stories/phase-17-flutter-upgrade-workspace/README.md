# Phase 17 — Flutter Upgrade & Workspace Unification

This phase upgrades the development Flutter SDK to 3.44.2 and folds the
standalone Jaspr example (`examples/jaspr_basic_drag_drop`) into the pub
workspace, removing the `dependency_overrides` workaround it needed while it
lived outside the workspace.

## Why now

After US-060, `jaspr_basic_drag_drop` was the only example outside the workspace.
It could not join because Flutter 3.38.5's `flutter_test` pinned `matcher 0.12.17`
/ `test_api 0.7.7`, which forced the workspace's `test`/`analyzer` below the
`analyzer ^10` that `jaspr_builder` requires. Flutter 3.44.2 relaxes the pin to
`matcher 0.12.19` / `test_api 0.7.11`, allowing `test 1.31.0` and `analyzer 10`,
which `jaspr_builder` accepts — so a single workspace resolution is now possible.

## Delivery Sequence

| Story | Scope | Decision |
| --- | --- | --- |
| **US-061** | Pin dev Flutter to 3.44.2; add `jaspr_basic_drag_drop` to the workspace; drop its override; keep it covered by `melos run analyze` | ADR 0018 |

## Validation Ladder

- Workspace resolves with the Jaspr example as a member: `dart pub get`.
- Full gate on 3.44.2: `fvm dart run melos run validate` (format, analyze all
  members incl. the Jaspr example, core/jaspr `dart test`, Flutter adapter +
  example `flutter test`).
- Jaspr example browser build: `dart run build_runner build` inside the example.
- No consumer-facing change: published packages keep `sdk >=3.5.0` /
  `flutter >=3.24.0`; only the dev toolchain pin moves.
