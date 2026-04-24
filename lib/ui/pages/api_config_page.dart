import 'package:flutter/material.dart';
import 'package:mycelium/core/app_config.dart';
import 'package:provider/provider.dart';

class ApiConfigPage extends StatefulWidget {
  @override
  State<ApiConfigPage> createState() => _ApiConfigPageState();
}

class _ApiConfigPageState extends State<ApiConfigPage> {
  late final TextEditingController controller;
  late final AppConfig config;

  @override
  void initState() {
    super.initState();

    config = context.read<AppConfig>();

    controller = TextEditingController(text: config.baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "API Base URL",
              ),
              onSubmitted: (value) {
                config.setBaseUrl(value); // ✔ ici
              },
            ),
          ],
        ),
      ),
    );
  }
}
