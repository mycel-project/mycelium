import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:mycelium/ui/widgets/app_bar.dart';
import 'package:mycelium/ui/layouts/adptative_scaffold.dart';
import 'package:mycelium/ui/layouts/editor_layout.dart';
import 'main.directories.g.dart';

void main() => runApp(const WidgetbookApp());

List<ActivityAction> activityActions = [
  ActivityAction(
    icon: Icons.import_contacts_sharp,
    tooltip: "test",
    onTap: () {},
  ),
  ActivityAction(
    icon: Icons.fax_rounded,
    tooltip: "test",
    onTap: () {},
  ),
  ActivityAction(
    icon: Icons.ten_k,
    tooltip: "test",
    onTap: () {},
  ),
    ActivityAction(
    icon: Icons.import_contacts_sharp,
    tooltip: "test",
    onTap: () {},
  ),
  ActivityAction(
    icon: Icons.fax_rounded,
    tooltip: "test",
    onTap: () {},
  ),
  ActivityAction(
    icon: Icons.ten_k,
    tooltip: "test",
    onTap: () {},
  ),
    ActivityAction(
    icon: Icons.import_contacts_sharp,
    tooltip: "test",
    onTap: () {},
  ),
  ActivityAction(
    icon: Icons.fax_rounded,
    tooltip: "test",
    onTap: () {},
  ),
];

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

@widgetbook.UseCase(name: "Desktop", type: AdaptativeScaffold)
Widget adaptativeScaffold(BuildContext context) {

  return AdaptativeScaffold(
    body: Container(color: Colors.blue),
    leftPannel: Container(color: Colors.red),
    rightPannel: Container(color: Colors.red),
    activityActions: activityActions,
    desktopTopBar: Container(color: Colors.yellow),
  );
}

@widgetbook.UseCase(name: "Mobile", type: AdaptativeScaffold)
Widget adaptativeScaffoldMobile(BuildContext context) {
  return AdaptativeScaffold(
    body: Container(color: Colors.blue),
    leftPannel: Container(color: Colors.red),
    rightPannel: Container(color: Colors.red),
    activityActions: activityActions,
    overrideIsDesktop: false,
    mobileAppBar: AppBar(),
  );
}

@widgetbook.UseCase(name: "Default", type: EditorLayout)
Widget editorLayout(BuildContext context) {
  return Scaffold(
    body: EditorLayout(
      body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: const Center(child: Text("Mon éditeur")),
        ),
    )
  );
}

