import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/data/services/node_service.dart';

class NodesViewModel extends ChangeNotifier {
  final NodeService service;
  final CollectionStore collectionStore;

  List<Node> nodes = [];
  List<NodeType> nodeTypes = [];
  Node? selectedNode;

  NodesViewModel(this.service, this.collectionStore) {
    collectionStore.addListener(_onCollectionChange);
    _init();
  }

  Future<void> _init() async {
    nodeTypes = await service.getNodeTypes();
    notifyListeners();
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
    nodes = await service.getNodes(collectionId);
    notifyListeners();
  }

  @override
  void dispose() {
    collectionStore.removeListener(_onCollectionChange);
    super.dispose();
  }
}
