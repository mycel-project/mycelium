import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/domain/cloze_mode.dart';
import 'package:mycelium/domain/navigation_usecase.dart';

class ReviewUseCase {
  final ReviewStore reviewStore;
  final CollectionStore collectionStore;
  final ReviewRepository reviewRepository;
  final NavigationUseCase navigationUseCase;

  ReviewUseCase(
    this.reviewStore,
    this.collectionStore,
    this.reviewRepository,
    this.navigationUseCase,
  );

  Future<bool> handleNextReview() async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) {
      throw StateError("No collection selected");
    }

    final result = await reviewRepository.getNextReview(colId);

    if (result is Node) {
      final node = result;
      navigationUseCase.navigateTo(node.id);
      reviewStore.setReview(node.id);
    } else {
      reviewStore.endReview();
    }

    return true;
  }

  String transformClozeContent(
    String content, {
    required ClozeMode mode,
    String placeholder = "[...]",
    String revealWrapper = "**",
  }) {
    final regexString = reviewRepository.getClozeRegexSync();

    if (regexString == null) {
      return content;
    }

    final regex = RegExp(regexString);

    return content.replaceAllMapped(regex, (match) {
      final value = match.group(1) ?? "";

      switch (mode) {
        case ClozeMode.hide:
          return placeholder;

        case ClozeMode.show:
          return "$revealWrapper$value$revealWrapper";
      }
    });
  }
}
