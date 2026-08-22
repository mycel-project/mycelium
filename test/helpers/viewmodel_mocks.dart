import 'package:mocktail/mocktail.dart';

import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/core/stores/scroll_position_store.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/data/services/node_service.dart';
import 'package:mycelium/domain/create_extract_usecase.dart';
import 'package:mycelium/domain/get_outline_usecase.dart';
import 'package:mycelium/domain/navigation_usecase.dart';
import 'package:mycelium/domain/node_usecase.dart';
import 'package:mycelium/domain/refresh_current_node_usecase.dart';
import 'package:mycelium/domain/refresh_priorities_usecase.dart';
import 'package:mycelium/domain/remove_links_usecase.dart';
import 'package:mycelium/domain/review_node_usecase.dart';
import 'package:mycelium/domain/review_usecase.dart';
import 'package:mycelium/domain/transform_cloze_usecase.dart';
import 'package:mycelium/domain/split_node_usecase.dart';
import 'package:mycelium/domain/update_priority_usecase.dart';
import 'package:mycelium/viewmodels/md_editor_viewmodel.dart';

class MockNodeService extends Mock implements NodeService {}
class MockNodeStore extends Mock implements NodeStore {}
class MockReviewStore extends Mock implements ReviewStore {}
class MockNodeRepository extends Mock implements NodeRepository {}
class MockReviewUseCase extends Mock implements ReviewUseCase {}
class MockTransformClozeUseCase extends Mock implements TransformClozeUseCase {}
class MockReviewRepository extends Mock implements ReviewRepository {}
class MockNodeUseCase extends Mock implements NodeUseCase {}
class MockCollectionStore extends Mock implements CollectionStore {}
class MockApiStore extends Mock implements ApiStore {}
class MockNotificationBus extends Mock implements NotificationBus {}
class MockNavigationUseCase extends Mock implements NavigationUseCase {}
class MockCreateExtractUseCase extends Mock implements CreateExtractUseCase {}
class MockReviewNodeUseCase extends Mock implements ReviewNodeUseCase {}
class MockRemoveLinksUseCase extends Mock implements RemoveLinksUseCase {}
class MockUpdatePriorityUseCase extends Mock implements UpdatePriorityUseCase {}
class MockRefreshPrioritiesUseCase extends Mock implements RefreshPrioritiesUseCase {}
class MockScrollPositionStore extends Mock implements ScrollPositionStore {}
class MockGetOutlineUseCase extends Mock implements GetOutlineUseCase {}
class MockSplitNodeUseCase extends Mock implements SplitNodeUseCase {}
class MockRefreshCurrentNodeUseCase extends Mock implements RefreshCurrentNodeUseCase {}

MdEditorViewModel createTestMdEditorViewModel({
  NodeService? nodeService,
  NodeStore? nodeStore,
  ReviewStore? reviewStore,
  NodeRepository? nodeRepository,
  ReviewUseCase? reviewUseCase,
  TransformClozeUseCase? transformClozeUseCase,
  ReviewRepository? reviewRepository,
  NodeUseCase? nodeUseCase,
  CollectionStore? collectionStore,
  ApiStore? apiStore,
  NotificationBus? notificationBus,
  NavigationUseCase? navigationUseCase,
  CreateExtractUseCase? createExtractUseCase,
  ReviewNodeUseCase? reviewNodeUseCase,
  RemoveLinksUseCase? removeLinksUseCase,
  UpdatePriorityUseCase? updatePriorityUseCase,
  RefreshPrioritiesUseCase? refreshPrioritiesUseCase,
  ScrollPositionStore? scrollPositionStore,
  GetOutlineUseCase? getOutlineUseCase,
  SplitNodeUseCase? splitNodeUseCase,
  RefreshCurrentNodeUseCase? refreshCurrentNodeUseCase,
}) {
  return MdEditorViewModel(
    nodeService ?? MockNodeService(),
    nodeStore ?? MockNodeStore(),
    reviewStore ?? MockReviewStore(),
    nodeRepository ?? MockNodeRepository(),
    reviewUseCase ?? MockReviewUseCase(),
    transformClozeUseCase ?? MockTransformClozeUseCase(),
    reviewRepository ?? MockReviewRepository(),
    nodeUseCase ?? MockNodeUseCase(),
    collectionStore ?? MockCollectionStore(),
    apiStore ?? MockApiStore(),
    notificationBus ?? MockNotificationBus(),
    navigationUseCase ?? MockNavigationUseCase(),
    createExtractUseCase ?? MockCreateExtractUseCase(),
    reviewNodeUseCase ?? MockReviewNodeUseCase(),
    removeLinksUseCase ?? MockRemoveLinksUseCase(),
    updatePriorityUseCase ?? MockUpdatePriorityUseCase(),
    refreshPrioritiesUseCase ?? MockRefreshPrioritiesUseCase(),
    scrollPositionStore ?? MockScrollPositionStore(),
    getOutlineUseCase ?? MockGetOutlineUseCase(),
    splitNodeUseCase ?? MockSplitNodeUseCase(),
    refreshCurrentNodeUseCase ?? MockRefreshCurrentNodeUseCase(),
  );
}
