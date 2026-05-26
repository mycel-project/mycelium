import "package:flutter/material.dart";

class NoMoreReviewsWidget extends StatelessWidget {
  final VoidCallback onDismiss;
  final VoidCallback onUndo;

  const NoMoreReviewsWidget({
    super.key,
    required this.onDismiss,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: GestureDetector(
        onTap: onDismiss,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "No more reviews for today.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: onUndo,
                        child: const Icon(Icons.undo),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: onDismiss,
                        child: const Icon(Icons.check),
                      ), 
                    ]
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
