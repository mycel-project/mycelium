import 'package:flutter/material.dart';
import 'package:mycelium/ui/render/blockquote_renderer.dart';
import 'package:mycelium/ui/render/registry.dart';

class MarkdownController extends TextEditingController {
  final blockRegistry = BlockRegistry();
  final blockQuoteRenderer = BlockQuoteRenderer();

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle =
        style ?? const TextStyle(fontSize: 16, color: Colors.black);

    final parts = <InlineSpan>[];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final rawLine = lines[i];

      String line = "";
      String quoteStart = "";

      final match = RegExp(r'^(\s*>+\s*)').firstMatch(rawLine);

      if (match != null) {
        quoteStart = match.group(1)!;
        line = rawLine.replaceFirst(RegExp(r'^\s*>+\s*'), '');
      } else {
        line = rawLine;
      }

      bool matched = false;
      TextSpan built = const TextSpan(text: "");

      for (final renderer in blockRegistry.renderers) {
        if (renderer.canBuild(line)) {
          built = renderer.build(line);
          matched = true;
          break;
        }
      }

      if (!matched) {
        built = TextSpan(text: line);
      }

      if (quoteStart.isEmpty) {
        parts.add(built);
      } else {
        parts.add(blockQuoteRenderer.wrap(built, quoteStart));
      }

      if (i != lines.length - 1) {
        parts.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(style: baseStyle, children: parts);
  }
}
