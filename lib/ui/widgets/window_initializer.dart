import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowInitializer extends StatefulWidget {
  final Widget child;
  const WindowInitializer({super.key, required this.child});

  @override
  State<WindowInitializer> createState() => _WindowInitializerState();
}

class _WindowInitializerState extends State<WindowInitializer> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.maximize();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
