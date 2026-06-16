@TestOn('browser')
library;

import 'dart:async';

import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart' as web;

void main() {
  group('DndDraggable browser input', () {
    testClient('starts from a handle and ignores the body when a handle exists', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);
      DndDragStartEvent? startEvent;
      DndDragEndEvent? endEvent;

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: DndDraggable(
            id: const DndId('task-1'),
            onDragStart: (event) => startEvent = event,
            onDragEnd: (event) => endEvent = event,
            child: div([
              DndDragHandle(
                child: button([Component.text('handle')]),
              ),
              section([Component.text('body')]),
            ]),
          ),
        ),
      );

      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerdown', x: 10, y: 10, pointerType: 'mouse', pointerId: 1),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointermove', x: 40, y: 10, pointerType: 'mouse', pointerId: 1),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerup', x: 40, y: 10, pointerType: 'mouse', pointerId: 1),
      );

      expect(startEvent?.activeId, const DndId('task-1'));
      expect(startEvent?.inputKind, DndInputKind.mouse);
      expect(endEvent?.activeId, const DndId('task-1'));
      expect(controller.state, const DndIdle());

      startEvent = null;
      endEvent = null;

      await tester.dispatchEvent(
        find.tag('section'),
        _pointerEvent('pointerdown', x: 80, y: 80, pointerType: 'mouse', pointerId: 2),
      );
      await tester.dispatchEvent(
        find.tag('section'),
        _pointerEvent('pointermove', x: 120, y: 80, pointerType: 'mouse', pointerId: 2),
      );
      await tester.dispatchEvent(
        find.tag('section'),
        _pointerEvent('pointerup', x: 120, y: 80, pointerType: 'mouse', pointerId: 2),
      );

      expect(startEvent, isNull);
      expect(endEvent, isNull);
      expect(controller.state, const DndIdle());
    });

    testClient('starts from a handle when the browser only emits mouse events', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);
      DndDragStartEvent? startEvent;
      final moveEvents = <DndDragMoveEvent>[];
      DndDragEndEvent? endEvent;

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: DndDraggable(
            id: const DndId('task-1'),
            onDragStart: (event) => startEvent = event,
            onDragMove: moveEvents.add,
            onDragEnd: (event) => endEvent = event,
            child: div([
              DndDragHandle(
                child: button([Component.text('handle')]),
              ),
            ]),
          ),
        ),
      );

      await tester.dispatchEvent(
        find.tag('button'),
        _mouseEvent('mousedown', x: 10, y: 10, buttons: 1),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _mouseEvent('mousemove', x: 40, y: 10, buttons: 1),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _mouseEvent('mouseup', x: 40, y: 10, buttons: 0),
      );

      expect(startEvent?.activeId, const DndId('task-1'));
      expect(startEvent?.inputKind, DndInputKind.mouse);
      expect(moveEvents, isNotEmpty);
      expect(endEvent?.activeId, const DndId('task-1'));
      expect(endEvent?.inputKind, DndInputKind.mouse);
      expect(controller.state, const DndIdle());
    });

    testClient('touch waits for the default hold while mouse starts immediately', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);
      DndDragStartEvent? startEvent;
      DndDragCancelEvent? cancelEvent;

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: DndDraggable(
            id: const DndId('task-1'),
            onDragStart: (event) => startEvent = event,
            onDragCancel: (event) => cancelEvent = event,
            child: section([Component.text('body')]),
          ),
        ),
      );

      await tester.dispatchEvent(
        find.tag('section'),
        _pointerEvent('pointerdown', x: 10, y: 10, pointerType: 'touch', pointerId: 3),
      );
      await tester.dispatchEvent(
        find.tag('section'),
        _pointerEvent('pointermove', x: 30, y: 10, pointerType: 'touch', pointerId: 3),
      );
      await tester.dispatchEvent(
        find.tag('section'),
        _pointerEvent('pointerup', x: 30, y: 10, pointerType: 'touch', pointerId: 3),
      );

      expect(startEvent, isNull);
      expect(cancelEvent?.activeId, const DndId('task-1'));
      expect(cancelEvent?.reason, DndCancelReason.sensor);
      expect(controller.state, const DndIdle());

      startEvent = null;
      cancelEvent = null;

      await tester.dispatchEvent(
        find.tag('section'),
        _pointerEvent('pointerdown', x: 10, y: 10, pointerType: 'touch', pointerId: 4),
      );
      await Future<void>.delayed(const Duration(milliseconds: 550));
      await tester.dispatchEvent(
        find.tag('section'),
        _pointerEvent('pointerup', x: 10, y: 10, pointerType: 'touch', pointerId: 4),
      );

      expect(startEvent?.activeId, const DndId('task-1'));
      expect(startEvent?.inputKind, DndInputKind.touch);
      expect(controller.state, const DndIdle());
    });

    testClient('supports keyboard pickup, movement, and drop from a handle', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);
      DndDragStartEvent? startEvent;
      final moveEvents = <DndDragMoveEvent>[];
      DndDragEndEvent? endEvent;

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: DndDraggable(
            id: const DndId('task-1'),
            keyboardDragStep: 10,
            onDragStart: (event) => startEvent = event,
            onDragMove: moveEvents.add,
            onDragEnd: (event) => endEvent = event,
            child: div([
              DndDragHandle(
                child: button([Component.text('handle')]),
              ),
            ]),
          ),
        ),
      );

      await tester.dispatchEvent(
        find.tag('button'),
        _keyboardEvent('keydown', 'Enter'),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _keyboardEvent('keydown', 'ArrowRight'),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _keyboardEvent('keydown', 'ArrowDown'),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _keyboardEvent('keydown', 'Enter'),
      );

      expect(startEvent?.activeId, const DndId('task-1'));
      expect(startEvent?.inputKind, DndInputKind.keyboard);
      expect(moveEvents, hasLength(2));
      expect(moveEvents.last.session.delta, const DndPoint(10, 10));
      expect(endEvent?.activeId, const DndId('task-1'));
      expect(endEvent?.inputKind, DndInputKind.keyboard);
      expect(controller.state, const DndIdle());
    });

    testClient('surfaces duplicate draggable diagnostics after reconciliation', (tester) async {
      final warnings = <DndWarning>[];
      final controller = DndController(
        diagnosticsConfig: DndDiagnosticsConfig(onWarning: warnings.add),
      );
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: div([
            DndDraggable(
              key: const ValueKey('first'),
              id: const DndId('task-1'),
              child: button([Component.text('first')]),
            ),
            DndDraggable(
              key: const ValueKey('second'),
              id: const DndId('task-1'),
              child: section([Component.text('second')]),
            ),
          ]),
        ),
      );

      await Future<void>.delayed(Duration.zero);

      expect(
        warnings,
        [
          isA<DndWarning>()
              .having((warning) => warning.code, 'code', 'duplicate-draggable-id')
              .having((warning) => warning.id, 'id', const DndId('task-1'))
              .having((warning) => warning.message, 'message', contains('after reconciliation')),
        ],
      );
    });

    testClient('does not warn for a draggable owner handoff that settles in one frame',
        (tester) async {
      final warnings = <DndWarning>[];
      final controller = DndController(
        diagnosticsConfig: DndDiagnosticsConfig(onWarning: warnings.add),
      );
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: _BrowserDraggableOwnerHandoff(),
        ),
      );

      await tester.click(find.tag('button'));
      await Future<void>.delayed(Duration.zero);

      expect(warnings, isEmpty);
      expect(controller.registry.hasDraggable(const DndId('task-1')), isTrue);
    });

    testClient('applies controller modifiers during pointer dragging', (tester) async {
      final controller = DndController(
        modifiers: const <DndModifier>[
          DndModifiers.restrictToHorizontalAxis,
        ],
      );
      addTearDown(controller.dispose);
      final moveEvents = <DndDragMoveEvent>[];
      DndDragEndEvent? endEvent;

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: div([
            div(
              styles: Styles(
                position: Position.fixed(left: 100.px, top: 0.px),
              ),
              [
                DndDroppable(
                  id: DndId('column-1'),
                  child: article(
                    styles: Styles(
                      width: 80.px,
                      height: 80.px,
                    ),
                    [],
                  ),
                ),
              ],
            ),
            div(
              styles: Styles(
                position: Position.fixed(left: 0.px, top: 0.px),
              ),
              [
                DndDraggable(
                  id: const DndId('task-1'),
                  onDragMove: moveEvents.add,
                  onDragEnd: (event) => endEvent = event,
                  child: section(
                    styles: Styles(
                      width: 40.px,
                      height: 40.px,
                    ),
                    const [Component.text('card')],
                  ),
                ),
              ],
            ),
          ]),
        ),
      );

      await tester.dispatchEvent(
        find.tag('section'),
        _pointerEvent('pointerdown', x: 20, y: 20, pointerType: 'mouse', pointerId: 5),
      );
      await tester.dispatchEvent(
        find.tag('section'),
        _pointerEvent('pointermove', x: 120, y: 120, pointerType: 'mouse', pointerId: 5),
      );

      expect(moveEvents, isNotEmpty);
      expect(moveEvents.last.currentPointer, const DndPoint(120, 20));
      expect(controller.overId, const DndId('column-1'));

      await tester.dispatchEvent(
        find.tag('section'),
        _pointerEvent('pointerup', x: 120, y: 120, pointerType: 'mouse', pointerId: 5),
      );

      expect(endEvent?.currentPointer, const DndPoint(120, 20));
      expect(endEvent?.overId, const DndId('column-1'));
      expect(controller.state, const DndIdle());
    });

    testClient('keeps handle dragging alive after the pointer leaves the draggable subtree',
        (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);
      DndDragStartEvent? startEvent;
      final moveEvents = <DndDragMoveEvent>[];
      DndDragEndEvent? endEvent;

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: div([
            div(
              styles: Styles(
                position: Position.fixed(left: 240.px, top: 0.px),
              ),
              [
                DndDroppable(
                  id: DndId('column-2'),
                  child: article(
                    styles: Styles(
                      width: 120.px,
                      height: 120.px,
                    ),
                    const [Component.text('drop zone')],
                  ),
                ),
              ],
            ),
            div(
              styles: Styles(
                position: Position.fixed(left: 0.px, top: 0.px),
              ),
              [
                DndDraggable(
                  id: const DndId('task-1'),
                  onDragStart: (event) => startEvent = event,
                  onDragMove: moveEvents.add,
                  onDragEnd: (event) => endEvent = event,
                  child: div([
                    DndDragHandle(
                      child: button([Component.text('handle')]),
                    ),
                  ]),
                ),
              ],
            ),
          ]),
        ),
      );

      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerdown', x: 20, y: 20, pointerType: 'mouse', pointerId: 6),
      );
      await tester.dispatchEvent(
        find.tag('article'),
        _pointerEvent('pointermove', x: 280, y: 20, pointerType: 'mouse', pointerId: 6),
      );
      expect(controller.overId, const DndId('column-2'));
      await tester.dispatchEvent(
        find.tag('article'),
        _pointerEvent('pointerup', x: 280, y: 20, pointerType: 'mouse', pointerId: 6),
      );

      expect(startEvent?.activeId, const DndId('task-1'));
      expect(moveEvents, isNotEmpty);
      expect(moveEvents.last.currentPointer, const DndPoint(280, 20));
      expect(endEvent?.overId, const DndId('column-2'));
      expect(controller.state, const DndIdle());
    });

    testClient('applies controller modifiers during keyboard dragging', (tester) async {
      final controller = DndController(
        modifiers: const <DndModifier>[
          DndModifiers.restrictToVerticalAxis,
        ],
      );
      addTearDown(controller.dispose);
      DndDragStartEvent? startEvent;
      final moveEvents = <DndDragMoveEvent>[];
      DndDragEndEvent? endEvent;

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: DndDraggable(
            id: const DndId('task-1'),
            keyboardDragStep: 10,
            onDragStart: (event) => startEvent = event,
            onDragMove: moveEvents.add,
            onDragEnd: (event) => endEvent = event,
            child: div([
              DndDragHandle(
                child: button([Component.text('handle')]),
              ),
            ]),
          ),
        ),
      );

      await tester.dispatchEvent(
        find.tag('button'),
        _keyboardEvent('keydown', 'Enter'),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _keyboardEvent('keydown', 'ArrowRight'),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _keyboardEvent('keydown', 'ArrowDown'),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _keyboardEvent('keydown', 'Enter'),
      );

      final initialPointer = startEvent!.initialPointer;
      expect(
        moveEvents.map((event) => event.currentPointer),
        <DndPoint>[
          initialPointer,
          initialPointer.translate(const DndPoint(0, 10)),
        ],
      );
      expect(endEvent?.currentPointer, initialPointer.translate(const DndPoint(0, 10)));
      expect(controller.state, const DndIdle());
    });

    testClient(
        'keeps handle dragging working when an ancestor rebuilds from controller notifications',
        (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);
      DndDragStartEvent? startEvent;
      final moveEvents = <DndDragMoveEvent>[];
      DndDragEndEvent? endEvent;

      tester.pumpComponent(
        _ControllerListeningShell(
          controller: controller,
          child: DndDraggable(
            id: const DndId('task-1'),
            onDragStart: (event) => startEvent = event,
            onDragMove: moveEvents.add,
            onDragEnd: (event) => endEvent = event,
            child: div([
              DndDragHandle(
                child: button(
                  attributes: const <String, String>{'id': 'handle-probe'},
                  const [Component.text('handle')],
                ),
              ),
            ]),
          ),
        ),
      );

      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerdown', x: 10, y: 10, pointerType: 'mouse', pointerId: 9),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointermove', x: 40, y: 10, pointerType: 'mouse', pointerId: 9),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerup', x: 40, y: 10, pointerType: 'mouse', pointerId: 9),
      );

      expect(startEvent?.activeId, const DndId('task-1'));
      expect(moveEvents, isNotEmpty);
      expect(endEvent?.activeId, const DndId('task-1'));
      expect(controller.state, const DndIdle());
    });
  });
}

class _ControllerListeningShell extends StatefulComponent {
  const _ControllerListeningShell({
    required this.controller,
    required this.child,
  });

  final DndController controller;
  final Component child;

  @override
  State<_ControllerListeningShell> createState() => _ControllerListeningShellState();
}

class _ControllerListeningShellState extends State<_ControllerListeningShell> {
  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    component.controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    component.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return DndScope(
      controller: component.controller,
      child: component.child,
    );
  }
}

class _BrowserDraggableOwnerHandoff extends StatefulComponent {
  @override
  State<_BrowserDraggableOwnerHandoff> createState() => _BrowserDraggableOwnerHandoffState();
}

class _BrowserDraggableOwnerHandoffState extends State<_BrowserDraggableOwnerHandoff> {
  int _generation = 0;

  @override
  Component build(BuildContext context) {
    return div([
      button(onClick: () => setState(() => _generation += 1), [Component.text('swap')]),
      DndDraggable(
        key: ValueKey('generation-$_generation'),
        id: const DndId('task-1'),
        child: article([Component.text('item')]),
      ),
    ]);
  }
}

web.PointerEvent _pointerEvent(
  String type, {
  required int x,
  required int y,
  required String pointerType,
  required int pointerId,
}) {
  return web.PointerEvent(
    type,
    web.PointerEventInit(
      bubbles: true,
      cancelable: true,
      composed: true,
      clientX: x,
      clientY: y,
      pointerType: pointerType,
      pointerId: pointerId,
    ),
  );
}

web.KeyboardEvent _keyboardEvent(String type, String key) {
  return web.KeyboardEvent(
    type,
    web.KeyboardEventInit(
      bubbles: true,
      cancelable: true,
      composed: true,
      key: key,
    ),
  );
}

web.MouseEvent _mouseEvent(
  String type, {
  required int x,
  required int y,
  required int buttons,
}) {
  return web.MouseEvent(
    type,
    web.MouseEventInit(
      bubbles: true,
      cancelable: true,
      composed: true,
      clientX: x,
      clientY: y,
      buttons: buttons,
      button: 0,
    ),
  );
}
