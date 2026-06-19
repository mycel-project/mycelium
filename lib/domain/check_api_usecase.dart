import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/network/api_service.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/check_api_compatibility_usecase.dart';

class CheckApiUseCase {
  final ApiService apiService;
  final ApiStore apiStore;
  final CheckApiCompatibilityUseCase checkApiCompatibilityUseCase;

  CheckApiUseCase(
    this.apiService,
    this.apiStore,
    this.checkApiCompatibilityUseCase,
  );

  Future<ApiStatus> execute() async {
    try {
      final isReachable = await apiService.checkReachability();
      if (isReachable) {
        apiStore.setReachable();
        await checkApiCompatibilityUseCase.execute();
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
