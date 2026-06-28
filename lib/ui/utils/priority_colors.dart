import 'package:flutter/material.dart';

Color getPriorityColor(double priority) {
  final double clamped = priority.clamp(0.0, 100.0);
  final double t = clamped / 100.0;

  const List<Color> spectrum = [
    Colors.purple,
    Colors.indigo,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red,
  ];

  if (t >= 1.0) return spectrum.last;
  if (t <= 0.0) return spectrum.first;

  final int segmentCount = spectrum.length - 1;
  final double scaledT = t * segmentCount;
  final int index = scaledT.floor();
  final double localT = scaledT - index;

  return Color.lerp(spectrum[index], spectrum[index + 1], localT) ??
      spectrum[index];
}
