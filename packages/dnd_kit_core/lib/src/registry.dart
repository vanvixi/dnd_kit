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

  // Identity of the widget/state that currently owns each id. Owner-aware
  // registration lets a lazy list rebuild a keyed entry (new owner mounts
  // before the old owner is disposed) without tripping duplicate detection or
  // letting the departing owner remove the live registration.
  final Map<DndId, Object> _draggableOwners = <DndId, Object>{};
  final Map<DndId, Object> _droppableOwners = <DndId, Object>{};

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
  ///
  /// When [owner] is provided, registration is owner-aware and last-wins: a new
  /// owner can take over an id (e.g. a lazy list rebuilding a keyed entry)
  /// without tripping duplicate detection. When [owner] is omitted, duplicate
  /// ids are rejected in debug mode, preserving strict diagnostics for direct
  /// registry usage.
  void registerDraggable(DndDraggableRegistration registration, {Object? owner}) {
    if (owner == null) {
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
      return;
    }

    _draggables[registration.id] = registration;
    _draggableOwners[registration.id] = owner;
  }

  /// Registers [registration] as a droppable entry.
  ///
  /// See [registerDraggable] for the [owner] semantics.
  void registerDroppable(DndDroppableRegistration registration, {Object? owner}) {
    if (owner == null) {
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
      return;
    }

    _droppables[registration.id] = registration;
    _droppableOwners[registration.id] = owner;
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
  ///
  /// When [owner] is provided and a different owner currently holds [id]
  /// (a newer owner took over), the removal is skipped and `null` is returned so
  /// a departing owner cannot drop the live registration.
  DndDraggableRegistration? unregisterDraggable(DndId id, {Object? owner}) {
    if (owner != null) {
      final currentOwner = _draggableOwners[id];
      if (currentOwner != null && !identical(currentOwner, owner)) {
        return null;
      }
    }
    _draggableOwners.remove(id);
    return _draggables.remove(id);
  }

  /// Removes the droppable with [id].
  ///
  /// See [unregisterDraggable] for the [owner] semantics.
  DndDroppableRegistration? unregisterDroppable(DndId id, {Object? owner}) {
    if (owner != null) {
      final currentOwner = _droppableOwners[id];
      if (currentOwner != null && !identical(currentOwner, owner)) {
        return null;
      }
    }
    _droppableOwners.remove(id);
    return _droppables.remove(id);
  }

  /// Removes all registered entries.
  void clear() {
    _draggables.clear();
    _droppables.clear();
    _draggableOwners.clear();
    _droppableOwners.clear();
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
