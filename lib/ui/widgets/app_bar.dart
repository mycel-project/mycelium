import 'package:flutter/material.dart';
import 'package:mycelium/utils/device.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final List<Widget>? actions;
  final Widget? leading;

  const MyAppBar({super.key, required this.titleText, this.actions, this.leading});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      automaticallyImplyLeading: leading == null,
      centerTitle: true,
      title: Text(titleText),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      actions: actions == null ? null : [...actions!, SizedBox(width: Device.isDesktop ? 0 : 8)],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
