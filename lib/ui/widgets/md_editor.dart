import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:mycelium/core/editor/editor_backend.dart";
import "package:mycelium/core/editor/editor_command.dart";
import "package:mycelium/core/editor/editor_event.dart";
import "package:mycelium/core/stores/review_store.dart";
import "package:mycelium/ui/widgets/confirmation_dialog.dart";
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
  late MdEditorViewModel vm;
  late final EditorBackend _backend;

  final FocusNode focusNode = FocusNode();

  StreamSubscription<EditorCommand>? _vmCommandSub;
  StreamSubscription<EditorEvent>? _backendEventSub;

  @override
  void initState() {
    super.initState();
    _backend = context.read<EditorBackend>();
    vm = context.read<MdEditorViewModel>();
    focusNode.addListener(_onFlutterFocusChanged);

    // commands comming from vm
    _vmCommandSub = vm.commands.listen((cmd) { 
      if (!mounted) return;
      _backend.handleCommand(cmd);
    });

    // Listen for flutter_live_markdown hooks
    _backendEventSub = _backend.events.listen(_onBackendEvent); 

    vm.scrollPositionStore.addListener(_onScrollPositionChanged);
  }

  void _onBackendEvent(EditorEvent event) {
    if (!mounted) return;
    switch (event) {
      case TextChanged(:final getText):
        vm.updateContentLazy(getText);
      case SelectionChanged(:final getBase, :final getExtent, :final hasSelection):
        vm.onSelectionChanged(getBase, getExtent, hasSelection);
      case HistoryChanged(:final canUndo, :final canRedo):
        vm.updateHistoryState(canUndo, canRedo);
      case EditorFocused():
        if (!focusNode.hasFocus) {
          focusNode.requestFocus();
        }
    }
  }

  bool _isRemovingFocus = false;
  void removeFocusAndCursor({bool force = false}) {
    if (_isRemovingFocus || (!force && vm.hasSelection)) return;
    _isRemovingFocus = true;
    focusNode.unfocus();
    _backend.handleCommand(const Blur());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.onSelectionChanged(() => 0, () => 0, false);
      _isRemovingFocus = false;
    });
  }

  void _onScrollPositionChanged() {
    if (vm.isUpdatingPosition) return;
    if (!mounted) return;
    _backend.handleCommand(ScrollTo(vm.scrollPositionStore.offset));
  }

  @override
  void dispose() {
    _vmCommandSub?.cancel();
    _backendEventSub?.cancel();
    vm.scrollPositionStore.removeListener(_onScrollPositionChanged);
    focusNode.removeListener(_onFlutterFocusChanged);
    focusNode.unfocus();
    focusNode.dispose();
    super.dispose();
  }

  void _onFlutterFocusChanged() {
    if (!focusNode.hasFocus) {
      _backend.handleCommand(const Blur());
    }
  }

  String? _previousNodeId;
  bool? _previousLocked;
  bool? _previousKeyboard;
  bool? _previousActiveKeyboard;

  bool _isShowingDialog = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newNodeId = vm.nodeStore.currentNode?.id;

    if (_previousNodeId != newNodeId) {
      _previousNodeId = newNodeId;
      removeFocusAndCursor(force: true);
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
    final currentVm = context.watch<MdEditorViewModel>();
    final reviewNodeId = context.watch<ReviewStore>().currentNodeId;

    final isLocked = currentVm.isLocked();
    final showKeyboard =
        Device.isDesktop ||
        currentVm.activeKeyboard ||
        currentVm.isCurrentNodeSpore();

    final activeKeyboardChanged =
        _previousActiveKeyboard != currentVm.activeKeyboard;
    final requestFocus = currentVm.activeKeyboard && activeKeyboardChanged;

    if (_previousLocked != isLocked ||
        _previousKeyboard != showKeyboard ||
        activeKeyboardChanged) {
      _previousLocked = isLocked;
      _previousKeyboard = showKeyboard;
      _previousActiveKeyboard = currentVm.activeKeyboard;
      _backend.handleCommand(
        SetMode(isLocked, requestFocus: requestFocus),
      );
    }

    final actionButtons = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Device.isDesktop ? 300 : double.infinity,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (!currentVm.isCurrentNodeSpore()) ...[
              if (!Device.isDesktop) HistoryButton(vm: currentVm),
              DismissButton(vm: currentVm),
              FragmentButton(vm: currentVm),
              SporeButton(vm: currentVm),
              if (!Device.isDesktop)
                KeyboardButton(
                  vm: currentVm,
                  removeFocusAndCursor: removeFocusAndCursor,
                ),
              MoreButton(
                removeFocusAndCursor: () {
                  removeFocusAndCursor();
                },
              ),
            ],
          ],
        ),
      ),
    );

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
                        decoration: currentVm.isCurrentNodeSpore()
                            ? currentVm.noClozeField
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
                            : currentVm.dismissState == true
                            ? BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              )
                            : const BoxDecoration(),
                        child: Focus(
                          focusNode: focusNode,
                          child: _backend.buildWidget(context),
                        ),
                      ),
                    ),
                    if (!kIsWeb)
                      Positioned(
                        bottom: 16,
                        left: 8,
                        right: 8,
                        child: actionButtons,
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (kIsWeb) actionButtons,
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.isDesktop(context)
                  ? MediaQuery.sizeOf(context).width * 0.5
                  : double.infinity,
            ),
            child: ReviewActionBar(
              vm: currentVm,
              focusNode: focusNode,
              reviewNodeId: reviewNodeId,
            ),
          ),
        ],
      ),
    );
  }
}
