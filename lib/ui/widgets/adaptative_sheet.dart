import 'package:flutter/material.dart';
import 'package:mycelium/utils/device.dart';

Future<void> showAdaptiveSheet({
  required BuildContext context,
  required Widget child,
}) {
  if (Device.isDesktop) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: child,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } else {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: child,
        ),
      ),
    );
  }
}
