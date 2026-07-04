import "package:flutter/material.dart";
import "package:mycelium/ui/pages/api_config_page.dart";

class ApiNotReachableWidget extends StatelessWidget {
  const ApiNotReachableWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Opacity(
            opacity: 0.15,
            child: Image.asset(
              "assets/full.png",
              height: 200,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  "Connect to Mycel to begin:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    shadows: const [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.white,
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        blurRadius: 5,
                        color: Colors.white,
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        blurRadius: 2,
                        color: Colors.white70,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ApiConfigPage()),
                ),
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(color: Colors.white70, width: 0),
                ),
                child: const Text("Mycel API configuration"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
