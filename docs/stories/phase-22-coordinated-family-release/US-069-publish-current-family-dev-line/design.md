# Design

## Domain Model

The release unit is the current three-package family:

- `dnd_kit`: pure Dart engine and dependency root.
- `dnd_kit_flutter`: Flutter adapter that depends on the engine.
- `dnd_kit_jaspr`: Jaspr adapter that depends on the engine.

Versioning promotes the `0.3.0-dev` line to a coordinated stable `0.3.0`: all
three packages publish `0.3.0` together. Because the engine contract changed,
both adapters repoint to the stable engine release (`dnd_kit: ^0.3.0`) before
publication.

## Application Flow

1. Confirm the published baselines on pub.dev.
2. Move each package's unreleased changelog content into the next publishable
   version section.
3. Bump `pubspec.yaml` versions and dependency constraints.
4. Run workspace dependency resolution and the full validation lane.
5. Run `dart pub publish --dry-run` in dependency order.
6. Record the exact maintainer-run publish order and any remaining human step.

## Interface Contract

Public package contracts remain additive:

- `dnd_kit` publishes `DndScrollAxis` and axis-aware
  `dndAutoScrollVelocity(...)`.
- `dnd_kit_flutter` publishes horizontal support on `DndAutoScroll` and
  `DndAutoScrollController`.
- `dnd_kit_jaspr` publishes horizontal support on `DndAutoScroll` and the
  overlay controller-rebind fix.

No new route, CLI, or runtime API beyond those already-implemented contracts is
introduced by this release story.

## Data Model

No application data model changes. Durable Harness state adds one intake row,
one story row, proof booleans, and a trace for the release-preparation work.

## UI / Platform Impact

Platform impact is package-consumer facing:

- Flutter users can consume the horizontal auto-scroll release from
  `dnd_kit_flutter`.
- Jaspr users can consume both horizontal auto-scroll and the overlay rebind
  fix from `dnd_kit_jaspr`.
- Pure Dart consumers and adapter authors can consume the axis-aware shared
  auto-scroll engine contract from `dnd_kit`.

## Observability

Proof is release-oriented rather than runtime-observability-oriented:

- full workspace validation (`melos run validate`);
- three publish dry-runs in dependency order;
- story + trace records capturing the exact version/order.

## Alternatives Considered

1. Publish only the changed adapters without a new engine release.
   Rejected because both adapters now rely on the new axis-aware engine
   contract, so the engine must publish first.
2. Stay on an incremental dev bump (`0.3.0-dev.2` / `0.3.0-dev.3`).
   Rejected because the axis-aware contract is now adopted by both adapters and
   the API has soaked through the examples, so the maintainer chose to close the
   `0.3.0` API and publish a stable release. As a `0.x` version this still
   leaves room for a later breaking `0.4.0`.
