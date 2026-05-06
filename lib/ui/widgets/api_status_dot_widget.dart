import "package:flutter/material.dart";
import "package:mycelium/core/stores/api_store.dart";
import "package:mycelium/domain/api_status.dart";
import "package:mycelium/domain/check_api_usecase.dart";
import "package:mycelium/ui/pages/network_debug_page.dart";
import "package:provider/provider.dart";
import 'package:mycelium/core/injection.dart';

class ApiStatusDotWidget extends StatefulWidget {
  const ApiStatusDotWidget({super.key});

  @override
  State<ApiStatusDotWidget> createState() => _ApiStatusDotWidgetState();
}

class _ApiStatusDotWidgetState extends State<ApiStatusDotWidget> {
  bool _isChecking = false;

  Future<void> _onPressed() async {
    setState(() => _isChecking = true);
    await Future.wait([
        sl<CheckApiUseCase>().execute(),
        Future.delayed(const Duration(milliseconds: 500)),
    ]);
    if (mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    final apiStore = context.watch<ApiStore>();

    return IconButton(
      onPressed: _onPressed,
      onLongPress: () {
        final currentRoute = ModalRoute.of(context)?.settings.name;

        if (currentRoute != 'NetworkDebugPage') {
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: 'NetworkDebugPage'),
              builder: (_) => NetworkDebugPage(),
            ),
          );
        }
      },
      splashRadius: 20,
      icon: _isChecking
      ? const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
        ),
      )
      : Icon(
        size: 16,
        switch (apiStore.apiStatus) {
          ApiStatus.unknown || ApiStatus.emptyUrl => Icons.circle,
          ApiStatus.reachable => Icons.circle,
          ApiStatus.unreachable => Icons.error,
        },
        color: switch (apiStore.apiStatus) {
          ApiStatus.unknown || ApiStatus.emptyUrl => Colors.grey,
          ApiStatus.reachable => Colors.green,
          ApiStatus.unreachable => Colors.red,
        },
      ),
    );
  }
}
