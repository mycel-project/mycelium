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
    markdownController.addListener(() {
        if (vm.isUpdatingCursor || _isRemovingFocus) return;
        vm.onCursorChanged(markdownController.selection.baseOffset);
    });

    vm.addListener(_syncFromVm);
    WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncFromVm();
    });
  }

  final ScrollController scrollController = ScrollController();

  int? _lastNodeId;

  bool _isRemovingFocus = false; // avoid stack overflow
  void removeFocusAndCursor() {
    if (_isRemovingFocus) return;
    _isRemovingFocus = true;
    focusNode.unfocus();
    vm.onCursorChanged(null);
    vm.updateSelection(null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
        _isRemovingFocus = false;
    });
  }

  void _syncFromVm() {
    final currentId = vm.node?.id;

    if (_lastNodeId != currentId) {
      removeFocusAndCursor();

      _lastNodeId = currentId;
    }
    if (vm.isUpdatingSelection || vm.isUpdatingCursor) return;

    if (markdownController.text != vm.content) {
      final target = vm.targetCursorPosition;
      markdownController.value = TextEditingValue(
        text: vm.content,
        selection: TextSelection.collapsed(
          offset:
          target ??
          markdownController.selection.baseOffset.clamp(
            0,
            vm.content.length,
          ),
        ),
      );
      if (target != null) {
        vm.targetCursorPosition = null;
        final cursorOffset =
        target *
        scrollController.position.maxScrollExtent /
        vm.content.length;
        scrollController.animateTo(
          cursorOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _onSelectionChanged() {
    if (vm.isUpdatingSelection) return;
    vm.updateSelection(markdownController.selection);
  }

  @override
  void dispose() {
    markdownController.removeListener(_onSelectionChanged);
    markdownController.dispose();
    vm.removeListener(_syncFromVm);
    focusNode.dispose();
    scrollController.dispose();
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
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    controller: scrollController,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 120,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: TextField(
                            focusNode: focusNode,
                            readOnly: vm.isLocked() == true
                            ? true
                            : !vm.activeKeyboard &&
                            !vm.isCurrentNodeSpore(),
                            showCursor: true,
                            onTap: vm.isLocked() ? null : vm.editMode,
                            maxLines: null,
                            expands: false,
                            keyboardType: TextInputType.multiline,
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
                  bottom: 16,
                  left: 8,
                  right: 8,
                  child:  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                              onPressed: vm.dismissState == true
                              ? () async => await vm.toggleDismiss()
                              : () async {
                                focusNode.unfocus();
                                final confirmed = await ConfirmationDialog.show(
                                  context,
                                  title: "Confirmation",
                                  text:
                                  "Have you extracted all the relevant information from this fragment?\n\nIt won’t be shown again in future reviews.",
                                );
                                if (confirmed == true) {
                                  if (!vm.hasChildren()) {
                                    final confirmed =
                                    await ConfirmationDialog.show(
                                      context,
                                      title: "No children",
                                      text:
                                      "This fragment has no children.\n\nOnly confirm if it is not valuable to you, as it will not be shown again in reviews.",
                                    );
                                    if (!confirmed) return;
                                  }
                                  await vm.toggleDismiss();
                                }
                              },
                              child: Opacity(
                                opacity: vm.dismissState ?? false ? 0.4 : 1.0,
                                child: const Icon(Icons.task_alt),
                              ),
                            ),
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
                              onPressed: () {
                                if (vm.activeKeyboard) {
                                  removeFocusAndCursor(); // Cleaner like that i guess
                                }
                                vm.toggleKeyboard();
                              },
                              child: vm.activeKeyboard
                              ? const Icon(Icons.keyboard_hide)
                              : const Icon(Icons.keyboard),
                            ),
                            FloatingActionButton(
                              child: Icon(Icons.more_vert),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    final vm = context.watch<MdEditorViewModel>();
                                    return SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            enabled: vm.hasCursor,
                                            leading: Icon(Icons.backspace),
                                            title: Text(
                                              'Delete all content before cursor',
                                            ),
                                            onTap: () async {
                                              await vm.deleteBeforeCursor();
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            enabled: vm.hasCursor,
                                            leading: Transform.flip(
                                              flipX: true,
                                              child: Icon(Icons.backspace),
                                            ),
                                            title: Text(
                                              'Delete all content after cursor',
                                            ),
                                            onTap: () async {
                                              await vm.deleteAfterCursor();
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.delete),
                                            title: Text('Delete this fragment'),
                                            onTap: () async {
                                              final confirm = await ConfirmationDialog.show(
                                                context,
                                                title: "Delete confirmation",
                                                text: "Delete this fragment and all its children?",
                                                destructive: true,
                                              );
                                              if (!context.mounted) return;
                                              if (confirm == true) {
                                                await vm.deleteNode();
                                              }
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
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
