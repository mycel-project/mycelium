import 'package:mycelium/domain/review_usecase.dart';

class LaunchReviewButtonViewmodel {
  final ReviewUseCase reviewUseCase;
  LaunchReviewButtonViewmodel(this.reviewUseCase);

  void launch() {
    reviewUseCase.handleNextReview();
  }
}
