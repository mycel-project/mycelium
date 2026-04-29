import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/data/services/review_service.dart';
import 'package:mycelium/domain/cloze_mode.dart';

class ReviewUseCase {
  // Must pass trough review repository i guess
  final ReviewService reviewService;
  final NodeStore nodeStore;
  final ReviewStore reviewStore;
  final CollectionStore collectionStore;
  final ReviewRepository reviewRepository;

  ReviewUseCase(
    this.reviewService,
    this.nodeStore,
    this.reviewStore,
    this.collectionStore,
    this.reviewRepository,
  );

  Future<bool> handleNextReview() async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) {
      throw StateError("No collection selected");
    }
    
    final result = await reviewRepository.getNextReview(colId);

    if (result is Node) {
      final node = result;
      nodeStore.selectNode(node);
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
