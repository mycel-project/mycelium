import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/ui/widgets/adaptative_sheet.dart';
import 'package:mycelium/ui/widgets/confirmation_dialog.dart';
import 'package:mycelium/ui/widgets/priority_selector.dart';
import 'package:mycelium/utils/device.dart';
import 'package:mycelium/viewmodels/md_editor_viewmodel.dart';
import 'package:provider/provider.dart';

class HistoryButton extends StatelessWidget {
  final MdEditorViewModel vm;
  const HistoryButton({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: vm.toggleHistoryMode,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton(
            heroTag: "fab_history",
            onPressed: vm.canPerformHistoryAction
                ? vm.performHistoryAction
                : null,
            child: Opacity(
              opacity: vm.canPerformHistoryAction ? 1.0 : 0.4,
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
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                vm.historyButtonMode == ActionMode.undo
                    ? Icons.redo
                    : Icons.undo,
                size: 11,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DismissButton extends StatelessWidget {
  final MdEditorViewModel vm;
  const DismissButton({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "fab_dismiss",
      onPressed: vm.dismissState == true
          ? () async => await vm.toggleDismiss()
          : () async {
              FocusScope.of(context).unfocus();
              final result = await ConfirmationDialog.show(
                context,
                title: "Confirmation",
                text:
                    "Have you extracted all the relevant information from this fragment?\n\nIt won’t be shown again in future reviews.",
              );
              if (result.confirmed == true) {
                if (!vm.hasChildren()) {
                  if (!context.mounted) return;
                  final result = await ConfirmationDialog.show(
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
    );
  }
}

class FragmentButton extends StatelessWidget {
  final MdEditorViewModel vm;
  final TextEditingController markdownController;
  const FragmentButton({
    super.key,
    required this.vm,
    required this.markdownController,
  });

  Future<Node?> _createFragment(BuildContext context) async {
    final extract = await vm.createFragment(markdownController.text);
    if (!context.mounted || extract is! Node) return null;
    markdownController.selection = const TextSelection.collapsed(offset: -1);
    FocusScope.of(context).unfocus();
    return extract;
  }

  Future<void> _onSecondary(BuildContext context) async {
    final extract = await _createFragment(context);
    if (extract is Node && context.mounted) {
      await showPriorityPicker(
        context,
        title: "Prioritize created extract",
        nodes: vm.getNodes(),
        currentNodeId: extract.id,
        onRefresh: vm.refreshPriorities,
        onUpdate: vm.updatePriority,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: Device.isDesktop
      ? 'Create fragment (right-click for direct priorization)'
      : 'Create fragment (hold for direct priorization)',
      child: GestureDetector(
        onSecondaryTap: Device.isDesktop && vm.hasSelection ? () async => await _onSecondary(context) : null,
        onLongPress: !Device.isDesktop && vm.hasSelection
        ? () async {
          HapticFeedback.mediumImpact();
          await _onSecondary(context);
        }
        : null,
        child: FloatingActionButton(
          heroTag: "fab_fragment",
          onPressed: vm.hasSelection ? () async => await _createFragment(context) : null,
          child: Opacity(
            opacity: vm.hasSelection ? 1.0 : 0.4,
            child: const Icon(Icons.content_cut),
          ),
        ),
      ),
    );
  }
}

class SporeButton extends StatelessWidget {
  final MdEditorViewModel vm;
  final TextEditingController markdownController;
  const SporeButton({
      super.key,
      required this.vm,
      required this.markdownController,
  });

  Future<Node?> _createSpore(BuildContext context) async {
    final extract = await vm.createSpore(markdownController.text);
    if (!context.mounted || extract is! Node) return null;
    markdownController.selection = const TextSelection.collapsed(offset: -1);
    FocusScope.of(context).unfocus();
    return extract;
  }

  Future<void> _onSecondary(BuildContext context) async {
    final spore = await _createSpore(context);
    if (spore is Node && context.mounted) {
      await showPriorityPicker(
        context,
        title: "Prioritize created extract",
        nodes: vm.getNodes(),
        currentNodeId: spore.id,
        onRefresh: vm.refreshPriorities,
        onUpdate: vm.updatePriority,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: Device.isDesktop
      ? 'Create spore (right-click for direct priorization)'
      : 'Create spore (hold for direct priorization)',
      child: GestureDetector(
        onSecondaryTap: Device.isDesktop && vm.hasSelection ? () async => await _onSecondary(context) : null,
        onLongPress: !Device.isDesktop && vm.hasSelection
        ? () async {
          HapticFeedback.mediumImpact();
          await _onSecondary(context);
        }
        : null,
        child: FloatingActionButton(
          heroTag: "fab_spore",
          onPressed: vm.hasSelection ? () async => await _createSpore(context) : null,
          child: Opacity(
            opacity: vm.hasSelection ? 1.0 : 0.4,
            child: const Icon(Icons.quiz),
          ),
        ),
      ),
    );
  }
}

class KeyboardButton extends StatelessWidget {
  final MdEditorViewModel vm;
  final VoidCallback removeFocusAndCursor;
  const KeyboardButton({
    super.key,
    required this.vm,
    required this.removeFocusAndCursor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "fab_keyboard",
      onPressed: () {
        if (vm.activeKeyboard) removeFocusAndCursor();
        vm.toggleKeyboard();
      },
      child: vm.activeKeyboard
          ? const Icon(Icons.keyboard_hide)
          : const Icon(Icons.keyboard),
    );
  }
}

class MoreButton extends StatelessWidget {
  final TextEditingController markdownController;
  final Function removeFocusAndCursor;
  final ScrollController scrollController;

  const MoreButton({
    super.key,
    required this.markdownController,
    required this.removeFocusAndCursor,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "fab_more",
      child: const Icon(Icons.more_vert),
      onPressed: () {
        showAdaptiveSheet(
          context: context,
          child: MoreBottomSheet(
            markdownController: markdownController,
            removeFocusAndCursor: removeFocusAndCursor,
            scrollController: scrollController,
          ),
        );
      },
    );
  }
}

class MoreBottomSheet extends StatelessWidget {
  final TextEditingController markdownController;
  final Function removeFocusAndCursor;
  final ScrollController scrollController;
  const MoreBottomSheet({
    super.key,
    required this.markdownController,
    required this.removeFocusAndCursor,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MdEditorViewModel>();
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            enabled: vm.hasCursor,
            leading: const Icon(Icons.backspace),
            title: const Text('Delete all content before cursor'),
            onTap: () async {
              await vm.deleteBeforeCursor(markdownController.text);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
          ListTile(
            enabled: vm.hasCursor,
            leading: Transform.flip(
              flipX: true,
              child: const Icon(Icons.backspace),
            ),
            title: const Text('Delete all content after cursor'),
            onTap: () async {
              await vm.deleteAfterCursor(markdownController.text);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Transform.flip(
              flipX: true,
              child: const Icon(Icons.link_off),
            ),
            title: vm.hasSelection
                ? const Text('Remove link formatting in selection')
                : const Text('Remove all link formatting'),
                onTap: () async {
                  final double ratio = scrollController.offset / scrollController.position.maxScrollExtent;
                  await vm.removeLinks(markdownController.text);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                      scrollController.jumpTo(ratio * scrollController.position.maxScrollExtent);
                  });
                  removeFocusAndCursor();
                },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete this fragment'),
            onTap: () async {
              final result = await ConfirmationDialog.show(
                context,
                title: "Delete confirmation",
                text: "Delete this fragment and all its children?",
                destructive: true,
              );
              if (!context.mounted) return;
              if (result.confirmed == true) await vm.deleteNode();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
