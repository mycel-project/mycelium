import 'package:pub_semver/pub_semver.dart';
import 'package:mycelium/domain/api_compatibility.dart';

class CompatibilityChecker {
  ApiCompatibility check(
    String frontendVersion,
    String backendVersion,
    Map<String, dynamic> compatibilityMatrix,
  ) {
    if (frontendVersion == "dev") return ApiCompatibility.compatible;
    try {
      final frontend = Version.parse(frontendVersion);
      final backend = Version.parse(backendVersion);
      for (final entry in compatibilityMatrix.entries) {
        final frontendConstraint = VersionConstraint.parse(entry.key);
        if (!frontendConstraint.allows(frontend)) continue;
        final backendConstraint = VersionConstraint.parse(
          entry.value["mycel"]["compatible"],
        );
        return backendConstraint.allows(backend)
            ? ApiCompatibility.compatible
            : ApiCompatibility.incompatible;
      }
      return ApiCompatibility.incompatible;
    } catch (e) {
      return ApiCompatibility.error;
    }
  }
}
