import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:mycelium/ui/layouts/adptative_scaffold.dart';
import 'main.directories.g.dart';

void main() => runApp(const WidgetbookApp());

List<ActivityAction> activityActions = [
  ActivityAction(
    icon: Icons.import_contacts_sharp,
    tooltip: "test",
    onTap: () {},
  ),
  ActivityAction(icon: Icons.fax_rounded, tooltip: "test", onTap: () {}),
  ActivityAction(icon: Icons.ten_k, tooltip: "test", onTap: () {}),
  ActivityAction(
    icon: Icons.import_contacts_sharp,
    tooltip: "test",
    onTap: () {},
  ),
  ActivityAction(icon: Icons.fax_rounded, tooltip: "test", onTap: () {}),
  ActivityAction(icon: Icons.ten_k, tooltip: "test", onTap: () {}),
  ActivityAction(
    icon: Icons.import_contacts_sharp,
    tooltip: "test",
    onTap: () {},
  ),
  ActivityAction(icon: Icons.fax_rounded, tooltip: "test", onTap: () {}),
];

List<AdaptativeElement> adaptativeElements = [
  AdaptativeElement(
    icon: Icons.leaderboard_rounded,
    tooltip: "learn",
    onTap: () {},
    desktopPosition: DesktopPosition.topBarRight,
    mobilePosition: MobilePosition.appBarRight
  ),
  AdaptativeElement(
    icon: Icons.ten_k_outlined,
    tooltip: "example",
    onTap: () {},
    desktopPosition: DesktopPosition.topBarLeft,
    mobilePosition: MobilePosition.burger
  ),
  AdaptativeElement(
    icon: Icons.chevron_left,
    tooltip: "nav",
    onTap: () {},
    desktopPosition: DesktopPosition.topBarLeft,
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

@widgetbook.UseCase(name: "Desktop", type: AdaptativeScaffold)
Widget adaptativeScaffold(BuildContext context) {
  return AdaptativeScaffold(
    body: Container(color: Colors.blue),
    leftPannel: Container(color: Colors.red),
    rightPannel: Container(color: Colors.red),
    activityActions: activityActions,
    adaptativeElements: adaptativeElements,
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
    adaptativeElements: adaptativeElements,
  );
}
