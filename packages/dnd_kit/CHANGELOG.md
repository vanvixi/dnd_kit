# Changelog

## 0.1.0-dev.2

- `dnd_kit` is now a thin umbrella package that re-exports `dnd_kit_flutter`.
  The Flutter adapter source moved to the `dnd_kit_flutter` package so the
  toolkit can grow additional framework adapters (for example a future
  `dnd_kit_jaspr`) on top of the shared `dnd_kit_core` engine.
- No public API changes: `package:dnd_kit/dnd_kit.dart` continues to export the
  same widgets, controllers, sensors, overlay, auto-scroll, and sortable APIs.
