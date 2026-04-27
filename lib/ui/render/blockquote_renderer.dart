import 'package:flutter/material.dart';
import 'package:mycelium/ui/render/block_renderer.dart';

class BlockQuoteRenderer extends BlockRenderer {
  const BlockQuoteRenderer();

  @override
  RegExp get regex => RegExp('^>+\\s+');

  @override
  TextSpan build(String block) {
    final match = regex.firstMatch(block);

    if (match == null) {
      return TextSpan(text: block);
    }
    
    return TextSpan(
      text: block,
      style: TextStyle(
        color: Colors.grey,
        fontStyle: FontStyle.italic,
        fontSize: 16,
      ),
    );
  }

  TextSpan wrap(TextSpan child, String quoteStart) {
    // Specific to blockquote because it can embed block markdown
    return TextSpan(
      style: TextStyle(
        color: Colors.grey.shade400,
        fontStyle: FontStyle.italic,
      ),
      children: [
        TextSpan(text: quoteStart),
        child,
      ],
    );
  }
}
