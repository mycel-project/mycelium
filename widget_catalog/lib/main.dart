import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:mycelium/ui/widgets/app_bar.dart';
import 'main.directories.g.dart';

void main() => runApp(const WidgetbookApp());

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [DeviceFrameAddon(devices: Devices.all)],
    );
  }
}

@widgetbook.UseCase(name: "Default", type: MyAppBar)
Widget myAppBar(BuildContext context) {
  return Scaffold(
    appBar: MyAppBar(
      titleText: "yo",
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
    ),
    body: Container(),
  );
}

