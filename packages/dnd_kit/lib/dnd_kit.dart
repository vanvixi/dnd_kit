/// Flutter drag-and-drop toolkit with sortable presets.
///
/// This is the `dnd_kit` umbrella package. It re-exports the Flutter adapter
/// from `dnd_kit_flutter` (which in turn re-exports the pure Dart
/// `dnd_kit_core` engine), so applications can use the shorter import:
///
/// ```dart
/// import 'package:dnd_kit/dnd_kit.dart';
/// ```
///
/// The public API — [DndScope], [DndController], [DndDraggable],
/// [DndDroppable], [DndDragOverlay], auto-scroll helpers, and the stable
/// sortable APIs such as [SortableScope] and [SortableItem] — is identical to
/// importing `package:dnd_kit_flutter/dnd_kit_flutter.dart` directly.
library;

export 'package:dnd_kit_flutter/dnd_kit_flutter.dart';
