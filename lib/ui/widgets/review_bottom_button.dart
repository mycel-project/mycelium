import 'package:flutter/material.dart';

class ReviewBottomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final VoidCallback? onUndoTap;
  final String text;

  const ReviewBottomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.onUndoTap,
  });

 @override
Widget build(BuildContext context) {
  return SafeArea(
    top: false,
    child: SizedBox(
      height: 56,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onUndoTap != null)
            Expanded(
              flex: 15,
              child: Material(
                color: Colors.grey.shade200,
                child: InkWell(
                  onTap: onUndoTap,
                  child: const Center(
                    child: Icon(Icons.undo),
                  ),
                ),
              ),
            ),

          Expanded(
            flex: onUndoTap != null ? 85 : 100,
            child: SizedBox.expand( 
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
