import 'package:flutter/material.dart';

class ConfirmationOption {
  final String label;
  final bool defaultValue;
  final String key;

  const ConfirmationOption({
    required this.key,
    required this.label,
    this.defaultValue = false,
  });
}

class ConfirmationResult {
  final bool confirmed;
  final Map<String, bool> options;

  const ConfirmationResult({required this.confirmed, required this.options});
}

class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String text;
  final bool destructive;
  final List<ConfirmationOption> options;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.text,
    this.destructive = false,
    this.options = const [],
  });

  static Future<ConfirmationResult> show(
    BuildContext context, {
    required String title,
    required String text,
    bool destructive = false,
    List<ConfirmationOption> options = const [],
  }) async {
    final result = await showGeneralDialog<ConfirmationResult>(
      context: context,
      barrierLabel: "Confirmation",
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, anim1, anim2) {
        return Material(
          color: Colors.black54,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pop(
              context,
              ConfirmationResult(confirmed: false, options: {}),
            ),
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: ConfirmationDialog(
                  title: title,
                  text: text,
                  destructive: destructive,
                  options: options,
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
    );
    return result ?? ConfirmationResult(confirmed: false, options: {});
  }

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  late Map<String, bool> _values;

  @override
  void initState() {
    super.initState();
    _values = {for (final o in widget.options) o.key: o.defaultValue};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.text),
          if (widget.options.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...widget.options.map((option) => CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(option.label),
              value: _values[option.key],
              onChanged: (val) => setState(() => _values[option.key] = val ?? false),
            )),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            ConfirmationResult(confirmed: false, options: _values),
          ),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            ConfirmationResult(confirmed: true, options: _values),
          ),
          child: Text(
            widget.destructive ? "Confirm" : "OK",
            style: TextStyle(color: widget.destructive ? Colors.red : null),
          ),
        ),
      ],
    );
  }
}
