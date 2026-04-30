import 'package:flutter/material.dart';


Future<String?> showInputDialog({
  required BuildContext context,
  required String title,
  String? placeholder,
  TextInputType keyboardType = TextInputType.text,
}) async {
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    barrierDismissible: true, 
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          autofocus: true,
          decoration: InputDecoration(
            hintText: placeholder,
          ),
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
    },
  );
}
