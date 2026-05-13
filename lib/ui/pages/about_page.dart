import "package:flutter/material.dart";
import "package:mycelium/ui/widgets/app_bar.dart";
import 'package:mycelium/viewmodels/about_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AboutViewModel>();

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
                "Current version: ${vm.version}",
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              Image.asset(
                "assets/full.png",
                height: 160,
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      vm.reloadLastUpdate();
                    },
                    icon: Icon(
                      Icons.refresh,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: "Reload latest version",
                    splashRadius: 22,
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                  Text(
                    "Last available version: ${vm.lastVersion ?? '-'}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "To download the latest version:",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  TextButton.icon(
                    onPressed: () {
                      launchUrl(
                        Uri.parse(
                          "https://mycel-project.github.io/download.html",
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.open_in_new,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      "Mycel Project",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
