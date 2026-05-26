import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:mycelium/data/models/node.dart";

// Maybe pass small node views embedding for instance title formatted (true title or content extract as in node tree)

// Used ClaudeAI to quickly build widget 
class PrioritySelector extends StatefulWidget {
  final List<Node> nodes;
  final int currentNodeId;
  final void Function(double newPriority) onConfirm;

  const PrioritySelector({
      super.key,
      required this.nodes,
      required this.currentNodeId,
      required this.onConfirm,
  });

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
    _sortedPriorities = widget.nodes
    .map((n) => n.priority)
    .toSet()
    .toList()
    ..sort();

    final currentNode = widget.nodes.firstWhere((n) => n.id == widget.currentNodeId);
    _selectedPriority = currentNode.priority;
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

  static const double _logIntensity = 2; // control log intensity

  double _priorityToSlider(double priority) {
    if (_sortedPriorities.length <= 1) return 0.0;
    final index = _sortedPriorities.indexOf(priority);
    if (index == -1) return 0.0;
    final t = index / (_sortedPriorities.length - 1);
    return log(1 + t * (exp(_logIntensity) - 1)) / _logIntensity;
  }

  double _sliderToPriority(double sliderVal) {
    if (_sortedPriorities.length <= 1) return _sortedPriorities.first;
    final t = (exp(sliderVal * _logIntensity) - 1) / (exp(_logIntensity) - 1);
    final index = (t * (_sortedPriorities.length - 1)).round()
    .clamp(0, _sortedPriorities.length - 1);
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
    final candidates = widget.nodes
    .where((n) => n.id != widget.currentNodeId && n.priority < _selectedPriority)
    .toList()
    ..sort((a, b) => b.priority.compareTo(a.priority));
    return candidates.isNotEmpty ? candidates.first : null;
  }

  Node? get _lowerPriorityNeighbor {
    final candidates = widget.nodes
    .where((n) => n.id != widget.currentNodeId && n.priority > _selectedPriority)
    .toList()
    ..sort((a, b) => a.priority.compareTo(b.priority));
    return candidates.isNotEmpty ? candidates.first : null;
  }

  String _excerpt(Node node) {
    final raw = node.content?['0'].trim() as String?;
    if (raw == null || raw.isEmpty) return '(no content)';
    return raw.length > 100 ? "${raw.substring(0, 100)}…" : raw;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final higher = _higherPriorityNeighbor;
    final lower = _lowerPriorityNeighbor;
    final sliderVal = _priorityToSlider(_selectedPriority);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reprioritize',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),

          _NeighborCard(
            label: 'More prioritized',
            node: higher,
            excerpt: higher != null ? _excerpt(higher) : null,
            priority: higher?.priority,
            dimmed: higher == null,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                    activeTrackColor: theme.colorScheme.primary,
                    inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                    thumbColor: theme.colorScheme.primary,
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onSubmitted: _onTextSubmitted,
                  onEditingComplete: () => _onTextSubmitted(_textController.text),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _NeighborCard(
            label: 'Less prioritized',
            node: lower,
            excerpt: lower != null ? _excerpt(lower) : null,
            priority: lower?.priority,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.3),
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
