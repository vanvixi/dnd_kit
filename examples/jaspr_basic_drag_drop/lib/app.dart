import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class BasicDragDropApp extends StatefulComponent {
  const BasicDragDropApp({super.key});

  @override
  State<BasicDragDropApp> createState() => _BasicDragDropAppState();
}

class _BasicDragDropAppState extends State<BasicDragDropApp> {
  late final DndController _controller = DndController()
    ..addListener(_handleControllerChanged);

  DndId _activeLaneId = _lanes.first.id;
  int _dragStartCount = 0;
  int _dragMoveCount = 0;
  int _dragEndCount = 0;
  int _dragCancelCount = 0;

  @override
  void dispose() {
    _controller
      ..removeListener(_handleControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleDragEnd(DndDragEndEvent event) {
    final overId = event.overId;
    if (overId != null &&
        _lanes.any((lane) => lane.id == overId) &&
        overId != _activeLaneId) {
      setState(() => _activeLaneId = overId);
    }
  }

  @override
  Component build(BuildContext context) {
    final session = _controller.activeSession;
    final isDragging = session != null;
    final activeLane = _lanes.firstWhere((lane) => lane.id == _activeLaneId);
    final overId = _controller.overId?.value ?? 'none';
    final delta = session?.delta ?? DndPoint.zero;
    final currentPointer = session?.currentPointer ?? DndPoint.zero;

    return div(
      attributes: _style(
        'min-height:100vh; padding:32px; background:#f4efe7; color:#1f2937; '
        'font-family:IBM Plex Sans, Avenir Next, Segoe UI, sans-serif; '
        'cursor:${isDragging ? 'grabbing' : 'default'};',
      ),
      [
        DndScope(
          controller: _controller,
          child: div(
            attributes: _style(
              'max-width:1080px; margin:0 auto; padding:28px; border:1px solid #d7c7af; '
              'border-radius:28px; background:#fffaf2; display:flex; flex-direction:column; gap:24px;',
            ),
            [
              _Header(
                activeLaneLabel: activeLane.label,
                overId: overId,
                delta: _formatPoint(delta),
                currentPointer: _formatPoint(currentPointer),
                controllerState: _controller.state.runtimeType.toString(),
                dragStartCount: _dragStartCount,
                dragMoveCount: _dragMoveCount,
                dragEndCount: _dragEndCount,
                dragCancelCount: _dragCancelCount,
              ),
              div(
                attributes: _style(
                  'display:flex; flex-wrap:wrap; gap:20px; align-items:stretch;',
                ),
                [
                  for (final lane in _lanes)
                    _Lane(
                      lane: lane,
                      isActiveLane: lane.id == _activeLaneId,
                      child: lane.id == _activeLaneId
                          ? _DraggableTask(
                              isDragging: isDragging,
                              onDragStart: (_) {
                                setState(() {
                                  _dragStartCount += 1;
                                });
                              },
                              onDragMove: (_) {
                                setState(() {
                                  _dragMoveCount += 1;
                                });
                              },
                              onDragEnd: (event) {
                                setState(() {
                                  _dragEndCount += 1;
                                });
                                _handleDragEnd(event);
                              },
                              onDragCancel: (_) {
                                setState(() {
                                  _dragCancelCount += 1;
                                });
                              },
                            )
                          : const _EmptyLaneState(),
                    ),
                ],
              ),
              DndDragOverlay(
                builder: (context, overlayDetails) {
                  return _TaskCard(
                    title: 'Design API review',
                    subtitle:
                        'Overlay follows the shared runtime during free-form dragging.',
                    chipLabel: overlayDetails.overId?.value ?? 'moving',
                    isDragging: true,
                    showHandle: false,
                    attributes: const <String, String>{
                      'data-example-overlay': 'true',
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessComponent {
  const _Header({
    required this.activeLaneLabel,
    required this.overId,
    required this.delta,
    required this.currentPointer,
    required this.controllerState,
    required this.dragStartCount,
    required this.dragMoveCount,
    required this.dragEndCount,
    required this.dragCancelCount,
  });

  final String activeLaneLabel;
  final String overId;
  final String delta;
  final String currentPointer;
  final String controllerState;
  final int dragStartCount;
  final int dragMoveCount;
  final int dragEndCount;
  final int dragCancelCount;

  @override
  Component build(BuildContext context) {
    return div(
      attributes: _style('display:flex; flex-direction:column; gap:12px;'),
      [
        h1(
          attributes: _style('margin:0; font-size:40px; line-height:1.1;'),
          const [
            Component.text(
                'Jaspr drag and drop, with the shared runtime live.'),
          ],
        ),
        p(
          attributes: _style(
              'margin:0; font-size:18px; line-height:1.5; color:#5b6470;'),
          const [
            Component.text(
              'The card moves through a browser pointer drag, tracks the live '
              'pointer delta, and stays free-form so the demo fits mobile '
              'layouts that stack vertically.',
            ),
          ],
        ),
        div(
          attributes: _style('display:flex; flex-wrap:wrap; gap:12px;'),
          [
            _MetricPill(
                id: 'metric-lane', label: 'Lane', value: activeLaneLabel),
            _MetricPill(id: 'metric-over', label: 'Over', value: overId),
            _MetricPill(id: 'metric-delta', label: 'Delta', value: delta),
            _MetricPill(
                id: 'metric-pointer', label: 'Pointer', value: currentPointer),
            _MetricPill(
              id: 'metric-state',
              label: 'State',
              value: controllerState,
            ),
            _MetricPill(
              id: 'metric-drag-events',
              label: 'Drag',
              value:
                  's:$dragStartCount m:$dragMoveCount e:$dragEndCount c:$dragCancelCount',
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessComponent {
  const _MetricPill({
    required this.id,
    required this.label,
    required this.value,
  });

  final String id;
  final String label;
  final String value;

  @override
  Component build(BuildContext context) {
    return div(
      id: id,
      attributes: _style(
        'display:flex; gap:8px; align-items:center; padding:10px 14px; border:1px solid #d7c7af; '
        'border-radius:999px; background:#fbf4ea;',
      ),
      [
        span(
          attributes: _style(
            'font-size:12px; letter-spacing:1.1px; text-transform:uppercase; color:#8a5a24;',
          ),
          [Component.text(label)],
        ),
        strong([Component.text(value)]),
      ],
    );
  }
}

class _Lane extends StatelessComponent {
  const _Lane({
    required this.lane,
    required this.isActiveLane,
    required this.child,
  });

  final _LaneModel lane;
  final bool isActiveLane;
  final Component child;

  @override
  Component build(BuildContext context) {
    return div(
      attributes: _style('flex:1 1 220px; min-width:220px;'),
      [
        DndDroppable(
          id: lane.id,
          builder: (context, dropDetails, dropChild) {
            return section(
              id: 'lane-${lane.id.value}',
              attributes: _mergeAttributes(
                _style(
                  'min-height:250px; padding:18px; border-radius:24px; display:flex; '
                  'flex-direction:column; gap:16px; background:${dropDetails.isOver ? '#fff1df' : '#f8efe2'}; '
                  'border:${dropDetails.isOver ? '2px solid #c2410c' : '1px solid #d7c7af'};',
                ),
                <String, String>{
                  'data-lane-id': lane.id.value,
                  'data-is-over': dropDetails.isOver.toString(),
                },
              ),
              [
                div(
                  attributes: _style(
                    'display:flex; justify-content:space-between; align-items:center; gap:12px;',
                  ),
                  [
                    strong(
                      attributes: _style('font-size:20px;'),
                      [Component.text(lane.label)],
                    ),
                    span(
                      attributes: _style(
                        'padding:6px 10px; border-radius:999px; font-size:12px; letter-spacing:1.1px; '
                        'text-transform:uppercase; background:${dropDetails.isOver ? '#f97316' : '#eadac4'}; '
                        'color:${dropDetails.isOver ? '#fff7ed' : '#6b4f32'};',
                      ),
                      [
                        Component.text(
                            dropDetails.isOver ? 'Drop here' : lane.tone)
                      ],
                    ),
                  ],
                ),
                p(
                  attributes:
                      _style('margin:0; line-height:1.5; color:#5b6470;'),
                  [Component.text(lane.description)],
                ),
                div(
                  attributes: _style(
                      'display:flex; flex-direction:column; gap:12px; margin-top:8px;'),
                  [
                    if (isActiveLane) dropChild else const _EmptyLaneState(),
                  ],
                ),
              ],
            );
          },
          child: child,
        ),
      ],
    );
  }
}

class _DraggableTask extends StatelessComponent {
  const _DraggableTask({
    required this.isDragging,
    required this.onDragStart,
    required this.onDragMove,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  final bool isDragging;
  final void Function(DndDragStartEvent event) onDragStart;
  final void Function(DndDragMoveEvent event) onDragMove;
  final void Function(DndDragEndEvent event) onDragEnd;
  final void Function(DndDragCancelEvent event) onDragCancel;

  @override
  Component build(BuildContext context) {
    return DndDraggable(
      id: const DndId('task-api-review'),
      onDragStart: onDragStart,
      onDragMove: onDragMove,
      onDragEnd: onDragEnd,
      onDragCancel: onDragCancel,
      child: _TaskCard(
        title: 'Design API review',
        subtitle:
            'Grab the handle, drag in any direction, and watch the live delta update.',
        chipLabel: 'active task',
        isDragging: isDragging,
        handleId: 'task-handle',
        attributes: <String, String>{
          'data-draggable-card': 'true',
        },
      ),
    );
  }
}

class _TaskCard extends StatelessComponent {
  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.chipLabel,
    required this.isDragging,
    this.handleId,
    this.showHandle = true,
    this.attributes,
  });

  final String title;
  final String subtitle;
  final String chipLabel;
  final bool isDragging;
  final String? handleId;
  final bool showHandle;
  final Map<String, String>? attributes;

  @override
  Component build(BuildContext context) {
    return article(
      attributes: _mergeAttributes(
        _style(
          'padding:18px; border-radius:22px; background:#fffdf8; border:1px solid #d9c4a2; '
          'display:flex; flex-direction:column; gap:14px; '
          'cursor:${isDragging ? 'grabbing' : 'default'};',
        ),
        attributes,
      ),
      [
        div(
          attributes: _style(
            'display:flex; justify-content:space-between; align-items:center; gap:12px;',
          ),
          [
            strong(
              attributes: _style('font-size:18px;'),
              [Component.text(title)],
            ),
            span(
              attributes: _style(
                'padding:6px 10px; border-radius:999px; background:#f4e4cc; color:#7c5221; '
                'font-size:12px; letter-spacing:1.1px; text-transform:uppercase;',
              ),
              [Component.text(chipLabel)],
            ),
          ],
        ),
        p(
          attributes: _style('margin:0; line-height:1.5; color:#5b6470;'),
          [Component.text(subtitle)],
        ),
        if (showHandle)
          div(
            attributes: _style(
              'display:flex; justify-content:space-between; align-items:center; gap:12px;',
            ),
            [
              DndDragHandle(
                child: div(
                  id: handleId,
                  attributes: _style(
                    'display:inline-flex; align-items:center; justify-content:center; '
                    'border-radius:999px; background:#9a3412; color:#fff7ed; '
                    'padding:10px 14px; cursor:${isDragging ? 'grabbing' : 'grab'}; '
                    'user-select:none;',
                  ),
                  const [Component.text('Drag handle')],
                ),
              ),
              span(
                attributes: _style('font-size:13px; color:#7a8391;'),
                const [Component.text('Free drag is active')],
              ),
            ],
          ),
      ],
    );
  }
}

class _EmptyLaneState extends StatelessComponent {
  const _EmptyLaneState();

  @override
  Component build(BuildContext context) {
    return div(
      attributes: _style(
        'min-height:132px; display:flex; align-items:center; justify-content:center; '
        'padding:16px; border:1px solid #dbc9b1; border-radius:20px; background:#fcf7ef; '
        'color:#8c7658; text-align:center; line-height:1.5;',
      ),
      const [
        Component.text('Drop the task here to move app-owned state.'),
      ],
    );
  }
}

class _LaneModel {
  const _LaneModel({
    required this.id,
    required this.label,
    required this.tone,
    required this.description,
  });

  final DndId id;
  final String label;
  final String tone;
  final String description;
}

const _lanes = <_LaneModel>[
  _LaneModel(
    id: DndId('lane-brief'),
    label: 'Brief',
    tone: 'Start',
    description:
        'The task starts here so the example can show handle-only pickup.',
  ),
  _LaneModel(
    id: DndId('lane-build'),
    label: 'Build',
    tone: 'Transit',
    description:
        'Free movement keeps the example natural on desktop and mobile layouts.',
  ),
  _LaneModel(
    id: DndId('lane-ship'),
    label: 'Ship',
    tone: 'Finish',
    description:
        'Dropping here updates local app state, not library-owned state.',
  ),
];

Map<String, String> _style(String value) => <String, String>{'style': value};

Map<String, String> _mergeAttributes(
  Map<String, String> base,
  Map<String, String>? extra,
) {
  if (extra == null || extra.isEmpty) {
    return base;
  }

  return <String, String>{
    ...base,
    ...extra,
  };
}

String _formatPoint(DndPoint point) =>
    '${point.x.toStringAsFixed(0)}, ${point.y.toStringAsFixed(0)}';
