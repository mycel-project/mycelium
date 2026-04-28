import "package:flutter/material.dart";
import 'package:mycelium/viewmodels/launch_review_button_viewmodel.dart';
import 'package:provider/provider.dart';

class LaunchReviewButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LaunchReviewButtonViewmodel>();
    return ElevatedButton(
      onPressed: () {
        vm.launch();
      },
      child: Text("Review"),
    );
  }
}
