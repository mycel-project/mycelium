import "package:flutter/material.dart";
import "package:mycelium/ui/pages/api_config_page.dart";

class ApiNotReachableWidget extends StatelessWidget {
  const ApiNotReachableWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              "Mycel API must be configured.",
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ApiConfigPage()),
            ),
            child: const Text("Open API configuration"),
          ),
        ],
      ),
    );
  }
}
