import "package:flutter/material.dart";

class NoMoreReviewsWidget extends StatelessWidget {
  final VoidCallback onDismiss;

  const NoMoreReviewsWidget({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                "No more reviews for today.",
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: onDismiss,
              child: const Icon(Icons.check),
            ),
          ],
        ),
      ),
    );
  }
}
