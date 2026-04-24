import 'package:flutter/material.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/data/services/node_service.dart';
import 'package:mycelium/viewmodels/collections_viewmodel.dart';

class NodesViewModel extends ChangeNotifier {
  final NodeService service;
  final CollectionsViewModel collectionsVM;

  NodesViewModel(this.service, this.collectionsVM) {
    collectionsVM.addListener(_onCollectionChange);
    _init();
  }

  List<Node> nodes = [];
  List<NodeType> nodeTypes = [];
  Node? selectedNode;

  Future<void> _init() async {
    nodeTypes = await service.getNodeTypes();
    notifyListeners();
  }

  void _onCollectionChange() {
    selectedNode = null;
    nodes = [];

    final collectionId = collectionsVM.selectedCollection?.id;
    if (collectionId != null) {
      loadNodes(collectionId);
    }
  }

  Future<void> loadNodes(int collectionId) async {
    nodes = await service.getNodes(collectionId);
    notifyListeners();
  }
}
