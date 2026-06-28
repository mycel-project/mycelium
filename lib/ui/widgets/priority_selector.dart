import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:mycelium/data/models/node.dart";
import 'package:mycelium/ui/utils/priority_colors.dart';
import 'package:mycelium/ui/widgets/adaptative_sheet.dart';

// Maybe pass small node views embedding for instance title formatted (true title or content extract as in node tree)

// Used ClaudeAI to quickly build widget
class PrioritySelector extends StatefulWidget {
  final List<Node> nodes;
  final String currentNodeId;
  final void Function(double newPriority) onConfirm;
  final String title;

  const PrioritySelector({
    super.key,
    String? title,
    required this.nodes,
    required this.currentNodeId,
    required this.onConfirm,
  }) : title = title ?? "Reprioritize";

  @override
  State<PrioritySelector> createState() => _PrioritySelectorState();
}

class _PrioritySelectorState extends State<PrioritySelector> {
  late List<double> _sortedPriorities;
  late double _selectedPriority;
  late TextEditingController _textController;
  late FocusNode _textFocusNode;

  @override
  void initState() {
    super.initState();
    _sortedPriorities =
        widget.nodes.map((n) => n.getUnit().priority).toSet().toList()..sort();

    final currentNode = widget.nodes.firstWhere(
      (n) => n.id == widget.currentNodeId,
    );
    _selectedPriority = currentNode.getUnit().priority;
    _textController = TextEditingController(text: _selectedPriority.toString());

    _textFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  static const double _logIntensity = 1.0; // control log intensity

  double _priorityToSlider(double priority) {
    if (_sortedPriorities.length <= 1) return 0.0;
    final index = _sortedPriorities.indexOf(priority);
    if (index == -1) return 0.0;
    final t = index / (_sortedPriorities.length - 1);
    return 1.0 -
        (log(1 + (1.0 - t) * (exp(_logIntensity) - 1)) / _logIntensity);
  }

  double _sliderToPriority(double sliderVal) {
    if (_sortedPriorities.length <= 1) return _sortedPriorities.first;
    final t =
        1.0 -
        ((exp((1.0 - sliderVal) * _logIntensity) - 1) /
            (exp(_logIntensity) - 1));
    final index = (t * (_sortedPriorities.length - 1)).round().clamp(
      0,
      _sortedPriorities.length - 1,
    );
    return _sortedPriorities[index];
  }

  void _onSliderChanged(double val) {
    final priority = _sliderToPriority(val);
    setState(() {
      _selectedPriority = priority;
      _textController.text = priority.toString();
    });
  }

  void _onTextSubmitted(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null) {
      _textController.text = _selectedPriority.toString();
      return;
    }
    final clamped = parsed.clamp(0, 100);
    double nearest = _sortedPriorities.first;
    double minDist = (clamped - nearest).abs();
    for (final p in _sortedPriorities) {
      final dist = (clamped - p).abs();
      if (dist < minDist || (dist == minDist && p > nearest)) {
        minDist = dist;
        nearest = p;
      }
    }
    setState(() {
      _selectedPriority = nearest;
      _textController.text = nearest.toString();
    });
  }

  Node? get _higherPriorityNeighbor {
    final candidates =
        widget.nodes
            .where(
              (n) =>
                  n.id != widget.currentNodeId &&
                  n.getUnit().priority > _selectedPriority,
            )
            .toList()
          ..sort(
            (a, b) => a.getUnit().priority.compareTo(b.getUnit().priority),
          );
    return candidates.isNotEmpty ? candidates.first : null;
  }

  Node? get _lowerPriorityNeighbor {
    final candidates =
        widget.nodes
            .where(
              (n) =>
                  n.id != widget.currentNodeId &&
                  n.getUnit().priority < _selectedPriority,
            )
            .toList()
          ..sort(
            (a, b) => b.getUnit().priority.compareTo(a.getUnit().priority),
          );
    return candidates.isNotEmpty ? candidates.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final higher = _higherPriorityNeighbor;
    final lower = _lowerPriorityNeighbor;
    final sliderVal = _priorityToSlider(_selectedPriority);

    final List<Color> sliderGradientColors = [];
    for (int i = 0; i <= 20; i++) {
      sliderGradientColors.add(getPriorityColor(_sliderToPriority(i / 20.0)));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          _NeighborCard(
            label: 'More prioritized',
            node: higher,
            excerpt: higher?.contentPreview,
            priority: higher?.getUnit().priority,
            dimmed: higher == null,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    trackShape: GradientSliderTrackShape(
                      colors: sliderGradientColors,
                    ),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                    inactiveTrackColor:
                        theme.colorScheme.surfaceContainerHighest,
                    thumbColor: getPriorityColor(_selectedPriority),
                  ),
                  child: Slider(
                    value: sliderVal.clamp(0.0, 1.0),
                    min: 0.0,
                    max: 1.0,
                    onChanged: _onSliderChanged,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 88,
                child: TextField(
                  focusNode: _textFocusNode,
                  controller: _textController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: _onTextSubmitted,
                  onEditingComplete: () =>
                      _onTextSubmitted(_textController.text),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _NeighborCard(
            label: 'Less prioritized',
            node: lower,
            excerpt: lower?.contentPreview,
            priority: lower?.getUnit().priority,
            dimmed: lower == null,
          ),

          const SizedBox(height: 28),

          ElevatedButton(
            onPressed: () {
              _onTextSubmitted(_textController.text);
              widget.onConfirm(_selectedPriority);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _NeighborCard extends StatelessWidget {
  final String label;
  final Node? node;
  final String? excerpt;
  final double? priority;
  final bool dimmed;

  const _NeighborCard({
    required this.label,
    required this.node,
    required this.excerpt,
    required this.priority,
    required this.dimmed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      opacity: dimmed ? 0.3 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: priority != null
                ? getPriorityColor(priority!)
                : theme.dividerColor.withValues(alpha: 0.3),
            width: priority != null ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  priority != null ? '$priority%' : '',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              excerpt ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showPriorityPicker(
  BuildContext context, {
  String? title,
  required List<Node> nodes,
  required String currentNodeId,
  required Future<void> Function() onRefresh,
  required Future<bool> Function(String nodeId, double priority) onUpdate,
}) async {
  if (nodes.length < 500) {
    await onRefresh();
  }
  if (!context.mounted) return;
  showAdaptiveSheet(
    context: context,
    child: PrioritySelector(
      title: title,
      nodes: nodes,
      currentNodeId: currentNodeId,
      onConfirm: (value) {
        onUpdate(currentNodeId, value);
        Navigator.pop(context);
      },
    ),
  );
}

class GradientSliderTrackShape extends SliderTrackShape {
  final List<Color> colors;
  const GradientSliderTrackShape({required this.colors});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final activeGradient = LinearGradient(colors: colors);

    final activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );
    final inactiveRect = Rect.fromLTRB(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
    );

    if (activeRect.width > 0) {
      final activePaint = Paint()
        ..shader = activeGradient.createShader(trackRect);
      context.canvas.drawRRect(
        RRect.fromRectAndCorners(
          activeRect,
          topLeft: Radius.circular(trackRect.height / 2),
          bottomLeft: Radius.circular(trackRect.height / 2),
        ),
        activePaint,
      );
    }

    if (inactiveRect.width > 0) {
      final inactivePaint = Paint()
        ..color = sliderTheme.inactiveTrackColor ?? Colors.grey;
      context.canvas.drawRRect(
        RRect.fromRectAndCorners(
          inactiveRect,
          topRight: Radius.circular(trackRect.height / 2),
          bottomRight: Radius.circular(trackRect.height / 2),
        ),
        inactivePaint,
      );
    }
  }
}
