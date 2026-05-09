import 'package:mycelium/data/models/config_field/bool_config_field.dart';
import 'package:mycelium/data/models/config_field/int_config_field.dart';
import 'package:mycelium/data/models/config_field/string_config_field.dart';

abstract class ConfigField {
  final String key;
  final String title;
  final String category;
  final String type;
  final String? description;
  final String? warning;

  const ConfigField({
    required this.key,
    required this.title,
    required this.category,
    required this.type,
    this.description,
    this.warning,
  });

  dynamic get defaultValue;

  factory ConfigField.fromJson(String key, Map<String, dynamic> json) {
    final type = json["type"];
    final common = {
      'key': key,
      'title': json["title"] ?? key,
      'category': json["category"] ?? "default",
      'description': json["description"],
    };

    switch (type) {
      case "integer":
      return IntConfigField(
        key: common['key'] as String,
        title: common['title'] as String,
        category: common['category'] as String,
        description: common['description'] as String?,
        unit: json["unit"],
        defaultValue: json["default"] ?? 0,
        min: json["minimum"] ?? 0,
        max: json["maximum"] ?? 100,
        step: json["step"] ?? 1,
        warning: json["warning"] ?? null,
      );
      case "string":
      return StringConfigField(
        key: common['key'] as String,
        title: common['title'] as String,
        category: common['category'] as String,
        description: common['description'] as String?,
        defaultValue: json["default"] ?? "",
        warning: json["warning"] ?? null,
      );
      case "boolean":
      return BoolConfigField(
        key: common['key'] as String,
        title: common['title'] as String,
        category: common['category'] as String,
        description: common['description'] as String?,
        defaultValue: json["default"] ?? false,
        warning: json["warning"] ?? null,
      );
      default:
      throw Exception("Unsupported type: $type");
    }
  }
}
