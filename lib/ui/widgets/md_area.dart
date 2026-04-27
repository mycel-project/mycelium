import "package:flutter/material.dart";
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class MdArea extends StatefulWidget {
  @override
  _MdAreaState createState() => _MdAreaState();

  String content;
  final VoidCallback selectionCallback;
  final ScrollController scrollController;

  MdArea({
    super.key,
    required this.content,
    required this.selectionCallback,
    required this.scrollController,
  });
}

class _MdAreaState extends State<MdArea> {
  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: widget.content,
      controller: widget.scrollController,
      selectable: true,
      onTapText: () {
        print("Tap");
      },
      onSelectionChanged: (text, selection, cause) {
        print("Selection");
        widget.selectionCallback();
      },
    );
  }
}
