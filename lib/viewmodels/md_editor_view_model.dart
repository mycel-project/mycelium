import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/services/node_service.dart';

class MdEditorViewModel extends ChangeNotifier {
  Node? node;

  NodeService nodeService;
  NodeStore nodeStore;

  MdEditorViewModel({required this.nodeService, required this.nodeStore}) {
    nodeStore.addListener(_onNodeStoreChanged);
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

  void loadNode(Node? node) {
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
