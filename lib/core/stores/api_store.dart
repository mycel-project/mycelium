import 'package:flutter/material.dart';
import 'package:mycelium/domain/api_status.dart';

class ApiStore extends ChangeNotifier {
  String _baseUrl = "";
  ApiStatus apiStatus = ApiStatus.unknown;

  String get baseUrl => _baseUrl;
  ApiStatus get status => apiStatus;

  void setBaseUrl(String url) {
    _baseUrl = url;
    if (url == "") {
      setEmpty();
    } else {
      setUnknown();
    }
    notifyListeners();
  }

  void setReachable() {
    if (apiStatus == ApiStatus.reachable) return;
    apiStatus = ApiStatus.reachable;
    notifyListeners();
  }

  void setUnreachable() {
    if (apiStatus == ApiStatus.unreachable) return;
    apiStatus = ApiStatus.unreachable;
    notifyListeners();
  }

  void setUnknown() {
    if (apiStatus == ApiStatus.unknown) return;
    apiStatus = ApiStatus.unknown;
    notifyListeners();
  }

  void setEmpty() {
    if (apiStatus == ApiStatus.emptyUrl) return;
    apiStatus = ApiStatus.emptyUrl;
    notifyListeners();
  }
}
