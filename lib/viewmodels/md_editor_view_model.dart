import 'package:flutter/material.dart';
import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/errors/node_update_errors.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/data/services/node_service.dart';
import 'package:mycelium/domain/cloze_mode.dart';
import 'package:mycelium/domain/review_usecase.dart';

class MdEditorViewModel extends ChangeNotifier {
  Node? node;

  NodeService nodeService;
  NodeStore nodeStore;
  ReviewStore reviewStore;
  NodeRepository nodeRepository;

  bool isAnswerVisible = false;
  bool isEditing = false;
  bool hasSelection = false;

  final ReviewUseCase reviewUseCase;
  TextSelection? selection;

  String? uiMessage;

  final ReviewRepository reviewRepository;

  MdEditorViewModel({
    required this.nodeService,
    required this.nodeStore,
    required this.reviewStore,
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

  void reviewSpore(int rating) {
    reviewRepository.reviewSpore(node!.collectionId, node!.id, 10, rating);
  }

  void reviewFragment() {
    reviewRepository.reviewFragment(node!.collectionId, node!.id, 10);
  }

  void nextReview() {
    reviewUseCase.handleNextReview();
  }

  bool isLocked() {
    return reviewStore.currentNodeId == node?.id &&
        isCurrentNodeSpore() &&
        !isAnswerVisible;
  }

  void _showMessage(String message) {
    uiMessage = message;
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      uiMessage = null;
      notifyListeners();
    });
  }

  bool _isUpdatingSelection = false;
  bool get isUpdatingSelection => _isUpdatingSelection;

  void updateSelection(TextSelection newSelection) {
    _isUpdatingSelection = true;
    selection = newSelection;
    hasSelection = !selection!.isCollapsed;
    notifyListeners();
    _isUpdatingSelection = false;
  }

  Future<void> createExtract(String extractType) async {
    final node = this.node;
    if (node == null) return;

    final result = await nodeRepository.createExtract(
      node.collectionId,
      node.id,
      content.substring(selection!.start, selection!.end),
      "0",
      selection!.start,
      selection!.end,
      nodeRepository.getNodeTypeByLabelSync(extractType)!.key,
    );
    result.fold((error) => _showMessage(error.toString()), (nodes) {
        for (final node in nodes) {
          if (node.id == this.node?.id) {
            loadNode(node);
          }
        }
        notifyListeners();
      }
    );
  }

  Future<void> createFragment() async {
    await createExtract("FRAGMENT");
  }

  Future<void> createSpore() async {
    await createExtract("SPORE");
  }

  bool isCurrentNodeSpore() {
    if (node != null) {
      final type = nodeRepository.getNodeTypeSync(node!.type);
      return type?.label == "SPORE";
    } else {
      return false;
    }
  }

  void editMode() {
    if (isCurrentNodeSpore() && !isEditing) {
      isEditing = true;
      content = node?.content?["0"] ?? "";
      notifyListeners();
    }
  }

  void showAnswer() {
    isAnswerVisible = true;
    content = reviewUseCase.transformClozeContent(
      node?.content?["0"] ?? "",
      mode: ClozeMode.show,
    );
    notifyListeners();
  }

  void loadNode(Node? node) {
    isAnswerVisible = false;
    if (node != null) {
      this.node = node;
      isDirty = false;
      isEditing = false;

      if (isCurrentNodeSpore()) {
        if (reviewStore.currentNodeId == node.id) {
          content = reviewUseCase.transformClozeContent(
            node.content?["0"] ?? "",
            mode: ClozeMode.hide,
          );
        } else {
          content = node.content?["0"] ?? "";
        }
      } else {
        content = node.content?["0"] ?? "";
      }

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
        final result = await nodeRepository.updateNodeContent(
          collectionId,
          nodeId,
          content,
        );

        result.fold(
          (error) {
            print("Can't update node: $error");
            if (error is InvalidNodeUpdateError) {
              _showMessage("Spore must contain at least one cloze field");
            } else {
              _showMessage("Can't update node");
            }
          },
          (node) {
            isDirty = false;
            isEditing = false;
            nodeStore.selectNode(node);
            notifyListeners();
          },
        );
      }
    }
  }
}
