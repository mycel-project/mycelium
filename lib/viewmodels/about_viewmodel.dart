import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/app_store.dart';
import 'package:mycelium/domain/check_app_update_usecase.dart';

class AboutViewModel extends ChangeNotifier {
  final AppStore appStore;
  final CheckAppUpdateUseCase checkAppUpdateUseCase;

  AboutViewModel(this.appStore, this.checkAppUpdateUseCase) {
    appStore.addListener(_onAppStoreChanged);
  }

  void _onAppStoreChanged() {
    notifyListeners();
  }

  String? get version => appStore.version;
  String? get lastVersion => appStore.lastVersionInfos?['tag_name'];

  Future<void> reloadLastUpdate() async {
    await checkAppUpdateUseCase.execute();
  }
}
