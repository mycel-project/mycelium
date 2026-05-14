import 'package:flutter/material.dart';
import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/navigation_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/repositories/node_repository.dart';

/// Handles node navigation and history tracking.
/// To navigate without recording history use selectNode from NodeStore directly (as done in back() and forward()).
/// Deleted nodes are kept in history to support undo, they are simply skipped during navigation.
/// ClaudeAI
class NavigationUseCase extends ChangeNotifier {
  final NodeRepository _nodeRepository;
  final NodeStore _nodeStore;
  final NavigationStore _navigationStore;
  final CollectionStore _collectionStore;

  bool _canGoBack = false;
  bool _canGoForward = false;

  bool get canGoBack => _canGoBack;
  bool get canGoForward => _canGoForward;
  
  int? _cursorBeforeNavigation; // to allow 1 undo when not discarding action for instance
  bool _didPushHistory = false; // specify if last action pushed into history to know when we undo if we have to delete this cancelled entry
  
  NavigationUseCase(
    this._nodeRepository,
    this._nodeStore,
    this._navigationStore,
    this._collectionStore,
  );

  bool _isValidDestination(int id) =>
      _nodeRepository.nodeCache.containsKey(id) &&
      id != _navigationStore.current;

  void _updateCanNavigate() {
    _canGoBack = false;
    for (int i = _navigationStore.cursorIndex - 1; i >= 0; i--) {
      final id = _navigationStore.idAtIndex(i);
      if (id != null && _isValidDestination(id)) {
        _canGoBack = true;
        break;
      }
    }

    _canGoForward = false;
    for (
      int i = _navigationStore.cursorIndex + 1;
      i < _navigationStore.historyLength;
      i++
    ) {
      final id = _navigationStore.idAtIndex(i);
      if (id != null && _isValidDestination(id)) {
        _canGoForward = true;
        break;
      }
    }

    notifyListeners();
  }

  void pushToHistory(int nodeId, {int offset = 0}) {
    /// To push a node in history without navigating to it, when extracting for instance. Not impacted by undo
    final insertIndex = _navigationStore.cursorIndex + offset;
    _navigationStore.insertAt(insertIndex, nodeId);
    _updateCanNavigate();
  }

  Future<void> navigateTo(int nodeId) async {
    final colId = _collectionStore.currentCollection?.id;
    if (colId == null) return;
    _cursorBeforeNavigation = _navigationStore.cursorIndex;
    _didPushHistory = true;

    final result = await _nodeRepository.getNode(colId, nodeId);
    result.fold((err) => null, (node) {
      _nodeStore.selectNode(node);
      _navigationStore.push(nodeId);
      _updateCanNavigate();
    });
  }

  void onNodesDeleted(List<int> deletedIds) {
    _updateCanNavigate();
  }

  Future<int?> back() async {
    final colId = _collectionStore.currentCollection?.id;
    if (colId == null) return null;
    _cursorBeforeNavigation = _navigationStore.cursorIndex;
    _didPushHistory = false;
    
    for (int i = _navigationStore.cursorIndex - 1; i >= 0; i--) {
      final id = _navigationStore.idAtIndex(i);
      if (id == null || !_isValidDestination(id)) continue;

      final result = await _nodeRepository.getNode(colId, id);
      final node = result.fold((err) => null, (node) => node);

      if (node != null) {
        _navigationStore.moveCursorTo(i);
        _nodeStore.selectNode(node);
        _updateCanNavigate();
        return node.id;
      }
    }
    return null;
  }

  Future<int?> forward() async {
    final colId = _collectionStore.currentCollection?.id;
    if (colId == null) return null;
    _cursorBeforeNavigation = _navigationStore.cursorIndex;
    _didPushHistory = false;
    
    for (
      int i = _navigationStore.cursorIndex + 1;
      i < _navigationStore.historyLength;
      i++
    ) {
      final id = _navigationStore.idAtIndex(i);
      if (id == null || !_isValidDestination(id)) continue;

      final result = await _nodeRepository.getNode(colId, id);
      final node = result.fold((err) => null, (node) => node);

      if (node != null) {
        _navigationStore.moveCursorTo(i);
        _nodeStore.selectNode(node);
        _updateCanNavigate();
        return node.id;
      }
    }
    return null;
  }

  void undoLastNavigation() {
    if (_cursorBeforeNavigation == null) return;
    _navigationStore.moveCursorTo(_cursorBeforeNavigation!);
    if (_didPushHistory) {
      _navigationStore.truncateFrom(_cursorBeforeNavigation! + 1);
    }
    _cursorBeforeNavigation = null;
    _updateCanNavigate();
  }
}
