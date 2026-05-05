import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/domain/init_collections_usecase.dart';

class InitDataUseCase {
  final InitCollectionsUseCase initCollectionsUseCase;
  final NodeRepository nodeRepository;
  final ReviewRepository reviewRepository;

  InitDataUseCase(
    this.initCollectionsUseCase,
    this.nodeRepository,
    this.reviewRepository,
  );

  Future<void> execute() async {
    await initCollectionsUseCase.execute();
    nodeRepository.clearTypesCache();
    await nodeRepository.getNodeTypes();
    reviewRepository.clearClozeRegex();
    await reviewRepository.getClozeRegex();
  }
}


