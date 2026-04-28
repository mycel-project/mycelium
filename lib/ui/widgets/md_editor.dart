import "package:flutter/material.dart";
import "package:mycelium/core/stores/review_state.dart";
import "package:mycelium/core/stores/review_store.dart";
import "package:mycelium/ui/controllers/markdown_controller.dart";
import "package:mycelium/ui/widgets/next_review_button.dart";
import "package:mycelium/ui/widgets/show_answer_button.dart";
import "package:mycelium/ui/widgets/validation_bar.dart";
import "package:mycelium/viewmodels/md_editor_view_model.dart";
import 'package:provider/provider.dart';

/// Widget that handles the current node editing and review process.
class MdEditor extends StatefulWidget {
  @override
  _MdEditorState createState() => _MdEditorState();
}

class _MdEditorState extends State<MdEditor> {
  late final MarkdownController markdownController = MarkdownController();
  late MdEditorViewModel vm;

  @override
  void initState() {
    super.initState();

    vm = context.read<MdEditorViewModel>();

    markdownController.text = vm.content;

    vm.addListener(_syncFromVm);
  }

  void _syncFromVm() {
    final vm = context.read<MdEditorViewModel>();

    if (markdownController.text != vm.content) {
      final selection = markdownController.selection;
      markdownController.text = vm.content;
      markdownController.selection = selection;
    }
  }

  @override
  void dispose() {
    markdownController.dispose();
    vm.removeListener(_syncFromVm);
    super.dispose();
  }

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MdEditorViewModel>();
    final reviewNodeId = context.watch<ReviewStore>().currentNodeId;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: TextField(
                    focusNode: focusNode,
                    readOnly: vm.isLocked(),
                    onTap: vm.isLocked() ? null : vm.editMode,
                    maxLines: null,
                    expands: true,
                    controller: markdownController,
                    onChanged: (value) {
                      vm.updateContent(value);
                    },
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                if (vm.uiMessage != null)
                  Positioned(
                    bottom: 110,
                    right: 30,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vm.uiMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 40,
                  right: 30,
                  child: Row(
                    children: [
                      FloatingActionButton(
                        onPressed: vm.isDirty ? vm.saveContent : null,
                        child: Opacity(
                          opacity: vm.isDirty ? 1.0 : 0.4,
                          child: const Icon(Icons.save),
                        ),
                      ),
                      if (!vm.isCurrentNodeSpore()) ...[
                        FloatingActionButton(
                          onPressed: vm.isDirty ? vm.saveContent : null,
                          child: Opacity(
                            opacity: vm.isDirty ? 1.0 : 0.4,
                            child: const Icon(Icons.content_cut),
                          ),
                        ),
                        FloatingActionButton(
                          onPressed: vm.isDirty ? vm.saveContent : null,
                          child: Opacity(
                            opacity: vm.isDirty ? 1.0 : 0.4,
                            child: const Icon(Icons.quiz),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          reviewNodeId == vm.node?.id
              ? vm.isCurrentNodeSpore()
                    ? vm.isAnswerVisible
                          ? ValidationBar(
                              onSelected: (value) {
                                vm.saveContent;
                                vm.reviewSpore(value);
                                focusNode.unfocus();
                                vm.nextReview();
                              },
                            )
                          : ShowAnswerButton(
                              onPressed: () {
                                vm.showAnswer();
                                focusNode.unfocus();
                              },
                            )
                    : NextReviewButton(
                        onPressed: () {
                          vm.saveContent;
                          focusNode.unfocus();
                          vm.reviewFragment();
                          vm.nextReview();
                        },
                      )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
