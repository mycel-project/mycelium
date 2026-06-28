import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/domain/cloze_mode.dart';
import 'package:mycelium/domain/transform_cloze_usecase.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late TransformClozeUseCase sut;
  late MockReviewRepository mockReviewRepository;

  setUp(() {
    mockReviewRepository = MockReviewRepository();
    sut = TransformClozeUseCase(mockReviewRepository);
  });

  group('TransformClozeUseCase.execute', () {
    const clozeRegex = r'\{\{c(\d+)::(.*?)\}\}';

    setUp(() {
      when(
        () => mockReviewRepository.getClozeRegexSync(),
      ).thenReturn(clozeRegex);
    });

    test('should return content unchanged if regex is null', () {
      when(() => mockReviewRepository.getClozeRegexSync()).thenReturn(null);
      final result = sut.execute('{{c1::hello}}', mode: ClozeMode.hide);
      expect(result, '{{c1::hello}}');
    });

    test('should hide all slots when targetSlot is null', () {
      final content = 'This is a {{c1::test}} with {{c2::multiple}} slots.';
      final result = sut.execute(
        content,
        mode: ClozeMode.hide,
        targetSlot: null,
      );
      expect(result, 'This is a [...] with [...] slots.');
    });

    test('should show all slots when targetSlot is null', () {
      final content = 'This is a {{c1::test}} with {{c2::multiple}} slots.';
      final result = sut.execute(
        content,
        mode: ClozeMode.show,
        targetSlot: null,
      );
      expect(result, 'This is a **test** with **multiple** slots.');
    });

    test('should hide only target slot when targetSlot is provided', () {
      final content = 'This is a {{c1::test}} with {{c2::multiple}} slots.';
      final result = sut.execute(content, mode: ClozeMode.hide, targetSlot: 1);
      expect(result, 'This is a [...] with multiple slots.');
    });

    test('should show only target slot when targetSlot is provided', () {
      final content = 'This is a {{c1::test}} with {{c2::multiple}} slots.';
      final result = sut.execute(content, mode: ClozeMode.show, targetSlot: 1);
      expect(result, 'This is a **test** with multiple slots.');
    });

    test('should target slot 0 correctly when targetSlot is 0', () {
      final content = 'This is a {{c0::zero}} slot and {{c1::one}} slot.';
      final result = sut.execute(content, mode: ClozeMode.hide, targetSlot: 0);
      expect(result, 'This is a [...] slot and one slot.');
    });

    test('should handle custom placeholder and revealWrapper', () {
      final content = 'This is a {{c1::test}}';
      final hiddenResult = sut.execute(
        content,
        mode: ClozeMode.hide,
        placeholder: '___',
      );
      expect(hiddenResult, 'This is a ___');

      final shownResult = sut.execute(
        content,
        mode: ClozeMode.show,
        revealWrapper: '__',
      );
      expect(shownResult, 'This is a __test__');
    });
  });
}
