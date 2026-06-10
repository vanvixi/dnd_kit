import 'dart:collection';

import 'diagnostics.dart';
import 'id.dart';

/// Pure Dart metadata for a registered draggable.
final class DndDraggableRegistration {
  /// Creates draggable registration metadata.
  const DndDraggableRegistration({
    required this.id,
    this.disabled = false,
    this.data,
  });

  /// The stable draggable id.
  final DndId id;

  /// Whether dragging is disabled for this entry.
  final bool disabled;

  /// Optional application-owned data associated with this draggable.
  final Object? data;

  @override
  bool operator ==(Object other) {
    return other is DndDraggableRegistration &&
        other.id == id &&
        other.disabled == disabled &&
        other.data == data;
  }

  @override
  int get hashCode => Object.hash(id, disabled, data);

  @override
  String toString() {
    return 'DndDraggableRegistration(id: $id, disabled: $disabled, data: $data)';
  }
}

/// Pure Dart metadata for a registered droppable.
final class DndDroppableRegistration {
  /// Creates droppable registration metadata.
  const DndDroppableRegistration({
    required this.id,
    this.disabled = false,
    this.data,
  });

  /// The stable droppable id.
  final DndId id;

  /// Whether dropping is disabled for this entry.
  final bool disabled;

  /// Optional application-owned data associated with this droppable.
  final Object? data;

  @override
  bool operator ==(Object other) {
    return other is DndDroppableRegistration &&
        other.id == id &&
        other.disabled == disabled &&
        other.data == data;
  }

  @override
  int get hashCode => Object.hash(id, disabled, data);

  @override
  String toString() {
    return 'DndDroppableRegistration(id: $id, disabled: $disabled, data: $data)';
  }
}

/// Immutable view of the currently registered draggable and droppable entries.
final class DndRegistrySnapshot {
  /// Creates a registry snapshot.
  factory DndRegistrySnapshot({
    Map<DndId, DndDraggableRegistration> draggables = const <DndId, DndDraggableRegistration>{},
    Map<DndId, DndDroppableRegistration> droppables = const <DndId, DndDroppableRegistration>{},
  }) {
    return DndRegistrySnapshot._(
      UnmodifiableMapView(Map<DndId, DndDraggableRegistration>.of(draggables)),
      UnmodifiableMapView(Map<DndId, DndDroppableRegistration>.of(droppables)),
    );
  }

  const DndRegistrySnapshot._(this.draggables, this.droppables);

  /// Registered draggables keyed by stable id.
  final Map<DndId, DndDraggableRegistration> draggables;

  /// Registered droppables keyed by stable id.
  final Map<DndId, DndDroppableRegistration> droppables;

  /// An empty registry snapshot.
  static final empty = DndRegistrySnapshot();

  @override
  bool operator ==(Object other) {
    return other is DndRegistrySnapshot &&
        _mapEquals(other.draggables, draggables) &&
        _mapEquals(other.droppables, droppables);
  }

  @override
  int get hashCode => Object.hash(_mapHash(draggables), _mapHash(droppables));

  @override
  String toString() {
    return 'DndRegistrySnapshot(draggables: $draggables, droppables: $droppables)';
  }
}

/// Pure Dart registry for draggable and droppable entries.
final class DndRegistry {
  /// Creates a registry.
  DndRegistry({
    DndDiagnosticsConfig diagnosticsConfig = const DndDiagnosticsConfig(),
  }) : _diagnosticsConfig = diagnosticsConfig;

  final DndDiagnosticsConfig _diagnosticsConfig;
  final Map<DndId, DndDraggableRegistration> _draggables = <DndId, DndDraggableRegistration>{};
  final Map<DndId, DndDroppableRegistration> _droppables = <DndId, DndDroppableRegistration>{};

  /// Registered draggables keyed by stable id.
  Map<DndId, DndDraggableRegistration> get draggables {
    return UnmodifiableMapView(_draggables);
  }

  /// Registered droppables keyed by stable id.
  Map<DndId, DndDroppableRegistration> get droppables {
    return UnmodifiableMapView(_droppables);
  }

  /// The current immutable registry snapshot.
  DndRegistrySnapshot get snapshot {
    return DndRegistrySnapshot(
      draggables: _draggables,
      droppables: _droppables,
    );
  }

  /// Returns whether a draggable with [id] is registered.
  bool hasDraggable(DndId id) => _draggables.containsKey(id);

  /// Returns whether a droppable with [id] is registered.
  bool hasDroppable(DndId id) => _droppables.containsKey(id);

  /// Returns the registered draggable with [id], when one exists.
  DndDraggableRegistration? draggable(DndId id) => _draggables[id];

  /// Returns the registered droppable with [id], when one exists.
  DndDroppableRegistration? droppable(DndId id) => _droppables[id];

  /// Registers [registration] as a draggable entry.
  void registerDraggable(DndDraggableRegistration registration) {
    if (_draggables.containsKey(registration.id)) {
      _warnDuplicate(
        code: 'duplicate-draggable-id',
        id: registration.id,
        label: 'draggable',
      );
    }
    assert(
      !_draggables.containsKey(registration.id),
      'Duplicate draggable id registered: ${registration.id}.',
    );
    _draggables[registration.id] = registration;
  }

  /// Registers [registration] as a droppable entry.
  void registerDroppable(DndDroppableRegistration registration) {
    if (_droppables.containsKey(registration.id)) {
      _warnDuplicate(
        code: 'duplicate-droppable-id',
        id: registration.id,
        label: 'droppable',
      );
    }
    assert(
      !_droppables.containsKey(registration.id),
      'Duplicate droppable id registered: ${registration.id}.',
    );
    _droppables[registration.id] = registration;
  }

  /// Updates or inserts [registration] as a draggable entry.
  void updateDraggable(DndDraggableRegistration registration) {
    _draggables[registration.id] = registration;
  }

  /// Updates or inserts [registration] as a droppable entry.
  void updateDroppable(DndDroppableRegistration registration) {
    _droppables[registration.id] = registration;
  }

  /// Removes the draggable with [id].
  DndDraggableRegistration? unregisterDraggable(DndId id) {
    return _draggables.remove(id);
  }

  /// Removes the droppable with [id].
  DndDroppableRegistration? unregisterDroppable(DndId id) {
    return _droppables.remove(id);
  }

  /// Removes all registered entries.
  void clear() {
    _draggables.clear();
    _droppables.clear();
  }

  void _warnDuplicate({
    required String code,
    required DndId id,
    required String label,
  }) {
    _diagnosticsConfig.warn(
      DndWarning(
        code: code,
        id: id,
        message: 'Duplicate $label id registered: $id. '
            'Each active $label in the same DndRegistry must use a unique DndId.',
      ),
    );
  }
}

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }

  for (final entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
      return false;
    }
  }

  return true;
}

int _mapHash<V>(Map<DndId, V> map) {
  final entries = map.entries.toList()..sort((a, b) => a.key.value.compareTo(b.key.value));
  return Object.hashAll(entries.map((entry) => Object.hash(entry.key, entry.value)));
}
