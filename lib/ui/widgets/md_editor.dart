import "package:flutter/material.dart";
import "package:mycelium/ui/controllers/markdown_controller.dart";
import "package:mycelium/ui/widgets/md_area.dart";
import "package:mycelium/viewmodels/md_editor_view_model.dart";

class MdEditor extends StatefulWidget {
  @override
  _MdEditorState createState() => _MdEditorState();
}

class _MdEditorState extends State<MdEditor> {
  String content =
      "# Salut\n ça marche!\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Cras mollis commodo metus finibus tincidunt.";

  MdEditorViewModel editorVm = MdEditorViewModel();

  late final MarkdownController markdownController;
  late final ScrollController scrollController;
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    markdownController = MarkdownController();
    scrollController = ScrollController();
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
              scrollController: scrollController,
              controller: markdownController,
              focusNode: focusNode,
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
