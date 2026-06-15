# 0013 Multi-Framework Package Naming

Date: 2026-06-15

## Status

Accepted

## Context

ADR 0008 made `dnd_kit` the primary Flutter package, renaming the Flutter
adapter from `dnd_kit_flutter` into `packages/dnd_kit`. That decision optimized
for a single, obvious Flutter package name before the first release.

The project now intends to support a second framework adapter (a Jaspr/DOM
adapter, `dnd_kit_jaspr`) built on the same framework-agnostic `dnd_kit_core`
engine. With the Flutter adapter occupying the bare `dnd_kit` name, the family
would be asymmetric: `dnd_kit` (Flutter) alongside `dnd_kit_jaspr` (Jaspr)
hides the fact that both are peer adapters over a shared core, and makes it
unclear where Flutter-specific code lives.

The Flutter package is published only at `0.1.0-dev`, so the cost of renaming
now is low compared to renaming after a stable release.

## Decision

Reintroduce `dnd_kit_flutter` as the name of the Flutter adapter package, and
keep `dnd_kit` as a thin umbrella that re-exports `dnd_kit_flutter`.

The package family becomes:

- `dnd_kit_core` — pure Dart engine shared by every adapter.
- `dnd_kit_flutter` — Flutter adapter (widgets, sensors, measuring, overlay,
  auto-scroll, sortable presets).
- `dnd_kit` — umbrella that re-exports `dnd_kit_flutter` under the brand name.
- `dnd_kit_jaspr` — future Jaspr adapter over `dnd_kit_core` (separate story).

The canonical Flutter application import `package:dnd_kit/dnd_kit.dart` keeps
working through the umbrella, so this is not a breaking change for current
users. Applications may also import `package:dnd_kit_flutter/dnd_kit_flutter.dart`
directly.

The rename preserves Git history: the adapter source and tests were moved with
rename-aware operations (`git mv`), not deleted and recreated.

This amends the naming half of ADR 0008. The dependency and layering goals of
ADR 0008 still hold: `dnd_kit_core` stays pure Dart, sortable stays a source
layer inside the Flutter adapter, and the package graph stays acyclic.

## Alternatives Considered

1. Keep `dnd_kit` as the Flutter adapter and add `dnd_kit_jaspr` beside it. This
   preserves the ADR 0008 name but produces an asymmetric family and hides
   where Flutter code lives.
2. Make `dnd_kit` an empty/meta package with no umbrella export. This loses the
   non-breaking short import that current Flutter users already depend on.
3. Use a `flutter_dnd_kit` prefix instead of a `dnd_kit_flutter` suffix. This
   breaks the `dnd_kit_*` grouping the family already uses (`dnd_kit_core`),
   hurting discoverability on pub.dev.

## Consequences

Positive:

- The family is symmetric: `core` + per-framework adapters, ready for
  `dnd_kit_jaspr` without further renames.
- The Flutter adapter has an honest, framework-specific name.
- `package:dnd_kit/dnd_kit.dart` stays valid, so existing users are not broken.
- The short brand name `dnd_kit` stays owned by the project on pub.dev.

Tradeoffs:

- One more published package (the umbrella) to version and release.
- Release ordering: `dnd_kit_flutter` must be published before the `dnd_kit`
  umbrella that depends on it.
- Historical docs and story evidence still mention the interim period when
  `dnd_kit` was the Flutter adapter itself.

## Follow-Up

- Publish `dnd_kit_flutter` before the `dnd_kit` umbrella when releasing.
- Track the Jaspr adapter (`dnd_kit_jaspr`) as a separate story/initiative built
  on `dnd_kit_core`.
