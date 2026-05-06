import "package:flutter/material.dart";
import "package:mycelium/ui/pages/api_config_page.dart";

class ApiNotReachableWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(),
                  children: [
                    const TextSpan(
                      text:
                          "Mycel API is not reachable.\n\n"
                          "You can retry by tapping the ",
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.error, size: 18, color: Colors.red),
                    ),
                    const TextSpan(
                      text:
                          " icon in the app bar, or view more information in the API configuration screen.",
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ApiConfigPage()),
                );
              },
              child: Text("API configuration"),
            ),
          ],
        ),
      ),
    );
  }
}
