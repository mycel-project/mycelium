import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/data/services/node_service.dart';

class NodesViewModel extends ChangeNotifier {
  // Or view -> vm -> domain service -> store ?
  final NodeService service;
  final CollectionStore collectionStore;
  final NodeStore nodeStore;

  List<Node> nodes = [];
  List<NodeType> nodeTypes = [];
  Node? selectedNode;

  NodesViewModel(this.service, this.collectionStore, this.nodeStore) {
    collectionStore.addListener(_onCollectionChange);
    nodeStore.addListener(_onNodeChange);
    _init();
  }

  void _onNodeChange() {
    // ensure selected node from local node is aligned with source of truth
    final node = nodeStore.currentNode;
    if (node == null) return;

    final index = nodes.indexWhere((n) => n.id == node.id);

    if (index != -1) {
      nodes[index] = node;
    } else {
      nodes.add(node);
    }

    notifyListeners();
  }

  void selectNode(int id) {
    final node = nodes.firstWhere((n) => n.id == id);
    nodeStore.selectNode(node);
  }

  Future<void> _init() async {
    final result = await service.getNodeTypes();

    if (result is ApiSuccess<List<NodeType>>) {
      nodeTypes = result.data;
      notifyListeners();
    } else if (result is ApiError) {
      print("Can't get node types: ${result.code}");
    }

    final collectionId = collectionStore.currentCollection?.id;
    if (collectionId != null) {
      loadNodes(collectionId);
    }
  }

  void _onCollectionChange() {
    selectedNode = null;
    nodes = [];
    final collectionId = collectionStore.currentCollection?.id;
    if (collectionId != null) {
      loadNodes(collectionId);
    }
  }

  Future<void> loadNodes(int collectionId) async {
    final result = await service.getNodes(collectionId);

    if (result is ApiSuccess<List<Node>>) {
      nodes = result.data;
      notifyListeners();
    } else if (result is ApiError) {
      print("Can't get node : ${result.code}");
    }
  }

  @override
  void dispose() {
    collectionStore.removeListener(_onCollectionChange);
    super.dispose();
  }
}
