import 'package:mycelium/data/models/config_field/config_field.dart';

class StringConfigField extends ConfigField {
  @override
  final String defaultValue;

  const StringConfigField({
    required super.key,
    required super.title,
    required super.category,
    super.description,
    required this.defaultValue,
  }) : super(type: "string");
}
