import "package:flutter/material.dart";
import "package:mycelium/core/stores/review_store.dart";
import "package:mycelium/ui/controllers/markdown_controller.dart";
import "package:mycelium/ui/widgets/confirmation_dialog.dart";
import "package:mycelium/ui/widgets/review_bottom_button.dart";
import "package:mycelium/ui/widgets/validation_bar.dart";
import "package:mycelium/viewmodels/md_editor_viewmodel.dart";
import 'package:provider/provider.dart';

/// Widget that handles the current node editing and review process.
class MdEditor extends StatefulWidget {
  const MdEditor({super.key});
  
  @override
  MdEditorState createState() => MdEditorState();
}

class MdEditorState extends State<MdEditor> {
  late final MarkdownController markdownController = MarkdownController();
  late MdEditorViewModel vm;

  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    vm = context.read<MdEditorViewModel>();

    markdownController.value = TextEditingValue(
      text: vm.content,
      selection: const TextSelection.collapsed(offset: 0),
    );
    markdownController.addListener(_onSelectionChanged);
    markdownController.addListener(_onCursorChanged);

    vm.onContentCommand = (content, cursor) {
      if (!mounted) return;
      markdownController.value = TextEditingValue(
        text: content,
        selection: TextSelection.collapsed(
          offset: (cursor ?? 0).clamp(0, content.length),
        ),
      );
      
      if (cursor != null && content.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || !scrollController.hasClients) return;
            final cursorOffset = cursor * scrollController.position.maxScrollExtent / content.length;
            scrollController.animateTo(
              cursorOffset,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
        });
      }
    };
  }

  void _onCursorChanged() {
    if (vm.isUpdatingCursor || _isRemovingFocus) return;
    vm.onCursorChanged(markdownController.selection.baseOffset);
  }

  final ScrollController scrollController = ScrollController();

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



  void _onSelectionChanged() {
    if (vm.isUpdatingSelection) return;
    vm.updateSelection(markdownController.selection);
  }

  @override
  void dispose() {
    focusNode.unfocus();
    vm.onContentCommand = null;
    markdownController.removeListener(_onSelectionChanged);
    markdownController.removeListener(_onCursorChanged);
    markdownController.dispose();
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
                            key: ValueKey(vm.node?.id),
                            focusNode: focusNode,
                            readOnly: vm.isLocked() == true
                                ? true
                                : !vm.activeKeyboard &&
                                      !vm.isCurrentNodeSpore(),
                            showCursor: !vm.isLocked(),
                            onTap: vm.isLocked() ? null : vm.editMode,
                            maxLines: null,
                            expands: false,
                            keyboardType: TextInputType.multiline,
                            undoController: vm.undoController,
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
                Positioned(
                  bottom: 16,
                  left: 8,
                  right: 8,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // FloatingActionButton(
                          //   // temp will be autosave only
                          //   onPressed: vm.isDirty ? vm.saveContent : null,
                          //   child: Opacity(
                          //     opacity: vm.isDirty ? 1.0 : 0.4,
                          //     child: const Icon(Icons.save),
                          //   ),
                          // ),
                          if (!vm.isCurrentNodeSpore()) ...[
                            GestureDetector(
                              onLongPress: vm.toggleHistoryMode,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  FloatingActionButton(
                                    onPressed: vm.canPerformHistoryAction
                                        ? vm.performHistoryAction
                                        : null,
                                    child: Opacity(
                                      opacity: vm.canPerformHistoryAction
                                          ? 1.0
                                          : 0.4,
                                      child: Icon(
                                        vm.historyButtonMode == ActionMode.undo
                                            ? Icons.undo
                                            : Icons.redo,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 3,
                                    right: 3,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        vm.historyButtonMode == ActionMode.undo
                                            ? Icons.redo
                                            : Icons.undo,
                                        size: 11,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FloatingActionButton(
                              onPressed: vm.dismissState == true
                                  ? () async => await vm.toggleDismiss()
                                  : () async {
                                      focusNode.unfocus();
                                      final result = await ConfirmationDialog.show(
                                        context,
                                        title: "Confirmation",
                                        text:
                                            "Have you extracted all the relevant information from this fragment?\n\nIt won’t be shown again in future reviews.",
                                      );
                                      if (result.confirmed == true) {
                                        if (!vm.hasChildren()) {
                                          final result =
                                              await ConfirmationDialog.show(
                                                context,
                                                title: "No children",
                                                text:
                                                    "This fragment has no children.\n\nOnly confirm if it is not valuable to you, as it will not be shown again in reviews.",
                                              );
                                          if (!result.confirmed) return;
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
                              onPressed: vm.hasSelection ? () async {
                                await vm.createFragment(markdownController.text);
                                markdownController.selection = const TextSelection.collapsed(offset: -1);
                                focusNode.unfocus();
                              } : null,
                              child: Opacity(
                                opacity: vm.hasSelection ? 1.0 : 0.4,
                                child: const Icon(Icons.content_cut),
                              ),
                            ),
                            FloatingActionButton(
                              onPressed: vm.hasSelection ? () async {
                                await vm.createSpore(markdownController.text);
                                markdownController.selection = const TextSelection.collapsed(offset: -1);
                                focusNode.unfocus();
                              } : null,
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
                                    final vm = context
                                        .watch<MdEditorViewModel>();
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
                                              await vm.deleteBeforeCursor(markdownController.text);
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
                                              await vm.deleteAfterCursor(markdownController.text);
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.delete),
                                            title: Text('Delete this fragment'),
                                            onTap: () async {
                                              final result =
                                                  await ConfirmationDialog.show(
                                                    context,
                                                    title:
                                                        "Delete confirmation",
                                                    text:
                                                        "Delete this fragment and all its children?",
                                                    destructive: true,
                                                  );
                                              if (!context.mounted) return;
                                              if (result.confirmed == true) {
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
                              onSelected: (value) async {
                                await vm.handleSporeReview(value);
                                focusNode.unfocus();
                              },
                            )
                          : ReviewBottomButton(
                              text: "Show Answer",
                              onUndoTap: () async {
                                await vm.undoReview();
                              },
                              onPressed: () {
                                vm.showAnswer();
                                focusNode.unfocus();
                              },
                            )
                    : ReviewBottomButton(
                        text: "Next Review",
                        onUndoTap: () async {
                          await vm.undoReview();
                        },
                        onPressed: () async {
                          await vm.handleFragmentReview();
                          focusNode.unfocus();
                        },
                      )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
