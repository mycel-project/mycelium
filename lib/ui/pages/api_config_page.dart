import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/domain/api_compatibility.dart';
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
  late final TextEditingController urlController;
  late final TextEditingController tokenController;

  @override
  void initState() {
    super.initState();
    urlController = TextEditingController(
      text: context.read<ApiViewModel>().baseUrl,
    );
    tokenController = TextEditingController(
      text: context.read<ApiViewModel>().token,
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
                              style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
                        controller: urlController,
                        decoration: InputDecoration(
                          labelText: "API Base URL",
                          hintText: "https://api.mycelcloud.com",
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_circle_right_outlined),
                            onPressed: () async {
                              vm.setUrl(urlController.text);
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                        onSubmitted: (value) => vm.setUrl(value),
                      ),
                      urlController.text == "https://api.mycelcloud.com"
                      ?
                      TextField(
                        controller: tokenController,
                        decoration: InputDecoration(
                          labelText: "MycelCloud Token",
                          hintText: "Find it on mycelcloud.com",
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_circle_right_outlined),
                            onPressed: () async {
                              vm.setToken(tokenController.text);
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                        onSubmitted: (value) => vm.setToken(value),
                      )
                      :
                      const SizedBox(),
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
                                ApiStatus.emptyUrl => Icons.circle,
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
                      if (vm.mycelVersion != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Mycel version: ${vm.mycelVersion}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary
                          ),
                        ),
                        if (vm.mycelCompatibility == ApiCompatibility.error) ...[
                          const SizedBox(height: 8),
                          const Text(
                            "Could not check Mycel compatibility. Please retry or report this error.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                        if (vm.mycelCompatibility == ApiCompatibility.incompatible) ...[
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "This Mycel version is not compatible with your current Mycelium version (${vm.myceliumVersion}). See ",
                                  style: const TextStyle(color: Colors.red),
                                ),
                                TextSpan(
                                  text: "compatibility.json",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(
                                      Uri.parse(
                                        "https://github.com/mycel-project/mycelium/blob/main/compatibility.json",
                                      ),
                                    );
                                  },
                                ),
                                const TextSpan(
                                  text: " on Mycelium's Github for compatibility details.",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                      const SizedBox(height: 36),
                      if (store.apiStatus == ApiStatus.reachable)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => HomePage()),
                              (route) => false,
                            );
                          },
                          child: const Text("Go to home page"),
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
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
