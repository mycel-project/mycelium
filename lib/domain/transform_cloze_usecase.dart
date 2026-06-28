import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/domain/cloze_mode.dart';

class TransformClozeUseCase {
  final ReviewRepository reviewRepository;

  TransformClozeUseCase(this.reviewRepository);

  String execute(
    String content, {
    required ClozeMode mode,
    String placeholder = "[...]",
    String revealWrapper = "**",
    int? targetSlot,
  }) {
    final regexString = reviewRepository.getClozeRegexSync();

    if (regexString == null) {
      return content;
    }

    final regex = RegExp(regexString, dotAll: true);

    return content.replaceAllMapped(regex, (match) {
      final slotNumber = int.tryParse(match.group(1) ?? "") ?? 0;
      final value = match.group(2) ?? "";
      final isTargetSlot = targetSlot == null || slotNumber == targetSlot;

      switch (mode) {
        case ClozeMode.hide:
          return isTargetSlot ? placeholder : value;
        case ClozeMode.show:
          return isTargetSlot ? "$revealWrapper$value$revealWrapper" : value;
      }
    });
  }
}
