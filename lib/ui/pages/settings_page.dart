import 'package:flutter/material.dart';
import 'package:mycelium/data/models/config_field/bool_config_field.dart';
import 'package:mycelium/data/models/config_field/config_field.dart';
import 'package:mycelium/data/models/config_field/int_config_field.dart';
import 'package:mycelium/data/models/config_field/string_config_field.dart';
import 'package:mycelium/ui/widgets/api_status_dot_widget.dart';
import 'package:mycelium/ui/widgets/app_bar.dart';
import 'package:mycelium/viewmodels/settings_viewmodel.dart';
import 'package:provider/provider.dart';

// AI used to quiclky build UI
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingViewModel>();

    final Map<String, List<ConfigField>> groupedFields = {};
    for (var field in vm.schema.values) {
      groupedFields.putIfAbsent(field.category, () => []).add(field);
    }

    return Scaffold(
      appBar: MyAppBar(
        titleText: "Settings",
        actions: [
          ApiStatusDotWidget(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SettingViewModel>().reloadSchema(),
          ),
        ],
      ),
      body: vm.schema.isNotEmpty
          ? ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              children: [
                ...groupedFields.entries.map((category) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.key.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                      ...category.value.map((field) {
                        final currentValue =
                            vm.conf?.data[field.key] ?? field.defaultValue;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24, left: 32, right: 32),
                          child: _SettingField(
                            field: field,
                            value: currentValue,
                            onChanged: (v) => vm.updateConf(field.key, v),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
              ],
            )
          : const Center(child: Text("No settings")),
    );
  }
}

class _SettingField extends StatelessWidget {
  final ConfigField field;
  final dynamic value;
  final Function(dynamic) onChanged;

  const _SettingField({required this.field, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.title, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        ),
        if (field.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              field.description!,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        const SizedBox(height: 8),
        if (field is IntConfigField)
          _IntField(
            field: field as IntConfigField,
            value: (value as num).toInt(),
            onChanged: onChanged,
          )
          else if (field is StringConfigField)
          _StringField(
            field: field as StringConfigField,
            value: value.toString(),
            onChanged: onChanged
          )
          else if (field is BoolConfigField)
          _BoolField(
            field: field as BoolConfigField,
            value: value as bool,
            onChanged: (v) => onChanged(v),
          ),
        ],
      );
    }
  }

class _IntField extends StatefulWidget {
  final IntConfigField field;
  final int value;
  final Function(int) onChanged;

  const _IntField({required this.field, required this.value, required this.onChanged});

  @override
  State<_IntField> createState() => _IntFieldState();
}

class _IntFieldState extends State<_IntField> {
  late double _localValue;

  @override
  void initState() {
    super.initState();
    _localValue = widget.value.toDouble();
  }

  @override
  void didUpdateWidget(covariant _IntField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _localValue = widget.value.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final min = widget.field.min.toDouble();
    final max = widget.field.max.toDouble();
    final divisions = (max - min) ~/ widget.field.step;
    final unit = widget.field.unit ?? "";

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          onPressed: () => widget.onChanged(widget.field.defaultValue),
        ),
        Expanded(
          child: Slider(
            value: _localValue.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions > 0 ? divisions : null,
            onChanged: (v) => setState(() => _localValue = v),
            onChangeEnd: (v) => widget.onChanged(v.toInt()),
          ),
        ),
        SizedBox(
          width: 80, 
          child: Text(
            "${_localValue.toInt()} $unit",
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
class _StringField extends StatefulWidget {
  final StringConfigField field; 
  final String value;
  final Function(String) onChanged;

  const _StringField({
    required this.field,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_StringField> createState() => _StringFieldState();
}

class _StringFieldState extends State<_StringField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _StringField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          onPressed: () => widget.onChanged(widget.field.defaultValue),
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onSubmitted: widget.onChanged,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_circle_right_outlined,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => widget.onChanged(_controller.text),
        ),
      ],
    );
  }
}

class _BoolField extends StatelessWidget {
  final BoolConfigField field;
  final bool value;
  final Function(bool) onChanged;

  const _BoolField({
    required this.field,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          onPressed: () => onChanged(field.defaultValue),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
