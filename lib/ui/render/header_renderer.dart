import 'package:flutter/material.dart';
import 'package:mycelium/ui/render/block_renderer.dart';

class HeaderRenderer extends BlockRenderer {
  const HeaderRenderer();

  @override
  RegExp get regex => RegExp(r'^(#{1,6})\s+');

  @override
  TextSpan build(String block) {
    final match = regex.firstMatch(block);

    if (match == null) {
      return TextSpan(text: block);
    }

    final hashes = match.group(1)!;
    final level = hashes.length;

    return TextSpan(
      children: [
        TextSpan(
          text: block,
          style: TextStyle(
            fontSize: 28 - (level * 2),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
