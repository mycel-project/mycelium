import "package:flutter/material.dart";
import "package:mycelium/core/stores/api_store.dart";
import "package:mycelium/domain/api_compatibility.dart";
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

class _ApiStatusDotWidgetState extends State<ApiStatusDotWidget>  with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _onPressed() async {
    setState(() => _isChecking = true);
    _rotationController.repeat();
    await Future.wait([
        sl<CheckApiUseCase>().execute(),
        Future.delayed(const Duration(milliseconds: 500)),
    ]);
    if (mounted) {
      _rotationController.stop();
      _rotationController.reset();
      setState(() => _isChecking = false);
    }
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
              settings: const RouteSettings(name: 'NetworkDebugPage'),
              builder: (_) => NetworkDebugPage(),
            ),
          );
        }
      },
      splashRadius: 20,
      icon: _isChecking
      ? RotationTransition(
        turns: _rotationController..repeat(),
        child: Image.asset("assets/full.png", height: 32),
      )
      : apiStore.apiStatus == ApiStatus.reachable && apiStore.compatibility == ApiCompatibility.compatible
      ? Image.asset("assets/full.png", height: 32)
      : Icon(
        size: 16,
        switch (apiStore.apiStatus) {
          ApiStatus.unknown || ApiStatus.emptyUrl => Icons.circle,
          ApiStatus.unreachable => Icons.error,
          _ => Icons.circle,
        },
        color: switch (apiStore.apiStatus) {
          ApiStatus.unknown || ApiStatus.emptyUrl => Colors.grey,
          ApiStatus.unreachable => Colors.red,
          ApiStatus.reachable => Colors.orange, // reachable but not compatible
        },
      ),
    );
  }
}
