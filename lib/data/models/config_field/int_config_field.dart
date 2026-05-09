import 'package:mycelium/data/models/config_field/config_field.dart';

class IntConfigField extends ConfigField {
  @override
  final int defaultValue;
  final int min;
  final int max;
  final int step;
  final String? unit; 

  const IntConfigField({
    required super.key,
    required super.title,
    required super.category,
    super.description,
    required this.defaultValue,
    required this.min,
    required this.max,
    required this.step,
    super.warning,
    this.unit,
  }) : super(type: "integer");
}
