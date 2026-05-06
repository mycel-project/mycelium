import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/notifications/notification.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/data/services/node_service.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/cloze_mode.dart';
import 'package:mycelium/domain/navigation_usecase.dart';
import 'package:mycelium/domain/node_usecase.dart';
import 'package:mycelium/domain/review_usecase.dart';

class MdEditorViewModel extends ChangeNotifier {
  Node? node;

  NodeService nodeService;
  NodeStore nodeStore;
  ReviewStore reviewStore;
  CollectionStore collectionStore;
  NodeRepository nodeRepository;
  NotificationBus notificationBus;
  NavigationUseCase navigationUseCase;

  bool isAnswerVisible = false;
  bool isEditing = false;
  bool hasSelection = false;

  final ReviewUseCase reviewUseCase;
  final NodeUseCase nodeUseCase;
  TextSelection? selection;

  ApiStore apiStore;

  int? cursorPosition;

  final ReviewRepository reviewRepository;

  MdEditorViewModel(
    this.nodeService,
    this.nodeStore,
    this.reviewStore,
    this.nodeRepository,
    this.reviewUseCase,
    this.reviewRepository,
    this.nodeUseCase,
    this.collectionStore,
    this.apiStore,
    this.notificationBus,
    this.navigationUseCase,
  ) {
    nodeStore.addListener(_onNodeStoreChanged);
    apiStore.addListener(_onApiStoreChanged);
    _onNodeStoreChanged();
  }

  bool? get dismissState => node?.typeData?['dismiss'] as bool?;

  bool _showUnsavedChangesDialog = false;
  bool get showUnsavedChangesDialog => _showUnsavedChangesDialog;
  Node? _pendingNode;

  Future<void> _onNodeStoreChanged() async {
    if (_showUnsavedChangesDialog) return;
    if (_pendingNode != null) {
      _pendingNode = null;
      return;
    }
    if (!await saveContent()) {
      _pendingNode = node;
      _showUnsavedChangesDialog = true;
      notifyListeners();
      return;
    }
    loadNode(nodeStore.currentNode);
  }

  void confirmDiscardChanges() {
    _showUnsavedChangesDialog = false;
    loadNode(nodeStore.currentNode);
    _pendingNode = null;
    notifyListeners();
  }

  void cancelNodeChange() {
    _showUnsavedChangesDialog = false;
    nodeStore.selectNode(_pendingNode);
    navigationUseCase.undoLastNavigation();
    notifyListeners();
  }

  Timer? _debounceTimer;

  /// User preference for autosave (hardcoded for now, should come from config/store).
  static bool autosaveFromParam = true;

  /// Reference value to restore autosave to when connection comes back.
  bool defaultAutoSave = autosaveFromParam;

  /// Current autosave state — disabled when offline, restored to [defaultAutoSave] on reconnect. Not instanciated from defaultAutoSave because it is not static
  bool _autosave = autosaveFromParam;

  @override
  void dispose() {
    nodeStore.removeListener(_onNodeStoreChanged);
    super.dispose();
  }

  void _onApiStoreChanged() {
    if (apiStore.status == ApiStatus.reachable) {
      _autosave = defaultAutoSave;
      tryAutoSave();
    } else {
      _autosave = false;
    }
  }

  String content = "";
  bool isDirty = false;

  Future<bool> reviewSpore(int rating) async {
    final result = reviewRepository.reviewSpore(
      node!.collectionId,
      node!.id,
      10,
      rating,
    );
    if (result case ApiError error) {
      notificationBus.showError("Cannot complete Spore review", error);
      return false;
    }
    return true;
  }

  Future<bool> reviewFragment() async {
    final result = reviewRepository.reviewFragment(
      node!.collectionId,
      node!.id,
      10,
    );
    if (result case ApiError error) {
      notificationBus.showError("Cannot complete Fragment review", error);
      return false;
    }
    return true;
  }

  Future<void> _handleReview(Future<bool> Function() reviewAction) async {
    if (!await saveContent()) return;
    if (!await reviewAction()) return;
    if (!await nextReview()) {
      reviewStore.setLoading();
    }
  }

  Future<void> handleSporeReview(int rating) =>
      _handleReview(() => reviewSpore(rating));
  Future<void> handleFragmentReview() => _handleReview(reviewFragment);

  Future<bool> nextReview() async {
    final result = await reviewUseCase.handleNextReview();
    if (result case ApiError error) {
      final msg = error.code == "no_collection"
          ? "No collection selected"
          : "Cannot load next review";
      notificationBus.showError(msg, error);
      return false;
    }
    return true;
  }

  bool isLocked() {
    return reviewStore.currentNodeId == node?.id &&
        isCurrentNodeSpore() &&
        !isAnswerVisible;
  }

  bool _isUpdatingSelection = false;
  bool get isUpdatingSelection => _isUpdatingSelection;

  bool _isUpdatingCursor = false;
  bool get isUpdatingCursor => _isUpdatingCursor;

  bool _activeKeyobard = false;
  bool get activeKeyboard => _activeKeyobard;

  void toggleKeyboard() {
    _activeKeyobard = !_activeKeyobard;
    notifyListeners();
  }

  void onCursorChanged(int? position) {
    _isUpdatingCursor = true;
    cursorPosition = (position == null || position < 0) ? null : position;
    print('onCursorChanged: $position, hasCursor: $hasCursor');
    notifyListeners();
    _isUpdatingCursor = false;
  }

  bool get hasCursor => cursorPosition != null;

  void updateSelection(TextSelection? newSelection) {
    _isUpdatingSelection = true;
    selection = newSelection;
    hasSelection = newSelection != null && !newSelection.isCollapsed;
    notifyListeners();
    _isUpdatingSelection = false;
  }

  Future<void> deleteNode() async {
    final colId = collectionStore.currentCollection?.id;
    final node = this.node;
    if (colId == null || node == null) return;
    await nodeUseCase.deleteNode(colId, node.id);
    notifyListeners();
  }

  Future<void> createExtract(String extractType) async {
    final node = this.node;
    if (node == null) return;

    final nodeType = nodeRepository.getNodeTypeByLabelSync(extractType);
    if (nodeType == null) {
      notificationBus.show(
        "Cannot extract: unknown node type: $extractType",
        NotificationType.error,
      );
      return;
    }

    final result = await nodeRepository.createExtract(
      node.collectionId,
      node.id,
      content.substring(selection!.start, selection!.end),
      "0",
      selection!.start,
      selection!.end,
      nodeType.key,
    );
    result.fold(
      (error) => notificationBus.show(error.toString(), NotificationType.error),
      (nodes) {
        for (final node in nodes) {
          if (node.id == this.node?.id) {
            nodeStore.selectNode(node);
          }
        }
        notifyListeners();
      },
    );
  }

  Future<void> createFragment() async {
    await createExtract("FRAGMENT");
  }

  Future<void> createSpore() async {
    await createExtract("SPORE");
  }

  Future<void> toggleDismiss() async {
    final collectionId = node?.collectionId;
    final nodeId = node?.id;
    final dismiss = dismissState;
    if (dismiss == null || collectionId == null || nodeId == null) return;

    final result = await nodeRepository.updateNodeDismiss(
      collectionId,
      nodeId,
      !dismiss,
    );
    switch (result) {
      case ApiSuccess(:final data):
        node = data;
        notifyListeners();
      case ApiError(:final code):
        notificationBus.show(
          "Can't toggle dismiss : $code",
          NotificationType.error,
        );
    }
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

  void loadNode(Node? node, {bool forceReload = false}) {
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

  int? targetCursorPosition; // used to move cursor manually

  Future<void> deleteBeforeCursor() async {
    final pos = cursorPosition;
    if (pos == null) return;
    targetCursorPosition = 0;
    updateContent(content.substring(pos));
    await saveContent();
  }

  Future<void> deleteAfterCursor() async {
    final pos = cursorPosition;
    if (pos == null) return;
    targetCursorPosition = pos;
    updateContent(content.substring(0, pos));
    await saveContent();
  }

  void updateContent(String value) {
    content = value;
    isDirty = true;
    tryAutoSave();
    notifyListeners();
  }

  void tryAutoSave() {
    if (_autosave) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
        saveContent();
      });
    }
  }

  bool hasChildren() {
    final currentNode = node;
    if (currentNode == null) return false;
    return nodeUseCase.hasChildren(currentNode.id);
  }

  Future<bool> saveContent() async {
    /// Returns true if the save completed or was not required, false if it failed.
    _debounceTimer?.cancel();
    if (!isDirty) return true;
    final collectionId = node?.collectionId;
    final nodeId = node?.id;
    if (collectionId == null || nodeId == null) return false;

    final result = await nodeRepository.updateNodeContent(
      collectionId,
      nodeId,
      content,
    );
    switch (result) {
      case ApiSuccess():
        isDirty = false;
        isEditing = false;
        notifyListeners();
        return true;
      case ApiError error:
        notificationBus.showError("Cannot save content", error);
        return false;
    }
  }
}
