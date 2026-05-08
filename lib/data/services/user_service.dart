import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/user_conf_update.dart';
import 'package:mycelium/data/services/api_service.dart';

class UserService {
  final ApiService api;
  UserService(this.api);

  Future<ApiResult<String>> getCurrentUser() async {
    return await api.get("/users/me");
  }

  Future<ApiResult<String>> updateUserConfig(
    UserConfUpdate data,
  ) async {
    return await api.patch("/users/me/settings", data.toJson());
  }

  Future<ApiResult<String>> getUserConfigSchema() async {
    return await api.get("/users/settings/schema");
  }
}
