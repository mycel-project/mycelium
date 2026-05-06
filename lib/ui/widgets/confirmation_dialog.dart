import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String text;
  final bool destructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.text,
    this.destructive = false,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String text,
    bool destructive = false,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierLabel: "Confirmation",
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, anim1, anim2) {
        return Material(
          color: Colors.black54,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pop(context, false),
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: ConfirmationDialog(
                  title: title,
                  text: text,
                  destructive: destructive,
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

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            destructive ? "Confirm" : "OK",
            style: TextStyle(color: destructive ? Colors.red : null),
          ),
        ),
      ],
    );
  }
}
