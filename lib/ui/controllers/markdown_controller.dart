import 'package:flutter/material.dart';
import "package:markdown_mycel_fork/markdown.dart";

class MarkdownController extends TextEditingController {
  // Never change text or value here, it's just for visual rendering

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle =
        style ?? const TextStyle(fontSize: 16, color: Colors.black);

    final (markdown, ast) = markdownToFormattedMarkdown(
      text,
      blockSyntaxes: [
        // No EmptyBlockSyntax() to convert it as paragraph and make it editable
        HeaderSyntax(),
        const BlockquoteSyntax(),
        ParagraphSyntax(),
      ], // Be careful with order, see block_parser.dart
      inlineSyntaxes: [
        // LineBreakSyntax(),
        LinkSyntax(),
        EmphasisSyntax.asterisk(),
        CodeSyntax(),
        // SoftLineBreakSyntax(),
        // EscapeSyntax(),
      ],
      withDefaultBlockSyntaxes: false,
      withDefaultInlineSyntaxes: false,
    );

    return TextSpan(children: markdown, style: baseStyle);
  }
}
