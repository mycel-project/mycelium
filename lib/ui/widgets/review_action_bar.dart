import 'package:flutter/material.dart';
import 'package:mycelium/ui/widgets/review_bottom_button.dart';
import 'package:mycelium/ui/widgets/validation_bar.dart';
import 'package:mycelium/viewmodels/md_editor_viewmodel.dart';

class ReviewActionBar extends StatelessWidget {
  final MdEditorViewModel vm;
  final String? reviewNodeId;
  const ReviewActionBar({super.key, required this.vm, required this.reviewNodeId});

  @override
  Widget build(BuildContext context) {
    if (reviewNodeId != vm.node?.id || reviewNodeId == null) return const SizedBox.shrink();

    if (vm.isCurrentNodeSpore()) {
      if (vm.isAnswerVisible) {
        return ValidationBar(
          onSelected: (value) async {
            await vm.handleSporeReview(value);
            if (!context.mounted) return;
            FocusScope.of(context).unfocus();
          },
        );
      }
      return ReviewBottomButton(
        text: "Show Answer",
        onUndoTap: () async => await vm.undoReview(),
        onPressed: () {
          vm.showAnswer();
          FocusScope.of(context).unfocus();
        },
      );
    }

    return ReviewBottomButton(
      text: "Next Review",
      onUndoTap: () async => await vm.undoReview(),
      onPressed: () async {
        await vm.handleFragmentReview();
        if (!context.mounted) return;
        FocusScope.of(context).unfocus();
      },
    );
  }
}
