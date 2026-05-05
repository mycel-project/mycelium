import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/services/api_service.dart';
import 'package:mycelium/domain/api_status.dart';

class CheckApiUseCase {
  final ApiService apiService;
  final ApiStore apiStore;

  CheckApiUseCase(this.apiService, this.apiStore);

  Future<ApiStatus> execute() async {
    try {
      final isReachable = await apiService.checkReachability();
      if (isReachable) {
        apiStore.setReachable();
      } else {
        if (!(apiStore.apiStatus == ApiStatus.emptyUrl)) {
          apiStore.setUnreachable();
        }
      }
      return apiStore.apiStatus;
    } catch (_) {
      apiStore.setUnreachable();
      return apiStore.apiStatus;
    }
  }
}
