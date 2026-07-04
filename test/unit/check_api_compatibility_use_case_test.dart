import 'package:flutter_test/flutter_test.dart';
import 'package:mycelium/domain/compatibility_checker.dart';

void main() {
  late CompatibilityChecker checker;

  setUp(() {
    checker = CompatibilityChecker();
  });

  group('_checkCompatibility', () {
    final simpleMatrix = {
      "0.0.1": {
        "mycel": {"compatible": ">=0.0.1 <0.1.0"},
      },
    };

    final rangeMatrix = {
      ">=0.0.1 <1.0.0": {
        "mycel": {"compatible": ">=0.0.1 <0.2.0"},
      },
    };

    final multiEntryMatrix = {
      ">=0.0.1 <0.1.0": {
        "mycel": {"compatible": ">=0.0.1 <0.1.0"},
      },
      ">=0.1.0 <1.0.0": {
        "mycel": {"compatible": ">=0.1.0 <1.0.0"},
      },
    };

    // --- Exact version key ---
    test('exact key: compatible versions', () {
      expect(
        checker.check("0.0.1", "0.0.5", simpleMatrix),
        true,
      );
    });

    test('exact key: backend too old', () {
      expect(
        checker.check("0.0.1", "0.0.0", simpleMatrix),
        false,
      );
    });

    test('exact key: backend too new', () {
      expect(
        checker.check("0.0.1", "0.1.0", simpleMatrix),
        false,
      );
    });

    test('exact key: frontend not in matrix', () {
      expect(
        checker.check("9.9.9", "0.0.5", simpleMatrix),
        null,
      );
    });

    // --- Range key ---
    test('range key: frontend matches range, backend compatible', () {
      expect(
        checker.check("0.0.5", "0.1.0", rangeMatrix),
        true,
      );
    });

    test('range key: frontend matches range, backend incompatible', () {
      expect(
        checker.check("0.0.5", "0.2.0", rangeMatrix),
        false,
      );
    });

    test('range key: frontend outside range', () {
      expect(
        checker.check("1.0.0", "0.1.0", rangeMatrix),
        null,
      );
    });

    // --- Multiple entries ---
    test('multi entry: matches first range', () {
      expect(
        checker.check("0.0.5", "0.0.5", multiEntryMatrix),
        true,
      );
    });

    test('multi entry: matches second range', () {
      expect(
        checker.check("0.1.5", "0.1.5", multiEntryMatrix),
        true,
      );
    });

    test('multi entry: backend incompatible with matched range', () {
      expect(
        checker.check("0.1.5", "0.0.5", multiEntryMatrix),
        false,
      );
    });

    // --- Error cases ---
    test('invalid frontend version returns null', () {
      expect(
        checker.check("not_a_version", "0.0.1", simpleMatrix),
        null,
      );
    });

    test('invalid backend version returns null', () {
      expect(
        checker.check("0.0.1", "not_a_version", simpleMatrix),
        null,
      );
    });

    test('malformed matrix returns null', () {
      expect(
        checker.check("0.0.1", "0.0.1", {"0.0.1": {}}),
        null,
      );
    });

    // --- Debug mode ---
    test('dev frontend version returns compatible', () {
      expect(
        checker.check("dev", "0.0.1", simpleMatrix),
        true,
      );
    });
  });
}
