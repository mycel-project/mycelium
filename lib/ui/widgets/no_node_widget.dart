import "package:flutter/material.dart";
import "package:mycelium/ui/widgets/launch_review_button.dart";

class NoNodeWidget extends StatelessWidget {
  const NoNodeWidget({super.key}); 
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.all(32),
              child: Text(
                "No node selected.\nBrowse or add nodes using the left panel, or launch review.",
                textAlign: TextAlign.center,
              ),
            ),
            LaunchReviewButton(),
          ],
        ),
      ),
    );
  }
}
