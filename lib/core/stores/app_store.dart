import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

class AppStore extends ChangeNotifier {
  PackageInfo? _packageInfo;

  PackageInfo? get packageInfo => _packageInfo;
  String get version => kDebugMode ? "dev" : (_packageInfo?.version ?? "");

  bool get isDebug => kDebugMode;

  Map<String, dynamic>? _lastVersionInfos;

  Map<String, dynamic>? get lastVersionInfos => _lastVersionInfos;

  set lastVersionInfos(Map<String, dynamic>? infos) {
    _lastVersionInfos = infos;
    notifyListeners();
  }

  Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
    notifyListeners();
  }
}
