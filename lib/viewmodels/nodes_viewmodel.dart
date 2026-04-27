import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/api_result.dart';
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
    final result = await service.getNodeTypes();

    if (result is ApiSuccess<List<NodeType>>) {
      nodeTypes = result.data;
      notifyListeners();
    } else if (result is ApiError) {
      print("Can't get node types: ${result.code}");
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
