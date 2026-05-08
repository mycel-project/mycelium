import 'package:flutter/material.dart';
import 'package:mycelium/data/models/user_conf_update.dart';
import 'package:mycelium/ui/widgets/api_status_dot_widget.dart';
import 'package:mycelium/ui/widgets/app_bar.dart';
import 'package:mycelium/viewmodels/settings_view_model.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingViewModel>();
    final conf = vm.conf;

    return Scaffold(
      appBar: MyAppBar(
        titleText: "Settings",
        actions: [ApiStatusDotWidget()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Learning", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _SettingTextField(
              label: "Undo review max age (s)",
              value: conf?.undoReviewMaxAge ?? 300,
              onChanged: (v) => vm.updateConf(UserConfUpdate(undoReviewMaxAge: v)),
            ),
            const SizedBox(height: 16),
            const Text("Network", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _SettingSlider(
              label: "Ping frequency (s)",
              value: conf?.pingFrequency.toDouble() ?? 3,
              min: 1,
              max: 60,
              onChanged: (v) => vm.updateConf(UserConfUpdate(pingFrequency: v.toInt())),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SettingSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toInt()}"),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}


class _SettingTextField extends StatefulWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _SettingTextField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_SettingTextField> createState() => _SettingTextFieldState();
}

class _SettingTextFieldState extends State<_SettingTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: widget.label),
      onChanged: (v) {
        final parsed = int.tryParse(v);
        if (parsed != null) widget.onChanged(parsed);
      },
    );
  }
}
