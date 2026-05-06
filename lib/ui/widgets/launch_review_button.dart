import "package:flutter/material.dart";
import 'package:mycelium/viewmodels/launch_review_button_viewmodel.dart';
import 'package:mycelium/core/injection.dart';

class LaunchReviewButton extends StatelessWidget {
  const LaunchReviewButton({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = sl<LaunchReviewButtonViewmodel>();
    return ElevatedButton(onPressed: vm.launch, child: Text("Review"));
  }
}
