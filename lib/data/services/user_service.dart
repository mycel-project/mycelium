import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/user_conf_update.dart';
import 'package:mycelium/data/network/api_client.dart';

class UserService {
  final ApiClient api;
  UserService(this.api);

  Future<ApiResult<String>> getCurrentUser() async {
    return await api.get("/users");
  }

  Future<ApiResult<String>> updateUserConfig(
    UserConfUpdate data,
  ) async {
    return await api.patch("/users", data.toJson());
  }

  Future<ApiResult<String>> getUserConfigSchema() async {
    return await api.get("/schemas/user-settings");
  }
}
