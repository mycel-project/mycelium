import "package:flutter/material.dart";
import "package:mycelium/core/stores/api_store.dart";
import "package:mycelium/domain/check_api_usecase.dart";
import "package:mycelium/domain/connection_status.dart";
import "package:mycelium/ui/pages/network_debug_page.dart";
import "package:mycelium/utils/device.dart";
import "package:provider/provider.dart";
import 'package:mycelium/core/injection.dart';

class ApiStatusDotWidget extends StatefulWidget {
  const ApiStatusDotWidget({super.key});

  @override
  State<ApiStatusDotWidget> createState() => _ApiStatusDotWidgetState();
}

class _ApiStatusDotWidgetState extends State<ApiStatusDotWidget>
with SingleTickerProviderStateMixin {
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

    void goDebug() {
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
    }

    return Tooltip(
      message: Device.isDesktop
      ? 'Reload connection (right-click for debug page)'
      : 'Reload connection (hold for debug page)',
      child: GestureDetector(
        onSecondaryTap: Device.isDesktop ? goDebug : null,
        child: IconButton(
          onPressed: _onPressed,
          onLongPress: Device.isMobile
          ? goDebug
          : null,
          splashRadius: 20,
          icon: _isChecking
          ? RotationTransition(
            turns: _rotationController..repeat(),
            child: Image.asset("assets/full.png", height: 32),
          )
          : apiStore.status == ConnectionStatus.connected
          ? Image.asset("assets/full.png", height: 32)
          : Icon(
            size: 16,
            switch (apiStore.status) {
              ConnectionStatus.unknown => Icons.circle,
              ConnectionStatus.unreachable => Icons.error,
              ConnectionStatus.degraded => Icons.error,
              _ => Icons.circle,
            },
            color: switch (apiStore.status) {
              ConnectionStatus.unknown => Colors.grey,
              ConnectionStatus.unreachable => Colors.red,
              ConnectionStatus.degraded => Colors.orange,
              _ => Colors.grey,
            },
          ),
        ),
      ),
    );
  }
}
