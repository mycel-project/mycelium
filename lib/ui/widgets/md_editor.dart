import "package:flutter/material.dart";
import "package:mycelium/core/stores/node_store.dart";
import "package:mycelium/core/stores/review_store.dart";
import "package:mycelium/ui/controllers/markdown_controller.dart";
import "package:mycelium/viewmodels/md_editor_view_model.dart";
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MdEditorViewModel>();
    final nodeReviewId = context.watch<ReviewStore>().currentReviewNodeId;
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: TextField(
              maxLines: null,
              expands: true,
              controller: markdownController,
              onChanged: (value) {
                vm.updateContent(value);
              },
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 30,
            child: FloatingActionButton(
              onPressed: vm.isDirty ? vm.saveContent : null,
              child: Opacity(
                opacity: vm.isDirty ? 1.0 : 0.4,
                child: const Icon(Icons.save),
              ),
            ),
          ),
          (nodeReviewId == vm.node?.id) ? Text("Reviewing") : Text("Not reviewing")
        ],
      ),
    );
  }
}
