import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/outline_entry.dart';
import 'package:mycelium/ui/widgets/adaptative_sheet.dart';
import 'package:mycelium/ui/widgets/confirmation_dialog.dart';
import 'package:mycelium/ui/widgets/heading_splitter.dart';
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
    return Tooltip(
      message: 'Dismiss',
      child: FloatingActionButton(
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
      ),
    );
  }
}

class FragmentButton extends StatelessWidget {
  final MdEditorViewModel vm;
  const FragmentButton({
    super.key,
    required this.vm,
  });

  Future<Node?> _createFragment(BuildContext context) async {
    final extract = await vm.createFragment(vm.content);
    if (!context.mounted || extract is! Node) return null;
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
        onSecondaryTap: Device.isDesktop && vm.hasSelection
            ? () async => await _onSecondary(context)
            : null,
        onLongPress: !Device.isDesktop && vm.hasSelection
            ? () async {
                HapticFeedback.mediumImpact();
                await _onSecondary(context);
              }
            : null,
        child: FloatingActionButton(
          heroTag: "fab_fragment",
          onPressed: vm.hasSelection
              ? () async => await _createFragment(context)
              : null,
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
  const SporeButton({
    super.key,
    required this.vm,
  });

  Future<Node?> _createSpore(BuildContext context) async {
    final extract = await vm.createSpore(vm.content);
    if (!context.mounted || extract is! Node) return null;
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
        onSecondaryTap: Device.isDesktop && vm.hasSelection
            ? () async => await _onSecondary(context)
            : null,
        onLongPress: !Device.isDesktop && vm.hasSelection
            ? () async {
                HapticFeedback.mediumImpact();
                await _onSecondary(context);
              }
            : null,
        child: FloatingActionButton(
          heroTag: "fab_spore",
          onPressed: vm.hasSelection
              ? () async => await _createSpore(context)
              : null,
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
        if (vm.activeKeyboard) FocusScope.of(context).unfocus();
        vm.toggleKeyboard();
      },
      child: vm.activeKeyboard
          ? const Icon(Icons.keyboard_hide)
          : const Icon(Icons.keyboard),
    );
  }
}

class MoreButton extends StatelessWidget {
  final MdEditorViewModel vm;
  final VoidCallback removeFocusAndCursor;

  const MoreButton({
    super.key,
    required this.vm,
    required this.removeFocusAndCursor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "fab_more",
      child: const Icon(Icons.more_vert),
      onPressed: () {
        // Snapshot of the state when the menu is opened
        final currentCursor = vm.cursorPosition;
        final currentSelection = vm.selection;
        final content = vm.content;
        final hasSel = vm.hasSelection;
        
        showAdaptiveSheet(
          context: context,
          child: MoreBottomSheet(
            hasSelection: hasSel,
            onDeleteBeforeCursor: currentCursor == null ? null : () async {
              await vm.deleteBeforeCursor(content, currentCursor);
            },
            onDeleteAfterCursor: currentCursor == null ? null : () async {
              await vm.deleteAfterCursor(content, currentCursor);
            },
            onRemoveLinks: () async {
              final sel = hasSel ? currentSelection : null;
              await vm.removeLinks(content, sel);
              removeFocusAndCursor();
            },
            onSplitFragment: () async {
              List<OutlineEntry>? outline = await vm.getCurrentOutline();
              if (!context.mounted) return;
              await showHeadingSplitter(
                context,
                outline: outline,
                onConfirm: (int level) async {
                  final result = await vm.splitNode(level);
                  if (result == true) {
                    await vm.refreshCurrentNode();
                  }
                },
              );
            },
            onDeleteFragment: () async {
              final result = await ConfirmationDialog.show(
                context,
                title: "Delete confirmation",
                text: "Delete this fragment and all its children?",
                destructive: true,
              );
              if (result.confirmed == true) await vm.deleteNode();
            },
          ),
        );
      },
    );
  }
}

class MoreBottomSheet extends StatelessWidget {
  final bool hasSelection; 
  final Future<void> Function()? onDeleteBeforeCursor;
  final Future<void> Function()? onDeleteAfterCursor;
  final Future<void> Function() onRemoveLinks;
  final Future<void> Function() onSplitFragment;
  final Future<void> Function() onDeleteFragment;

  const MoreBottomSheet({
    super.key,
    required this.hasSelection,
    this.onDeleteBeforeCursor,
    this.onDeleteAfterCursor,
    required this.onRemoveLinks,
    required this.onSplitFragment,
    required this.onDeleteFragment,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            enabled: onDeleteBeforeCursor != null,
            leading: const Icon(Icons.backspace),
            title: const Text('Delete all content before cursor'),
            onTap: onDeleteBeforeCursor == null ? null : () async {
              await onDeleteBeforeCursor!();
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
          ListTile(
            enabled: onDeleteAfterCursor != null,
            leading: Transform.flip(
              flipX: true,
              child: const Icon(Icons.backspace),
            ),
            title: const Text('Delete all content after cursor'),
            onTap: onDeleteAfterCursor == null ? null : () async {
              await onDeleteAfterCursor!();
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.link_off),
            title: hasSelection
                ? const Text('Remove link formatting in selection')
                : const Text('Remove all link formatting'),
            onTap: () async {
              await onRemoveLinks();
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.splitscreen),
            title: const Text('Split fragment'),
            onTap: () async {
              await onSplitFragment();
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete this fragment'),
            onTap: () async {
              await onDeleteFragment();
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
