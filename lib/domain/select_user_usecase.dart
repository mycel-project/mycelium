import 'package:mycelium/core/stores/user_store.dart';
import 'package:mycelium/data/local/user_preferences.dart';
import 'package:mycelium/data/models/user.dart';

class SelectUserUseCase {
  final UserStore userStore;
  final UserPreferences userPreferences;

  SelectUserUseCase(this.userStore, this.userPreferences);

  Future<void> execute(User user) async {
    userStore.selectUser(user);
    await userPreferences.saveId(user.id);
  }
}
