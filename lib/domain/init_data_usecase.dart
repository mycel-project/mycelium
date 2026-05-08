import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/data/repositories/user_repository.dart';
import 'package:mycelium/domain/init_collections_usecase.dart';
import 'package:mycelium/domain/init_user_usecase.dart';

class InitDataUseCase {
  final InitCollectionsUseCase initCollectionsUseCase;
  final NodeRepository nodeRepository;
  final ReviewRepository reviewRepository;
  final InitUserUseCase initUserUseCase;
  final UserRepository userRepository;

  InitDataUseCase(
    this.initCollectionsUseCase,
    this.nodeRepository,
    this.reviewRepository,
    this.initUserUseCase,
    this.userRepository,
  );

  Future<void> execute() async {
    // Cleaning in case of another Mycel verison with different data/types, ...
    userRepository.clearConfigSchemaCache();
    await userRepository.getUserConfigSchema();
    await initUserUseCase.execute();
    await initCollectionsUseCase.execute();
    nodeRepository.clearTypesCache();
    await nodeRepository.getNodeTypes();
    reviewRepository.clearClozeRegex();
    await reviewRepository.getClozeRegex();
  }
}
