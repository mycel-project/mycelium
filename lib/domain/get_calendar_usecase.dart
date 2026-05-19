import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/day_review_overview.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/utils/time_utils.dart';

class GetCalendarUseCase {
  final ReviewRepository reviewRepository;
  final NotificationBus notificationBus;

  GetCalendarUseCase(this.reviewRepository, this.notificationBus);

  Future<Map<DateTime, DayReviewOverview>?> execute(int colId) async {
    final result = await reviewRepository.getCalendar(colId, tzOffsetMinutes);
    switch (result) {
      case ApiSuccess(:final data):
        final calendar = data;
        return calendar;
      case ApiError error:
        notificationBus.showError("Cannot load calendar data", error);
        return null;
    }
  }
}
