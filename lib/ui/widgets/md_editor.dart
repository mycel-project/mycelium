import "package:flutter/material.dart";
import "package:mycelium/core/stores/review_store.dart";
import "package:mycelium/ui/controllers/markdown_controller.dart";
import "package:mycelium/ui/widgets/node_action_buttons.dart";
import "package:mycelium/ui/widgets/review_action_bar.dart";
import "package:mycelium/utils/device.dart";
import "package:mycelium/utils/responsive.dart";
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
          final cursorOffset =
              cursor *
              scrollController.position.maxScrollExtent /
              content.length;
          scrollController.animateTo(
            cursorOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    };

    scrollController.addListener(() {
      if (!scrollController.hasClients) return;
      final progress =
          scrollController.offset / scrollController.position.maxScrollExtent;
      vm.updateScroll(progress);
    });

    vm.goScrollTop = () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
        vm.updateScroll(0);
      }
    };

    void onScrollPositionChanged() async {
      if (vm.isUpdatingPosition) return;
      if (!mounted || !scrollController.hasClients) return;
      final position =
          vm.scrollPositionStore.offset *
          scrollController.position.maxScrollExtent /
          vm.content.length;
      scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    vm.scrollPositionStore.addListener(onScrollPositionChanged);
  }

  void _onCursorChanged() {
    if (vm.isUpdatingCursor || _isRemovingFocus) return;
    vm.onCursorChanged(markdownController.selection.baseOffset);
  }

  final ScrollController scrollController = ScrollController();

  bool _isRemovingFocus = false; // avoid stack overflow
  void removeFocusAndCursor() {
    if (_isRemovingFocus || vm.hasSelection) return;
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

    final readOnly = Device.isDesktop
        ? vm.isLocked()
        : vm.isLocked() || (!vm.activeKeyboard && !vm.isCurrentNodeSpore());

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.isDesktop(context)
                      ? MediaQuery.sizeOf(context).width * 0.5
                      : double.infinity,
                ),
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
                                readOnly: readOnly,
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
                          constraints: BoxConstraints(
                            maxWidth: Device.isDesktop ? 300 : double.infinity,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (!vm.isCurrentNodeSpore()) ...[
                                if (!Device.isDesktop) HistoryButton(vm: vm),
                                DismissButton(vm: vm),
                                FragmentButton(
                                  vm: vm,
                                  markdownController: markdownController,
                                ),
                                SporeButton(
                                  vm: vm,
                                  markdownController: markdownController,
                                ),
                                if (!Device.isDesktop)
                                  KeyboardButton(
                                    vm: vm,
                                    removeFocusAndCursor: removeFocusAndCursor,
                                  ),
                                MoreButton(
                                  markdownController: markdownController,
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
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.isDesktop(context)
                  ? MediaQuery.sizeOf(context).width * 0.5
                  : double.infinity,
            ),
            child: ReviewActionBar(
              vm: vm,
              focusNode: focusNode,
              reviewNodeId: reviewNodeId,
            ),
          ),
        ],
      ),
    );
  }
}
