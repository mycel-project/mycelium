import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/data/services/node_service.dart';
import 'package:mycelium/domain/review_usecase.dart';

class MdEditorViewModel extends ChangeNotifier {
  // Must delegate col logic directly in review usecase I guess
  Node? node;

  NodeService nodeService;
  NodeStore nodeStore;
  NodeRepository nodeRepository;

  bool isAnswerVisible = false;

  final ReviewUseCase reviewUseCase;

  final ReviewRepository reviewRepository;

  MdEditorViewModel({
    required this.nodeService,
    required this.nodeStore,
    required this.nodeRepository,
    required this.reviewUseCase,
    required this.reviewRepository,
  }) {
    nodeStore.addListener(_onNodeStoreChanged);
    _onNodeStoreChanged();
  }

  void _onNodeStoreChanged() {
    loadNode(nodeStore.currentNode);
  }

  @override
  void dispose() {
    nodeStore.removeListener(_onNodeStoreChanged);
    super.dispose();
  }

  String content = "";
  bool isDirty = false;

  void showAnswer() {
    isAnswerVisible = true;
    notifyListeners();
  }

  void reviewSpore(int rating) {
    reviewRepository.reviewSpore(
      node!.collectionId,
      node!.id,
      10,
      rating,
    );
  }

  void reviewFragment() {
    reviewRepository.reviewFragment(
      node!.collectionId,
      node!.id,
      10,
    );
  }

  void nextReview() {
      reviewUseCase.handleNextReview();
  }

  bool isCurrentNodeSpore() {
    if (node != null) {
      final type = nodeRepository.getNodeTypeSync(node!.type);
      return type?.label == "SPORE";
    } else {
      return false;
    }
  }

  void loadNode(Node? node) {
    isAnswerVisible = false;
    if (node != null) {
      this.node = node;
      content = node.content?["0"] ?? "";
      isDirty = false;
      notifyListeners();
    } else {
      this.node = null;
      content = "";
      notifyListeners();
      isDirty = false;
    }
  }

  void updateContent(String value) {
    content = value;
    isDirty = true;
    notifyListeners();
  }

  Future<void> saveContent() async {
    if (isDirty) {
      final collectionId = node?.collectionId;
      final nodeId = node?.id;

      if (collectionId != null && nodeId != null) {
        isDirty = false;
        notifyListeners();

        // pass through repo and delegate api state to repo
        final result = await nodeService.saveNodeContent(
          collectionId,
          nodeId,
          content,
        );
        if (result is ApiSuccess<Node>) {
          nodeStore.selectNode(result.data);
          notifyListeners();
        } else if (result is ApiError) {
          print("Can't get updated node: ${result.code}");
        }
      }
    }
  }
}
