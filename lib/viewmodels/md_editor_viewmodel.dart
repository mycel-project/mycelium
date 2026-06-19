import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/core/stores/scroll_position_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/outline_entry.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/data/services/node_service.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/cloze_mode.dart';
import 'package:mycelium/domain/create_extract_usecase.dart';
import 'package:mycelium/domain/get_outline_usecase.dart';
import 'package:mycelium/domain/navigation_usecase.dart';
import 'package:mycelium/domain/node_usecase.dart';
import 'package:mycelium/domain/refresh_current_node_usecase.dart';
import 'package:mycelium/domain/refresh_priorities_usecase.dart';
import 'package:mycelium/domain/remove_links_usecase.dart';
import 'package:mycelium/domain/review_node_usecase.dart';
import 'package:mycelium/domain/review_usecase.dart';
import 'package:mycelium/domain/split_node_usecase.dart';
import 'package:mycelium/domain/update_priority_usecase.dart';

enum ActionMode { undo, redo }

class MdEditorViewModel extends ChangeNotifier {
  Node? node;

  NodeService nodeService;
  NodeStore nodeStore;
  ReviewStore reviewStore;
  CollectionStore collectionStore;
  NodeRepository nodeRepository;
  NotificationBus notificationBus;
  NavigationUseCase navigationUseCase;
  ReviewUseCase reviewUseCase;
  CreateExtractUseCase createExtractUseCase;
  ReviewNodeUseCase reviewNodeUseCase;
  RemoveLinksUseCase removeLinksUseCase;
  UpdatePriorityUseCase updatePriorityUseCase;
  RefreshPrioritiesUseCase refreshPrioritiesUseCase;
  ScrollPositionStore scrollPositionStore;
  GetOutlineUseCase getOutlineUseCase;
  SplitNodeUseCase splitNodeUseCase;
  RefreshCurrentNodeUseCase refreshCurrentNodeUseCase;

  bool isAnswerVisible = false;
  bool isEditing = false;
  bool hasSelection = false;

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
    this.createExtractUseCase,
    this.reviewNodeUseCase,
    this.removeLinksUseCase,
    this.updatePriorityUseCase,
    this.refreshPrioritiesUseCase,
    this.scrollPositionStore,
    this.getOutlineUseCase,
    this.splitNodeUseCase,
    this.refreshCurrentNodeUseCase,
  ) {
    nodeStore.addListener(_onNodeStoreChanged);
    apiStore.addListener(_onApiStoreChanged);
    _onNodeStoreChanged();
    undoController.addListener(_onUndoStateChanged);
  }

  bool _noClozeField = false;

  bool? get dismissState => node?.getFragment()?.dismiss;

  bool _showUnsavedChangesDialog = false;
  bool get showUnsavedChangesDialog => _showUnsavedChangesDialog;
  Node? _pendingNode;

  bool isUpdatingPosition = false;

  void Function(String content, int? cursor)? onContentCommand;

  void Function()? goScrollTop;

  // To update content from vm
  void _applyContent(String newContent, {int? cursor}) {
    content = newContent;
    onContentCommand?.call(newContent, cursor);
  }

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
    if (nodeStore.previousNode?.id == null ||
        nodeStore.currentNode?.id != nodeStore.previousNode?.id) {
      goScrollTop?.call();
    }
    setNoClozeField(false);
    loadNode(nodeStore.currentNode);
  }

  void updateScroll(double progress) {
    if (progress.isNaN || progress.isInfinite) return;
    isUpdatingPosition = true;
    scrollPositionStore.update((progress * content.length).toInt());
    isUpdatingPosition = false;
  }

  void confirmDiscardChanges() {
    _showUnsavedChangesDialog = false;
    _pendingNode = null;
    isDirty = false;
    goScrollTop?.call();
    setNoClozeField(false);
    loadNode(nodeStore.currentNode);
    notifyListeners();
  }

  void cancelNodeChange() {
    _showUnsavedChangesDialog = false;
    nodeStore.selectNode(
      _pendingNode,
    ); // Now that store previousNode in nodeStore, could use that instead.
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
    undoController.removeListener(_onUndoStateChanged);
    undoController.dispose();
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

  bool _handleReviewError(ApiError error, String context) {
    // put that in ReviewNodeUseCase
    switch (error.code) {
      case "NO_PENDING_NODE":
        notificationBus.showWarning(
          "Review not taken into account, Mycel probably restarted, please retry.",
        );
        return true;
      default:
        notificationBus.showError("Cannot complete $context review", error);
        return false;
    }
  }

  Future<void> _handleReview(String type, {int? rating}) async {
    if (!await saveContent()) return;

    final error = await reviewNodeUseCase.execute(
      node!.collectionId,
      node!.id,
      type,
      rating: rating,
    );

    if (error != null) {
      _handleReviewError(error, type);
      return;
    }

    notifyListeners();

    if (!await nextReview()) {
      reviewStore.setLoading();
    }
  }

  Future<void> handleSporeReview(int rating) async =>
      _handleReview("spore", rating: rating);

  Future<void> handleFragmentReview() async => _handleReview("fragment");

  Future<bool> nextReview() async {
    final result = await reviewUseCase.handleNextReview();
    if (result case DomainError error) {
      notificationBus.showError("Cannot get review", error);
      return false;
    }
    return true;
  }

  // Undo
  final undoController = UndoHistoryController();
  ActionMode historyButtonMode = ActionMode.undo;

  bool get canPerformHistoryAction => historyButtonMode == ActionMode.undo
      ? undoController.value.canUndo
      : undoController.value.canRedo;

  void performHistoryAction() => historyButtonMode == ActionMode.undo
      ? undoController.undo()
      : undoController.redo();

  void toggleHistoryMode() {
    historyButtonMode = historyButtonMode == ActionMode.undo
        ? ActionMode.redo
        : ActionMode.undo;
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void _onUndoStateChanged() => notifyListeners();

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
    if (await nodeUseCase.deleteNode(colId, node.id)) notifyListeners();
  }

  Future<Node?> createExtract(String extractType, String currentContent) async {
    final node = this.node;
    TextSelection? sel = selection;
    if (node == null || sel == null) return null;
    content = currentContent;
    await saveContent();
    final extract = await createExtractUseCase.execute(
      node,
      extractType,
      currentContent,
      sel,
      onMismatch: () => isDirty = true,
    );
    if (extract is Node) {
      notifyListeners();
      return extract;
    } else {
      return null;
    }
  }

  Future<Node?> createFragment(String currentContent) async {
    return await createExtract("fragment", currentContent);
  }

  Future<Node?> createSpore(String currentContent) async {
    return await createExtract("spore", currentContent);
  }

  Future<void> removeLinks(String currentContent) async {
    final node = this.node;
    if (node == null) return;
    final sel = hasSelection ? selection : null;
    content = currentContent;
    await saveContent();
    final result = await removeLinksUseCase.execute(node, currentContent, sel);
    if (result) notifyListeners();
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
        // need to change in node store ?
        node = data;
        notifyListeners();
      case DomainError error:
        notificationBus.showError("Can't toggle dismiss", error);
    }
  }

  bool isCurrentNodeSpore() {
    if (node != null) {
      return node?.type == "spore";
    } else {
      return false;
    }
  }

  void editMode() {
    if (isCurrentNodeSpore() && !isEditing) {
      isEditing = true;
      _applyContent(node?.firstFieldValue ?? "");
      notifyListeners();
    }
  }

  void showAnswer() {
    isAnswerVisible = true;
    final newContent = reviewUseCase.transformClozeContent(
      node?.firstFieldValue ?? "",
      mode: ClozeMode.show,
    );
    _applyContent(newContent);
    notifyListeners();
  }

  void reloadCurrentNode() {
    Node? node = nodeStore.currentNode;
    nodeStore.selectNode(node);
  }

  void loadNode(Node? node, {bool forceReload = false}) {
    isAnswerVisible = false;
    if (node != null) {
      this.node = node;
      isDirty = false;
      undoController.value = UndoHistoryValue.empty;
      isEditing = false;
      String newContent;
      if (isCurrentNodeSpore()) {
        if (reviewStore.currentNodeId == node.id) {
          newContent = reviewUseCase.transformClozeContent(
            node.firstFieldValue,
            mode: ClozeMode.hide,
          );
        } else {
          newContent = node.firstFieldValue;
        }
      } else {
        newContent = node.firstFieldValue;
      }

      _applyContent(newContent);
      notifyListeners();
    } else {
      this.node = null;
      _applyContent("");
      notifyListeners();
      isDirty = false;
    }
  }

  Future<void> deleteBeforeCursor(String currentContent) async {
    final pos = cursorPosition;
    if (pos == null) return;
    final newContent = currentContent.substring(pos);
    _applyContent(newContent, cursor: 0);
    content = newContent;
    isDirty = true;
    await saveContent();
  }

  Future<void> deleteAfterCursor(String currentContent) async {
    final pos = cursorPosition;
    if (pos == null) return;
    final newContent = currentContent.substring(0, pos);
    _applyContent(newContent, cursor: pos);
    content = newContent;
    isDirty = true;
    await saveContent();
  }

  void updateContent(String value) {
    content = value;
    isDirty = true;
    tryAutoSave();
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

  Future<void> undoReview() async {
    final collectionId = node?.collectionId;
    if (collectionId == null) return;
    await reviewUseCase.undo(collectionId);
  }

  bool get noClozeField => _noClozeField;

  void setNoClozeField(bool value) {
    if (_noClozeField != value) {
      _noClozeField = value;
      notifyListeners();
    }
  }

  Future<bool> saveContent() async {
    /// Returns true if the save completed or was not required, false if it failed.
    _debounceTimer?.cancel();
    if (!isDirty) return true;
    final collectionId = node?.collectionId;
    final nodeId = node?.id;
    if (collectionId == null || nodeId == null) return false;
    final contentAtSaveTime = content;
    final result = await nodeRepository.updateNodeContent(
      collectionId,
      nodeId,
      {node?.firstFieldKey: content},
    );
    switch (result) {
      case ApiSuccess():
        node = result.data;
        // Need to reput node in node store ? to update content...
        if (content == contentAtSaveTime) isDirty = false;
        setNoClozeField(false);
        notifyListeners();
        return true;
      case DomainError error:
        if (error.code == "NO_CLOZE_FIELD_ERROR") {
          if (!noClozeField) {
            setNoClozeField(true);
            notificationBus.showError("Please add at least one cloze field.");
          }
        } else {
          notificationBus.showError("Cannot save content", error);
        }
    }
    return false;
  }

  Future<bool> updatePriority(String nodeId, double priority) async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return false;
    final result = await updatePriorityUseCase.execute(colId, nodeId, priority);
    if (result is Node) {
      nodeStore.selectNode(node);
      await refreshPriorities();
      notifyListeners();
      return true;
    }
    return false;
  }

  List<Node> getNodes() => nodeRepository.nodeCache.values.toList();

  Future<bool> refreshPriorities() async {
    final result = await refreshPrioritiesUseCase.execute();
    if (result) notifyListeners();
    return result;
  }

  Future<List<OutlineEntry>?> getCurrentOutline() async {
    Node? node = nodeStore.currentNode;
    final colId = collectionStore.currentCollection?.id;
    if (colId == null || node == null) return null;
    return await getOutlineUseCase.execute(colId, node.id, forceRefresh: true);
  }

  Future<bool> splitNode(int level) async {
    Node? node = nodeStore.currentNode;
    final colId = collectionStore.currentCollection?.id;
    if (colId == null || node == null) return false;
    final result = await splitNodeUseCase.execute(colId, node.id, level);
    return result != null;
  }

  Future<void> refreshCurrentNode() async {
    final result = await refreshCurrentNodeUseCase.execute();
    if (result is Node) {
      nodeStore.selectNode(result);
    }
  }
}
