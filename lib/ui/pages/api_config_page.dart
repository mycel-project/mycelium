import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/ui/pages/home_page.dart';
import 'package:mycelium/ui/widgets/app_bar.dart';
import 'package:mycelium/viewmodels/api_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class ApiConfigPage extends StatefulWidget {
  @override
  State<ApiConfigPage> createState() => _ApiConfigPageState();
}

class _ApiConfigPageState extends State<ApiConfigPage> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: context.read<ApiViewModel>().baseUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ApiViewModel>();
    final store = context.watch<ApiStore>();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: MyAppBar(titleText: "Api Configuration"),
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(64),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 128,
              ),
              child: IntrinsicHeight(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: "Mycelium is powered by "),
                            TextSpan(
                              text: "Mycel",
                              style: TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launchUrl(
                                    Uri.parse(
                                      "https://github.com/mycel-project/mycel",
                                    ),
                                  );
                                },
                            ),
                            TextSpan(
                              text:
                                  ".\n\nPlease enter your API endpoint below to connect Mycelium to an active Mycel instance (MycelCloud or self-hosted).",
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 48),
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: "API Base URL",
                          hintText: "http://192.168.1.10:8000",
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_circle_right_outlined),
                            onPressed: () async {
                              await vm.setUrl(controller.text);
                              if (store.apiStatus == ApiStatus.reachable) {
                                if (!context.mounted) return;
                                FocusScope.of(context).unfocus();
                              }
                            },
                          ),
                        ),
                        onSubmitted: (value) => vm.setUrl(value),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Connection Status: "),
                          if (vm.isChecking)
                            const CircularProgressIndicator()
                          else
                            Icon(
                              switch (store.apiStatus) {
                                ApiStatus.unknown ||
                                ApiStatus.emptyUrl => Icons.help,
                                ApiStatus.reachable => Icons.check,
                                ApiStatus.unreachable => Icons.cancel,
                              },
                              color: switch (store.apiStatus) {
                                ApiStatus.unknown ||
                                ApiStatus.emptyUrl => Colors.grey,
                                ApiStatus.reachable => Colors.green,
                                ApiStatus.unreachable => Colors.red,
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      if (store.apiStatus == ApiStatus.reachable)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => HomePage()),
                              (route) => false,
                            );
                          },
                          child: Text("Go to home page"),
                        )
                      else if (store.apiStatus == ApiStatus.unreachable)
                        _buildDebugHelp(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ClaudeAI formatting
Widget _buildDebugHelp(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSection(
        context,
        title: "General",
        tips: [(Icons.wifi, "Make sure your device has internet access")],
      ),
      const SizedBox(height: 12),
      _buildSection(
        context,
        title: "Self-hosted",
        tips: [
          (
            Icons.terminal,
            "Make sure Mycel is currently running on your server",
          ),
          (Icons.lan, "Server must be reachable on the same network"),
          (Icons.security, "Check that no firewall blocks the port"),
        ],
      ),
    ],
  );
}

Widget _buildSection(
  BuildContext context, {
  required String title,
  required List<(IconData, String)> tips,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        ...tips.map((tip) => _debugTip(tip.$1, tip.$2)),
      ],
    ),
  );
}

Widget _debugTip(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    ),
  );
}
