import 'package:flutter/material.dart';

class ValidationBar extends StatelessWidget {
  final void Function(int value) onSelected;

  const ValidationBar({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Row(
          children: [
            _buildButton(label: "again", color: Colors.red, value: 1),
            _buildButton(
              label: "hard",
              color: Colors.white,
              textColor: Colors.black,
              value: 2,
            ),
            _buildButton(label: "medium", color: Colors.green, value: 3),
            _buildButton(label: "easy", color: Colors.blue, value: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required int value,
    Color textColor = Colors.white,
  }) {
    return Expanded(
      child: SizedBox(
        height: double.infinity,
        child: ElevatedButton(
          onPressed: () => onSelected(value),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            padding: EdgeInsets.zero,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
