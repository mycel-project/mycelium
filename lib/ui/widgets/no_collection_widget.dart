import "package:flutter/material.dart";
import "package:mycelium/ui/pages/collections_page.dart";

class NoCollectionWidget extends StatelessWidget {
  const NoCollectionWidget({super.key}); 

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.all(32),
              child: Text(
                "No collection selected yet.\nCreate one or pick an existing one to get started.",
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CollectionsPage()),
                );
              },
              child: Text("Collections manager"),
            ),
          ],
        ),
      ),
    );
  }
}
