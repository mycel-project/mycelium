import 'package:flutter/material.dart';
import 'package:mycelium/domain/api_compatibility.dart';
import 'package:mycelium/domain/api_status.dart';

class ApiStore extends ChangeNotifier {
  String _baseUrl = "https://api.mycelcloud.com";
  String _token = "";
  ApiStatus apiStatus = ApiStatus.unknown;
  ApiCompatibility apiCompatibility = ApiCompatibility.unchecked;

  String get baseUrl => _baseUrl;
  String get token => _token;
  ApiStatus get status => apiStatus;
  ApiCompatibility get compatibility => apiCompatibility;

  String? _version;

  String? get version => _version;
  
  set version(String? version) {
    _version = version;
    notifyListeners();
  }

  void setBaseUrl(String url) {
    _baseUrl = url;
    resetCompatibility();
    version = null;
    if (url == "") {
      setEmpty();
    } else {
      setUnknown();
    }
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void setStatus(ApiStatus status) {
    if (apiStatus == status) return;
    apiStatus = status;
    notifyListeners();
  }

  void setReachable() => setStatus(ApiStatus.reachable);
  void setUnreachable() => setStatus(ApiStatus.unreachable);
  void setUnknown() => setStatus(ApiStatus.unknown);
  void setEmpty() => setStatus(ApiStatus.emptyUrl);

  void setCompatibility(ApiCompatibility compatibility) {
    if (apiCompatibility == compatibility) return;
    apiCompatibility = compatibility;
    notifyListeners();
  }

  void setCompatible() => setCompatibility(ApiCompatibility.compatible);
  void setIncompatible() => setCompatibility(ApiCompatibility.incompatible);
  void setCompatibilityError() => setCompatibility(ApiCompatibility.error);
  void resetCompatibility() => setCompatibility(ApiCompatibility.unchecked);
}
