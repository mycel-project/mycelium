import 'package:mycelium/data/models/config_field/config_field.dart';

class BoolConfigField extends ConfigField {
  @override
  final bool defaultValue;

  const BoolConfigField({
    required super.key,
    required super.title,
    required super.category,
    super.description,
    super.warning,
    required this.defaultValue,
  }) : super(type: "boolean");
}
