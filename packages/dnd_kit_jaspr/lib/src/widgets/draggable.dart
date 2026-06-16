import 'package:dnd_kit_core/dnd_kit_core.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:universal_web/web.dart' as web;

import '../scope/controller.dart';
import '../scope/scope.dart';

/// A drag source for the Jaspr adapter.
///
/// `DndDraggable` registers a stable [id] with the enclosing [DndScope]'s
/// controller, measures its DOM element on activation, and drives the shared
/// [DndPointerSensor] from browser pointer events. It uses pointer capture and
/// element-level pointer events (wired through Jaspr's `events:` map), so it
/// needs no document-level listeners and stays safe to import in any Jaspr
/// render mode — all DOM access is guarded by `kIsWeb`.
///
/// During an active drag the element follows the pointer via a CSS transform.
/// A dedicated drag overlay arrives in a later story.
class DndDraggable extends StatefulComponent {
  /// Creates a draggable wrapping [child].
  const DndDraggable({
    required this.id,
    required this.child,
    this.data,
    this.disabled = false,
    this.constraint = DndSensorActivationConstraint.none,
    this.onDragStart,
    this.onDragMove,
    this.onDragEnd,
    this.onDragCancel,
    super.key,
  });

  /// The stable draggable id registered with the controller.
  final DndId id;

  /// The visual content of the draggable.
  final Component child;

  /// Optional application-owned data associated with the draggable.
  final Object? data;

  /// Whether dragging is disabled.
  final bool disabled;

  /// The activation constraint applied before a drag session starts.
  final DndSensorActivationConstraint constraint;

  /// Called when a drag session starts.
  final DndDragStartCallback? onDragStart;

  /// Called when the active drag moves.
  final DndDragMoveCallback? onDragMove;

  /// Called when the active drag ends.
  final DndDragEndCallback? onDragEnd;

  /// Called when a pending or active drag is cancelled.
  final DndDragCancelCallback? onDragCancel;

  @override
  State<DndDraggable> createState() => _DndDraggableState();
}

class _DndDraggableState extends State<DndDraggable> {
  final GlobalNodeKey<web.HTMLElement> _nodeKey = GlobalNodeKey<web.HTMLElement>();

  DndController? _controller;
  DndDraggableRegistration? _registration;
  DndPointerSensor? _sensor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = DndScope.of(context);
    if (!identical(_controller, controller)) {
      _unregister();
      _controller = controller;
      _register();
    }
  }

  @override
  void didUpdateComponent(DndDraggable oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.id != component.id ||
        oldComponent.disabled != component.disabled ||
        oldComponent.data != component.data) {
      _unregister();
      _register();
    }
  }

  @override
  void dispose() {
    _sensor?.dispose();
    _unregister();
    super.dispose();
  }

  void _register() {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final registration = DndDraggableRegistration(
      id: component.id,
      disabled: component.disabled,
      data: component.data,
    );
    _registration = registration;
    controller.registry.registerDraggable(registration, owner: this);
  }

  void _unregister() {
    final controller = _controller;
    final registration = _registration;
    if (controller != null && registration != null) {
      controller.registry.unregisterDraggable(registration.id, owner: this);
    }
    _registration = null;
  }

  DndRect? _measure() {
    final node = _nodeKey.currentNode;
    if (node == null) {
      return null;
    }
    final rect = node.getBoundingClientRect();
    return DndRect(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
    );
  }

  void _handlePointerDown(web.Event event) {
    if (component.disabled || !kIsWeb) {
      return;
    }
    final controller = _controller;
    if (controller == null || !controller.isIdle) {
      return;
    }
    final pointer = event as web.PointerEvent;
    _nodeKey.currentNode?.setPointerCapture(pointer.pointerId);

    final sensor = DndPointerSensor(
      runtime: controller.runtime,
      activeRect: _measure(),
      constraint: component.constraint,
      onDragStart: component.onDragStart,
      onDragMove: (moveEvent) {
        _applyTransform(moveEvent.transform);
        component.onDragMove?.call(moveEvent);
      },
      onDragEnd: (endEvent) {
        _endGesture();
        component.onDragEnd?.call(endEvent);
      },
      onDragCancel: (cancelEvent) {
        _endGesture();
        component.onDragCancel?.call(cancelEvent);
      },
    );
    _sensor = sensor;
    sensor.start(
      DndSensorActivationEvent(
        activeId: component.id,
        position: DndPoint(pointer.clientX.toDouble(), pointer.clientY.toDouble()),
        inputKind: _inputKindFor(pointer),
      ),
    );
  }

  void _handlePointerMove(web.Event event) {
    final pointer = event as web.PointerEvent;
    _sensor?.move(DndPoint(pointer.clientX.toDouble(), pointer.clientY.toDouble()));
  }

  void _handlePointerUp(web.Event event) {
    _sensor?.end();
  }

  void _handlePointerCancel(web.Event event) {
    _sensor?.cancel();
  }

  void _endGesture() {
    _applyTransform(DndTransform.identity);
    _sensor = null;
  }

  void _applyTransform(DndTransform transform) {
    final node = _nodeKey.currentNode;
    if (node == null) {
      return;
    }
    node.style.transform =
        transform.isIdentity ? '' : 'translate(${transform.offset.x}px, ${transform.offset.y}px)';
  }

  DndInputKind _inputKindFor(web.PointerEvent event) {
    return switch (event.pointerType) {
      'mouse' => DndInputKind.mouse,
      'touch' || 'pen' => DndInputKind.touch,
      _ => DndInputKind.pointer,
    };
  }

  @override
  Component build(BuildContext context) {
    return div(
      key: _nodeKey,
      events: component.disabled
          ? null
          : <String, void Function(web.Event)>{
              'pointerdown': _handlePointerDown,
              'pointermove': _handlePointerMove,
              'pointerup': _handlePointerUp,
              'pointercancel': _handlePointerCancel,
            },
      [component.child],
    );
  }
}
