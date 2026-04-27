import 'package:flutter/material.dart';
import 'package:mycelium/ui/render/block_renderer.dart';

class ListRenderer extends BlockRenderer {
  const ListRenderer();

  @override
  RegExp get regex => RegExp(
    r'^([ ]{0,3})(?:'
    r'(\d{1,9})([.)])|'
    r'([-+*])'
    r')[ \t]+(.+)$',
  );

  @override
  TextSpan build(String block) {
    final match = regex.firstMatch(block);

    if (match == null) {
      return TextSpan(text: block);
    }

    final indent = match.group(1) ?? '';
    final orderedNumber = match.group(2);
    final unorderedMarker = match.group(4);
    final content = match.group(5) ?? '';

    final isOrdered = orderedNumber != null;

    return TextSpan(
      children: [
        TextSpan(text: indent), 

        TextSpan(
          text: isOrdered ? "$orderedNumber. " : "• ",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.grey.shade500,
          ),
        ),

        TextSpan(text: content),
      ],
    );
  }
}
