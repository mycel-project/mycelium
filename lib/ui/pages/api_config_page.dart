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
  const ApiConfigPage({super.key});
  @override
  State<ApiConfigPage> createState() => _ApiConfigPageState();
}

enum ApiMode { cloud, local }

class _ApiConfigPageState extends State<ApiConfigPage> {
  late final TextEditingController urlController;
  late final TextEditingController tokenController;
  late ApiMode _mode;
  String _lastCustomUrl = "";

  @override
  void initState() {
    super.initState();
    final vm = context.read<ApiViewModel>();
    urlController = TextEditingController(text: vm.baseUrl);
    tokenController = TextEditingController(text: vm.token);

    _mode = (vm.baseUrl == "https://api.mycelcloud.com" || vm.baseUrl.isEmpty)
        ? ApiMode.cloud
        : ApiMode.local;
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
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 64,
              ),
              child: IntrinsicHeight(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: "Mycelium is powered by "),
                            TextSpan(
                              text: "Mycel",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launchUrl(
                                    Uri.parse(
                                      "https://github.com/mycel-project/mycel",
                                    ),
                                  );
                                },
                            ),
                            const TextSpan(text: ".\nSee the "),
                            TextSpan(
                              text: "getting started guide",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launchUrl(
                                    Uri.parse(
                                      "https://mycel-project.com/getting-started.html",
                                    ),
                                  );
                                },
                            ),
                            const TextSpan(text: " for help."),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SegmentedButton<ApiMode>(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>((
                                Set<MaterialState> states,
                              ) {
                                if (states.contains(MaterialState.selected)) {
                                  return Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1);
                                }
                                return null;
                              }),
                        ),
                        segments: const [
                          ButtonSegment(
                            value: ApiMode.cloud,
                            label: Text('MycelCloud'),
                            icon: Icon(Icons.cloud),
                          ),
                          ButtonSegment(
                            value: ApiMode.local,
                            label: Text('Self-hosted'),
                            icon: Icon(Icons.computer),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (Set<ApiMode> newSelection) {
                          final newMode = newSelection.first;
                          if (_mode == newMode) return;

                          setState(() {
                            _mode = newMode;
                          });

                          if (_mode == ApiMode.cloud) {
                            if (urlController.text !=
                                "https://api.mycelcloud.com") {
                              _lastCustomUrl = urlController.text;
                            }
                            urlController.text = "https://api.mycelcloud.com";
                            vm.setUrl("https://api.mycelcloud.com");
                          } else {
                            if (_lastCustomUrl.isNotEmpty) {
                              urlController.text = _lastCustomUrl;
                            } else if (urlController.text ==
                                "https://api.mycelcloud.com") {
                              urlController.clear();
                            }
                            vm.setUrl(urlController.text);
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                      if (_mode == ApiMode.cloud) ...[
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text:
                                    "Connect using your mycelcloud token on your ",
                              ),
                              TextSpan(
                                text: "MycelCloud account",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(
                                      Uri.parse("https://mycelcloud.com"),
                                    );
                                  },
                              ),
                              const TextSpan(text: "."),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: tokenController,
                          decoration: InputDecoration(
                            labelText: "MycelCloud Token",
                            hintText: "Find it on mycelcloud.com",
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.arrow_circle_right_outlined,
                              ),
                              onPressed: () async {
                                vm.setToken(tokenController.text);
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          onSubmitted: (value) => vm.setToken(value),
                        ),
                      ] else ...[
                        const Text(
                          "Connect to your own self-hosted Mycel instance.",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: urlController,
                          decoration: InputDecoration(
                            labelText: "API Base URL",
                            hintText: "http://192.168.1.132:8000",
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.arrow_circle_right_outlined,
                              ),
                              onPressed: () async {
                                vm.setUrl(urlController.text);
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          onSubmitted: (value) => vm.setUrl(value),
                        ),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Connection Status: "),
                          if (vm.isChecking)
                            const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
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
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (vm.mycelCompatibility ==
                            ApiCompatibility.error) ...[
                          const SizedBox(height: 8),
                          const Text(
                            "Could not check Mycel compatibility. Please retry or report this error.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                        if (vm.mycelCompatibility ==
                            ApiCompatibility.incompatible) ...[
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "This Mycel version is not compatible with your current Mycelium version (${vm.myceliumVersion}). See ",
                                  style: const TextStyle(color: Colors.red),
                                ),
                                TextSpan(
                                  text: "compatibility.json",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
                                  text:
                                      " on Mycelium's Github for compatibility details.",
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
                        ),
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
