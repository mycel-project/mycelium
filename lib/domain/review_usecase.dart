import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/review_target.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/domain/cloze_mode.dart';
import 'package:mycelium/domain/navigation_usecase.dart';
import 'package:mycelium/utils/time_utils.dart';

class ReviewUseCase {
  final ReviewStore reviewStore;
  final CollectionStore collectionStore;
  final ReviewRepository reviewRepository;
  final NavigationUseCase navigationUseCase;
  final NotificationBus notificationBus;
  final NodeRepository nodeRepository;

  ReviewUseCase(
    this.reviewStore,
    this.collectionStore,
    this.reviewRepository,
    this.navigationUseCase,
    this.notificationBus,
    this.nodeRepository,
  );

  Future<ApiResult<void>> handleNextReview() async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return ApiError("no_collection");

    final result = await reviewRepository.getNextReview(colId, tzOffsetMinutes);
    if (result is ApiError) return result;
    if (result is ApiSuccess) {
      final node = (result as ApiSuccess).data;
      setReview(node);
    }
    return ApiSuccess(null);
  }

  void setReview(ReviewTarget? reviewTarget) {
    if (reviewTarget != null) {
      navigationUseCase.navigateTo(reviewTarget.node.id);
      reviewStore.setReview(reviewTarget.node.id, slot: reviewTarget.slot);
    } else {
      reviewStore.endReview();
    }
  }

  Future<bool> undo(String collectionId) async {
    final result = await reviewRepository.undoReview(collectionId);
    switch (result) {
      case ApiSuccess(:final data):
        final reviewTarget = data;
        if (reviewTarget != null) {
          nodeRepository.updateCache(reviewTarget.node.id, reviewTarget.node);
        }
        setReview(reviewTarget);
        return true;
      case DomainError error:
        switch (error.code) {
          case "NO_REVIEW_TO_UNDO":
            notificationBus.showInfo("No review to undo");
          case "UNDO_REVIEW_NOT_ALLOWED":
            notificationBus.showInfo("This review is too old to undo");
          case "UNDO_NODE_INACCESSIBLE":
            notificationBus.showWarning(
              "Undo has been applied but node is deleted.",
            );
          default:
            notificationBus.showError("Cannot undo review", error);
        }
    }
    return false;
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

    final regex = RegExp(regexString, dotAll: true);

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
