import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

Future<String?> showInputDialog({
  required BuildContext context,
  required String title,
  String? placeholder,
  String? initialValue = "",
  TextInputType keyboardType = TextInputType.text,
}) async {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) => PointerInterceptor(
      child: _InputDialog(
        controller: controller,
        title: title,
        placeholder: placeholder,
        keyboardType: keyboardType,
      ),
    ),
  );
}

Future<String?> showInputDialogWithRetry({
  required BuildContext context,
  required String title,
  required Future<bool> Function(String)
  onSubmit, // The callback must return true if the action has been effectuated.
  String? placeholder,
  String? initialValue,
  TextInputType keyboardType = TextInputType.text,
}) async {
  String? currentValue = initialValue;
  while (true) {
    final value = await showInputDialog(
      context: context,
      title: title,
      initialValue: currentValue,
      placeholder: placeholder,
      keyboardType: keyboardType,
    );
    if (value == null) return null;
    final success = await onSubmit(value);
    if (!context.mounted) return null;
    currentValue = value;
    if (success) return value;
  }
}

class _InputDialog extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String? placeholder;
  final TextInputType keyboardType;

  const _InputDialog({
    required this.controller,
    required this.title,
    this.placeholder,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autofocus: true,
        decoration: InputDecoration(hintText: placeholder),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text("OK"),
        ),
      ],
    );
  }
}
