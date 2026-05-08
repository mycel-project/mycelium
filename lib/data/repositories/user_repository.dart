import 'dart:convert';

import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/config_field/config_field.dart';
import 'package:mycelium/data/models/user.dart';
import 'package:mycelium/data/models/user_conf_update.dart';
import 'package:mycelium/data/services/user_service.dart';

class UserRepository {
  final UserService userService;

  Map<String, ConfigField> configSchemaCache = {};
  final Map<int, User> _userCache = {};

  UserRepository(this.userService);

  void clearCache() {
    _userCache.clear();
  }

  void clearConfigSchemaCache() {
    configSchemaCache.clear();
  }

  User _parseUser(ApiSuccess<String> result) {
    final json = jsonDecode(result.data);
    final user = User.fromJson(json["user"]);
    _userCache[user.id] = user;
    return user;
  }

  Future<ApiResult<User>> getCurrentUser() async {
    final result = await userService.getCurrentUser();
    if (result is ApiError) return result;
    return ApiSuccess(_parseUser(result as ApiSuccess<String>));
  }

  Future<ApiResult<User>> updateUserConfig(UserConfUpdate update) async {
    final result = await userService.updateUserConfig(update);
    if (result is ApiError) return result;
    return ApiSuccess(_parseUser(result as ApiSuccess<String>));
  }

  Future<ApiResult<Map<String, ConfigField>>> getUserConfigSchema() async {
    if (configSchemaCache.isNotEmpty) {
      return ApiSuccess(configSchemaCache);
    }

    final result = await userService.getUserConfigSchema();
    if (result is ApiError) return result;

    final decoded = jsonDecode((result as ApiSuccess<String>).data);
    final properties = decoded["schema"]["properties"] as Map<String, dynamic>;

    configSchemaCache = Map.fromEntries(
      properties.entries.map(
        (e) => MapEntry(
          e.key,
          ConfigField.fromJson(e.key, e.value),
        ),
      ),
    );

    return ApiSuccess(configSchemaCache);
  }
}
