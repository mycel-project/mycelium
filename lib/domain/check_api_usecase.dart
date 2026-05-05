import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/services/api_service.dart';

class CheckApiUseCase {
  final ApiService apiService;
  final ApiStore apiStore;

  CheckApiUseCase(this.apiService, this.apiStore);

  Future<bool> execute() async {
    try {
      final isReachable = await apiService.checkReachability();
      apiStore.setReachable(isReachable);
      return isReachable;
    } catch (_) {
      apiStore.setReachable(false);
      return false;
    }
  }
}
