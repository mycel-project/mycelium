import "package:flutter/material.dart";
import "package:mycelium/ui/widgets/app_bar.dart";
import 'package:provider/provider.dart';
import 'package:mycelium/core/stores/app_store.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final version = context.watch<AppStore>().version;

    return Scaffold(
      appBar: const MyAppBar(titleText: "About"),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Mycelium",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "version: $version",
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
