import 'package:flutter/material.dart';
import 'package:mycelium/data/models/outline_entry.dart';
import 'package:mycelium/ui/widgets/adaptative_sheet.dart';
import 'package:mycelium/ui/widgets/outline_sheet.dart';


// ClaudeAI juste to enhance UI
class HeadingSplitter extends StatefulWidget {
  final List<OutlineEntry>? outline;
  final void Function(int level) onConfirm;

  const HeadingSplitter({
    super.key,
    required this.outline,
    required this.onConfirm,
  });

  @override
  State<HeadingSplitter> createState() => _HeadingSplitterState();
}

class _HeadingSplitterState extends State<HeadingSplitter> {
  int level = 2;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onSliderChanged(double val) {
    setState(() {
      level = val.toInt();
    });
  }

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final sliderVal = level.toDouble();

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Text(
          'Split fragment',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
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
                  value: sliderVal.clamp(1, 6),
                  min: 1,
                  max: 6,
                  divisions: 5,
                  onChanged: _onSliderChanged,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'H$level',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      const Divider(height: 1),
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: OutlineSheet(entries: widget.outline, level: level),
      ),
      const Divider(height: 1),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => widget.onConfirm(level),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm'),
          ),
        ),
      ),
    ],
  );
}
}

Future<void> showHeadingSplitter(
  BuildContext context, {
  required List<OutlineEntry>? outline,
  required void Function(int level) onConfirm,
}) async {
  if (!context.mounted) return;
  await showAdaptiveSheet(
    context: context,
    child: HeadingSplitter(outline: outline, onConfirm: onConfirm),
  );
}
