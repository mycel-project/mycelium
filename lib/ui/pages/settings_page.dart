import 'package:flutter/material.dart';
import 'package:mycelium/ui/widgets/api_status_dot_widget.dart';
import 'package:mycelium/ui/widgets/app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        titleText: "Settings",
        actions: [
          ApiStatusDotWidget(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          
        ),
      ),
    );
  }
}

