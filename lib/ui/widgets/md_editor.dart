import "package:flutter/material.dart";
import "package:mycelium/core/stores/review_store.dart";
import "package:mycelium/ui/controllers/markdown_controller.dart";
import "package:mycelium/ui/widgets/confirmation_dialog.dart";
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

  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    vm = context.read<MdEditorViewModel>();

    markdownController.text = vm.content;
    markdownController.addListener(_onSelectionChanged);

    vm.addListener(_syncFromVm);
  }

  int? _lastNodeId;

  void _syncFromVm() {
    
    final currentId = vm.node?.id;

    if (_lastNodeId != currentId) {
      focusNode.unfocus();
      _lastNodeId = currentId;
    }
    if (vm.isUpdatingSelection) return;

    if (markdownController.text != vm.content) {
      final selection = markdownController.selection;
      markdownController.text = vm.content;
      markdownController.selection = selection;
    }

  }

  void _onSelectionChanged() {
    vm.updateSelection(markdownController.selection);

  }

  @override
  void dispose() {
    markdownController.removeListener(_onSelectionChanged);
    markdownController.dispose();
    vm.removeListener(_syncFromVm);
    super.dispose();
  }

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
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 120,
                    ),
                    child: TextField(
                      focusNode: focusNode,
                      readOnly: vm.isLocked(),
                      onTap: vm.isLocked() ? null : vm.editMode,
                      maxLines: null,
                      expands: false,
                      controller: markdownController,
                      onChanged: (value) {
                        vm.updateContent(value);
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
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
                  bottom: 32,
                  right: 32,
                  child: Wrap(
                    spacing: 24,
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
                          onPressed: vm.hasSelection
                              ? () async {
                                  await vm.createFragment();
                                  markdownController.selection =
                                      const TextSelection.collapsed(offset: -1);
                                  focusNode.unfocus();
                                }
                              : null,
                          child: Opacity(
                            opacity: vm.hasSelection ? 1.0 : 0.4,
                            child: const Icon(Icons.content_cut),
                          ),
                        ),
                        FloatingActionButton(
                          onPressed: vm.hasSelection
                              ? () async {
                                  await vm.createSpore();
                                  markdownController.selection =
                                      const TextSelection.collapsed(offset: -1);
                                  focusNode.unfocus();
                                }
                              : null,
                          child: Opacity(
                            opacity: vm.hasSelection ? 1.0 : 0.4,
                            child: const Icon(Icons.quiz),
                          ),
                        ),
                        FloatingActionButton(
                          onPressed: vm.dismissState == true
                          ? () async => await vm.toggleDismiss()
                          : () async {
                            focusNode.unfocus();
                            final confirmed =  await ConfirmationDialog.show(
                                context,
                                title: "Confirmation",
                                text: "Have you extracted all the relevant information from this fragment?\n\nIt won’t be shown again in future reviews."
                            );
                            if (confirmed == true) await vm.toggleDismiss();
                          },
                          child: Opacity(
                            opacity: vm.dismissState ?? false ? 0.4 : 1.0,
                            child: const Icon(Icons.task_alt),
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
