import 'package:mycelium/core/debug/network_logger.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/network/api_client.dart';
import 'package:mycelium/data/network/api_service.dart';

ApiClient createTestApiClient() {
  final store = ApiStore();
  store.setBaseUrl("http://localhost:4010");
  store.setToken("fake");
  final apiService = ApiService(store, NetworkLogger());
  return ApiClient(apiService, NotificationBus());
}
