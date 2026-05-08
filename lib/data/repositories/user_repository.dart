import 'dart:convert';

import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/user.dart';
import 'package:mycelium/data/services/user_service.dart';

class UserRepository {
  final UserService userService;

  final Map<int, User> _userCache = {};

  UserRepository(this.userService);

  void clearCache() {
    _userCache.clear();
  }

  Future<ApiResult<User>> getCurrentUser() async {
    final result = await userService.getCurrentUser();
    if (result is ApiError) return result;
    final json = jsonDecode((result as ApiSuccess<String>).data);
    final user = User.fromJson(json["user"]);
    _userCache[user.id] = user;
    return ApiSuccess(user);
  }
}
