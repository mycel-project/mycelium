import "package:flutter/material.dart";
import "package:mycelium/core/stores/node_store.dart";
import "package:mycelium/ui/controllers/markdown_controller.dart";
import "package:mycelium/viewmodels/md_editor_view_model.dart";
import 'package:provider/provider.dart';

class MdEditor extends StatefulWidget {
  @override
  _MdEditorState createState() => _MdEditorState();
}

class _MdEditorState extends State<MdEditor> {
  String? content;

  MdEditorViewModel editorVm = MdEditorViewModel();

  late final MarkdownController markdownController;

  void _onNodeChanged() {
    final node = context.read<NodeStore>().currentNode;
    final content = node?.content?["0"] ?? "";
    markdownController.text = content;
    FocusManager.instance.primaryFocus?.unfocus();
  }
  
  @override
  void initState() {
    super.initState();

    markdownController = MarkdownController();
    final nodeStore = context.read<NodeStore>();
    nodeStore.addListener(_onNodeChanged);
  }

  @override
  void dispose() {
    context.read<NodeStore>().removeListener(_onNodeChanged);
    markdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.only(left: 16, right: 16),
            child: TextField(
              maxLines: null,
              expands: true,
              controller: markdownController,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
          // Positioned(
          //   bottom: 40,
          //   right: 30,
          //   child: FloatingActionButton(
          //     child: Icon( Icons.edit),
          //   ),
          // ),
        ],
      ),
    );
  }
}
