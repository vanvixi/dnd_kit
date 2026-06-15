# 0008 Main dnd_kit Package

Date: 2026-06-10

## Status

Accepted (naming amended by ADR 0013: the Flutter adapter is `dnd_kit_flutter`
and `dnd_kit` is a re-export umbrella; the layering decisions below still hold).

## Context

The original four-package layout used `dnd_kit` as an umbrella package and
`dnd_kit_flutter` as the real Flutter adapter. Before release, that split made
the developer-facing package choice ambiguous: application developers should
install and import one obvious package, `dnd_kit`.

The stable sortable widgets depend on the Flutter adapter layer. Keeping
sortable source in a separate package after renaming the adapter to `dnd_kit`
would either make the main package unable to export sortable APIs or create a
package dependency cycle.

## Decision

Use `dnd_kit` as the primary Flutter package. Rename the package previously
called `dnd_kit_flutter` into `packages/dnd_kit` and move stable sortable preset
source into that package as an internal source layer.

Keep `dnd_kit_core` as a separate pure Dart package. Remove
`dnd_kit_sortable` as a separate package before release because sortable is now
part of the main `dnd_kit` public API.

The canonical application import is:

```dart
import 'package:dnd_kit/dnd_kit.dart';
```

## Alternatives Considered

1. Keep `dnd_kit` as an umbrella package and publish `dnd_kit_flutter` as the
   main Flutter adapter. This preserves the original architecture but makes the
   release-facing package name less obvious.
2. Rename `dnd_kit_flutter` to `dnd_kit` and keep sortable in a separate package
   that depends on `dnd_kit`. This avoids the adapter name problem but leaves a
   mostly empty package whose only role is re-exporting the main package.
3. Keep a separate `package:dnd_kit/sortable.dart` sublibrary. This is useful
   only if developers are expected to import sortable separately; the release
   API is clearer with one canonical `package:dnd_kit/dnd_kit.dart` import.

## Consequences

Positive:

- Flutter app developers depend on one primary package, `dnd_kit`.
- The canonical import exposes drag/drop and stable sortable APIs together.
- `dnd_kit_core` remains pure Dart and independently testable.
- The package graph avoids cycles.
- Release package maintenance is smaller because there is no empty sortable
  wrapper package.

Tradeoffs:

- Sortable is now a source layer inside the main package rather than an inner
  implementation package.
- Historical docs and story evidence may mention the pre-release
  `dnd_kit_flutter` or `dnd_kit_sortable` package names.

## Follow-Up

- Keep release docs focused on `package:dnd_kit/dnd_kit.dart`.
