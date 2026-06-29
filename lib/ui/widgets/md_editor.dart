import "dart:convert";
import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:mycelium/core/stores/review_store.dart";
import "package:mycelium/ui/controllers/markdown_controller.dart";
import "package:mycelium/ui/widgets/confirmation_dialog.dart";
import "package:mycelium/ui/widgets/node_action_buttons.dart";
import "package:mycelium/ui/widgets/review_action_bar.dart";
import "package:mycelium/utils/device.dart";
import "package:mycelium/utils/responsive.dart";
import "package:mycelium/viewmodels/md_editor_viewmodel.dart";
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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

  InAppWebViewController? _webViewController;

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
      if (!mounted || _webViewController == null) return;
      _webViewController!.callAsyncJavaScript(
        functionBody: "window.myceliumEditor.setDoc(content);",
        arguments: {'content': content},
      );
    };

    vm.goScrollTop = () {
      vm.updateScroll(0);
      if (!mounted || _webViewController == null) return;
      _webViewController!.callAsyncJavaScript(
        functionBody: "window.myceliumEditor.scrollToProgress(0);",
      );
    };

    void onScrollPositionChanged() async {
      if (vm.isUpdatingPosition) return;
      if (!mounted || _webViewController == null) return;

      final double progress = vm.content.isEmpty
          ? 0
          : vm.scrollPositionStore.offset / vm.content.length;
      _webViewController!.callAsyncJavaScript(
        functionBody: "window.myceliumEditor.scrollToProgress(progress);",
        arguments: {'progress': progress},
      );
    }

    vm.scrollPositionStore.addListener(onScrollPositionChanged);
  }

  void _onCursorChanged() {
    if (vm.isUpdatingCursor || _isRemovingFocus) return;
    vm.onCursorChanged(markdownController.selection.baseOffset);
  }

  bool _isRemovingFocus = false; // avoid stack overflow
  void removeFocusAndCursor() {
    if (_isRemovingFocus || vm.hasSelection) return;
    _isRemovingFocus = true;
    focusNode.unfocus();
    _webViewController?.clearFocus();
    _webViewController?.callAsyncJavaScript(
      functionBody:
          "if (document.activeElement) document.activeElement.blur();",
    );
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
    super.dispose();
  }

  String? _previousNodeId;
  bool? _previousLocked;
  bool? _previousKeyboard;

  bool _isShowingDialog = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newNodeId = vm.nodeStore.currentNode?.id;

    if (_previousNodeId != newNodeId) {
      _previousNodeId = newNodeId;
      focusNode.unfocus();
    }

    if (vm.showUnsavedChangesDialog && !_isShowingDialog) {
      _isShowingDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final result = await ConfirmationDialog.show(
          context,
          title: "Discard Changes?",
          text:
              "Your changes couldn't be saved. Switching to another node will discard them.",
          destructive: true,
        );
        _isShowingDialog = false;
        result.confirmed ? vm.confirmDiscardChanges() : vm.cancelNodeChange();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MdEditorViewModel>();
    final reviewNodeId = context.watch<ReviewStore>().currentNodeId;

    final isLocked = vm.isLocked();
    final showKeyboard =
        Device.isDesktop || vm.activeKeyboard || vm.isCurrentNodeSpore();
    final requestFocus = showKeyboard && _previousKeyboard == false;

    if (_previousLocked != isLocked || _previousKeyboard != showKeyboard) {
      _previousLocked = isLocked;
      _previousKeyboard = showKeyboard;
      _webViewController?.callAsyncJavaScript(
        functionBody:
            "window.myceliumEditor.setMode(isLocked, showKeyboard, requestFocus);",
        arguments: {
          'isLocked': isLocked,
          'showKeyboard': showKeyboard,
          'requestFocus': requestFocus,
        },
      );
    }

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
                      child: Container(
                        decoration: vm.isCurrentNodeSpore()
                            ? vm.noClozeField
                                  ? BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    )
                                  : BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    )
                            : vm.dismissState == true
                            ? BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              )
                            : const BoxDecoration(),
                        child: InAppWebView(
                          initialFile: "assets/editor/dist/index.html",
                          gestureRecognizers:
                              <Factory<OneSequenceGestureRecognizer>>{
                                Factory<VerticalDragGestureRecognizer>(
                                  VerticalDragGestureRecognizer.new,
                                ),
                                Factory<LongPressGestureRecognizer>(
                                  () => LongPressGestureRecognizer(
                                    duration: const Duration(milliseconds: 250),
                                  ),
                                ),
                              },
                          onWebViewCreated: (controller) {
                            _webViewController = controller;

                            controller.addJavaScriptHandler(
                              handlerName: 'onTextChange',
                              callback: (args) {
                                if (args.isNotEmpty) {
                                  vm.updateContent(args[0] as String);
                                }
                              },
                            );

                            controller.addJavaScriptHandler(
                              handlerName: 'onSelectionChange',
                              callback: (args) {
                                if (args.isNotEmpty) {
                                  final data = Map<String, dynamic>.from(
                                    args[0] as Map,
                                  );
                                  vm.onCursorChanged(data['extent'] as int);
                                  vm.updateSelection(
                                    TextSelection(
                                      baseOffset: data['base'] as int,
                                      extentOffset: data['extent'] as int,
                                    ),
                                  );
                                }
                              },
                            );
                            controller.addJavaScriptHandler(
                              handlerName: 'onScrollChanged',
                              callback: (args) {
                                if (args.isNotEmpty) {
                                  vm.updateScroll((args[0] as num).toDouble());
                                }
                              },
                            );
                          },
                          onLoadStop: (controller, url) async {
                            final initialText = vm.content;
                            await controller.callAsyncJavaScript(
                              functionBody: """
                                window.myceliumEditor.setMode(isLocked, showKeyboard, false);
                                window.myceliumEditor.setDoc(content);
                              """,
                              arguments: {
                                'content': initialText,
                                'isLocked': _previousLocked ?? false,
                                'showKeyboard': _previousKeyboard ?? true,
                              },
                            );
                          },
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
                                  removeFocusAndCursor: () {
                                    removeFocusAndCursor();
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
