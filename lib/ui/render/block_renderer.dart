import 'package:flutter/material.dart';

abstract class BlockRenderer {
  const BlockRenderer();

  RegExp get regex;
  
  bool canBuild(String block) {
    final match = regex.firstMatch(block);
    if (match == null) {
      return false;
    } else {
      return true;
    }
  }

  TextSpan build(String block);
}
