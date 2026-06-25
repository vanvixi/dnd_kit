import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../ui.dart';

/// Collision detection: the active [DndCollisionDetector] decides which target
/// wins when the dragged card overlaps several drop zones. The detector is
/// fixed per controller, so switching one rebuilds the controller.
class CollisionDemo extends StatefulComponent {
  const CollisionDemo({super.key});

  @override
  State<CollisionDemo> createState() => _CollisionDemoState();
}

enum _Detector { closestCenter, rectIntersection, pointerWithin }

const _zoneIds = <String>['zone-a', 'zone-b', 'zone-c'];

class _CollisionDemoState extends State<CollisionDemo> {
  _Detector _detector = _Detector.closestCenter;
  DndController? _controller;

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _disposeController() {
    _controller
      ?..removeListener(_handleChanged)
      ..dispose();
    _controller = null;
  }

  DndController get _activeController {
    return _controller ??= DndController(
      collisionDetector: _detectorFor(_detector),
    )..addListener(_handleChanged);
  }

  void _handleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _select(_Detector detector) {
    if (detector == _detector) {
      return;
    }
    setState(() {
      _detector = detector;
      _disposeController();
    });
  }

  DndCollisionDetector _detectorFor(_Detector detector) {
    return switch (detector) {
      _Detector.closestCenter => DndCollisionDetectors.closestCenter,
      _Detector.rectIntersection => DndCollisionDetectors.rectIntersection,
      _Detector.pointerWithin => DndCollisionDetectors.pointerWithin,
    };
  }

  @override
  Component build(BuildContext context) {
    final controller = _activeController;
    final over = controller.overId?.value;

    return DndScope(
      key: ValueKey<_Detector>(_detector),
      controller: controller,
      child: DemoPanel(
        children: [
          const DemoIntro(
            title: 'Collision detection',
            description:
                'Drag the card across the three zones. The active detector — '
                'shared math in dnd_kit — decides which zone is "over". '
                'pointerWithin only hits a zone the pointer is inside; '
                'closestCenter always picks the nearest centre.',
          ),
          div(
            styles: Styles(display: .flex, flexWrap: .wrap, gap: .all(10.px)),
            [
              _detectorButton(_Detector.closestCenter, 'closestCenter'),
              _detectorButton(_Detector.rectIntersection, 'rectIntersection'),
              _detectorButton(_Detector.pointerWithin, 'pointerWithin'),
            ],
          ),
          StatusBar(
            children: [
              Pill(label: 'Detector', value: _detectorLabel(_detector)),
              Pill(label: 'Over', value: over ?? 'none'),
            ],
          ),
          div(
            styles: Styles(
              display: .flex,
              gap: .all(16.px),
              justifyContent: .spaceBetween,
            ),
            [for (final id in _zoneIds) _zone(id)],
          ),
          div(
            styles: Styles(
              display: .flex,
              position: .relative(),
              height: 150.px,
              justifyContent: .center,
              alignItems: .center,
            ),
            [
              DndDraggable(
                id: const DndId('collision-card'),
                label: 'Collision test card',
                description:
                    'Press space to pick up, arrow keys to move over a zone, '
                    'space to drop, escape to cancel.',
                child: _card('Drag me over a zone', cCardBg),
              ),
              DndDragOverlay(
                builder: (context, overlayDetails) =>
                    _card('Resolving target…', cAccent, light: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Component _zone(String id) {
    return DndDroppable(
      id: DndId(id),
      builder: (context, dropState, child) {
        final isOver = dropState.isOver;
        return div(
          styles: Styles(
            display: .flex,
            flex: Flex(grow: 1, shrink: 1, basis: .auto),
            height: 120.px,
            border: .all(color: isOver ? cAccent : cBorder, width: 2.px),
            radius: .circular(18.px),
            justifyContent: .center,
            alignItems: .center,
            fontWeight: .w600,
            color: isOver ? cAccent : cMuted,
            backgroundColor: isOver ? cAccentSoft : cPanelAlt,
          ),
          [child],
        );
      },
      child: span([.text(id)]),
    );
  }

  Component _card(String label, Color background, {bool light = false}) {
    return div(
      styles: Styles(
        maxWidth: 220.px,
        padding: .symmetric(vertical: 16.px, horizontal: 20.px),
        border: .all(color: cCardBorder, width: 1.px),
        radius: .circular(16.px),
        cursor: .grab,
        userSelect: .none,
        fontWeight: .w600,
        textAlign: .center,
        color: light ? cWhiteWarm : cText,
        backgroundColor: background,
      ),
      [.text(label)],
    );
  }

  Component _detectorButton(_Detector detector, String label) {
    final active = detector == _detector;
    return button(
      styles: Styles(
        padding: .symmetric(vertical: 10.px, horizontal: 16.px),
        border: .all(color: active ? cAccent : cBorder, width: 1.px),
        radius: .circular(999.px),
        cursor: .pointer,
        fontFamily: kFontFamily,
        fontSize: 14.px,
        color: active ? cWhiteWarm : cText,
        backgroundColor: active ? cAccent : cPillBg,
      ),
      onClick: () => _select(detector),
      [.text(label)],
    );
  }

  String _detectorLabel(_Detector detector) {
    return switch (detector) {
      _Detector.closestCenter => 'closestCenter',
      _Detector.rectIntersection => 'rectIntersection',
      _Detector.pointerWithin => 'pointerWithin',
    };
  }
}
