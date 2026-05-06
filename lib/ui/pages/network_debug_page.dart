import "package:flutter/material.dart";
import "package:mycelium/core/debug/network_logger.dart";
import "package:mycelium/ui/widgets/api_status_dot_widget.dart";
import "package:mycelium/ui/widgets/app_bar.dart";
import "package:provider/provider.dart";

class NetworkDebugPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logs = context.watch<NetworkLogger>().logs;
    return Scaffold(
      appBar: MyAppBar(
        titleText:"Network Debug",
        actions: [
          ApiStatusDotWidget()
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            String formatTime(DateTime t) =>
            "${t.hour.toString().padLeft(2, '0')}:"
            "${t.minute.toString().padLeft(2, '0')}:"
            "${t.second.toString().padLeft(2, '0')}";
            final log = logs[index];
            return ListTile(
              visualDensity: VisualDensity(vertical: -2), 
              leading: Icon(
                log.isError ? Icons.error : Icons.check_circle,
                color: log.isError ? Colors.red : Colors.green,
              ),
              title: Text("${log.method} ${log.url}"),
              subtitle: Text([
                  log.statusCode?.toString(),
                  log.errorMessage,
                  formatTime(log.timestamp),
                ].whereType<String>().where((s) => s.isNotEmpty).join(" | ")),
              dense: true,
            );
          },
        ),
      ),
    );
  }
}
