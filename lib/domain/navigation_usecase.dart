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

  Future<void> navigateTo(int nodeId) async {
    final colId = _collectionStore.currentCollection?.id;
    if (colId == null) return;

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
}
