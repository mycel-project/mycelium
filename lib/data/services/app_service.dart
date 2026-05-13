import 'dart:async';
import 'package:http/http.dart' as http;

// Service used to query metadata of Mycelium/Mycel (versions, compatibility, ...), mainly through github
class AppService {
  AppService();
  // Maybe move the API calls into a central function that handles common GitHub API errors, like rate limit exceeded.

  Future<http.Response> getCompatibilityMatrix() async {
    return await http.get(
      // query param to avoid caching
      Uri.parse(
        "https://raw.githubusercontent.com/mycel-project/mycelium/main/compatibility.json?ts=${DateTime.now().millisecondsSinceEpoch}",
      ),
    );
  }

  Future<http.Response> getLastAppVersion() async {
    return await http.get(
      Uri.parse(
        "https://api.github.com/repos/mycel-project/mycelium/releases/latest",
      ),
    );
  }
}
