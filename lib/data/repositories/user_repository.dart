import 'dart:convert';

import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/user.dart';
import 'package:mycelium/data/models/user_conf_update.dart';
import 'package:mycelium/data/services/user_service.dart';

class UserRepository {
  final UserService userService;

  final Map<int, User> _userCache = {};

  UserRepository(this.userService);

  void clearCache() {
    _userCache.clear();
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
}
