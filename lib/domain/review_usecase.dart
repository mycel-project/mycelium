import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/domain/cloze_mode.dart';
import 'package:mycelium/domain/navigation_usecase.dart';

class ReviewUseCase {
  final ReviewStore reviewStore;
  final CollectionStore collectionStore;
  final ReviewRepository reviewRepository;
  final NavigationUseCase navigationUseCase;
  final NotificationBus notificationBus;

  ReviewUseCase(
    this.reviewStore,
    this.collectionStore,
    this.reviewRepository,
    this.navigationUseCase,
    this.notificationBus,
  );

  Future<ApiResult<void>> handleNextReview() async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return ApiError("no_collection");

    final result = await reviewRepository.getNextReview(colId);
    if (result is ApiError) return result;
    if (result is ApiSuccess) {
      final node = (result as ApiSuccess).data;
      setReview(node);
    }
    return ApiSuccess(null);
  }

  void setReview(Node? node) {
    if (node != null) {
      navigationUseCase.navigateTo(node.id);
      reviewStore.setReview(node.id);
    } else {
      reviewStore.endReview();
    }
  }

  Future<bool> undo(int collectionId) async {
    final result = await reviewRepository.undoReview(collectionId);
    switch (result) {
      case ApiSuccess(:final data):
        final node = data;
        setReview(node);
        return true;
      case ApiError error:
        if (error.code == "NO_REVIEW_TO_UNDO") {
          notificationBus.showInfo("No review to undo");
        } else {
          notificationBus.showError("Cannot undo review", error);
        }
        return false;
    }
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
