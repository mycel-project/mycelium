import 'package:pub_semver/pub_semver.dart';

class CompatibilityChecker {
  bool? check(
    String frontendVersion,
    String backendVersion,
    Map<String, dynamic> compatibilityMatrix,
  ) {
    if (frontendVersion == "dev") return true;
    try {
      final frontend = Version.parse(frontendVersion.replaceAll(RegExp(r'-(alpha|beta|rc).*'), ''));
      final backend = Version.parse(backendVersion.replaceAll(RegExp(r'-(alpha|beta|rc).*'), ''));
      for (final entry in compatibilityMatrix.entries) {
        final frontendConstraint = VersionConstraint.parse(entry.key);
        if (!frontendConstraint.allows(frontend)) continue;
        final backendConstraint = VersionConstraint.parse(
          entry.value["mycel"]["compatible"],
        );
        return backendConstraint.allows(backend) ? true : false;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
