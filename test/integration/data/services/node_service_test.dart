import 'dart:convert';
import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/outline_entry.dart';
import 'package:mycelium/data/services/node_service.dart';

import '../../../helpers/api_client_helper.dart';

void main() {
  late NodeService service;

  void testNodeDetailView(result) {
    if (result is ApiError) {
      log("${result.code} ${result.message} ${result.statusCode}");
    }
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<Map>());
    final node = Node.fromJson(json["data"]);
    expect(node, isA<Node>());
  }

  void testListNodeView(result) {
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<List>());
    final nodes = (json["data"] as List).map((e) => Node.fromJson(e)).toList();
    expect(nodes, isA<List<Node>>());
  }

  setUp(() {
    service = NodeService(createTestApiClient());
  });

  test('getNodes', () async {
    final result = await service.getNodes("test");
    testListNodeView(result);
  });

  test('getDeletedNodes', () async {
    final result = await service.getDeletedNodes("test");
    testListNodeView(result);
  });

  test('getNode', () async {
    final result = await service.getNode("test", "test");
    testNodeDetailView(result);
  });

  test('getPriorities', () async {
    final result = await service.getPriorities("test");
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<List>());
    final priorities = json["data"];
    expect(priorities, isA<List>());
  });

  test('getRootNode', () async {
    final result = await service.getRootNode("test", "test");
    testNodeDetailView(result);
  });

  test('deletetNode', () async {
    final result = await service.deleteNode("test", "test");
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<Map>());
  });

  test('getOutline', () async {
    final result = await service.getOutline("test", "test");
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<Map>());
    final entries = (json["data"]["entries"] as List? ?? [])
        .map((e) => OutlineEntry.fromJson(e))
        .toList();
    expect(entries, isA<List>());
  });

  test('splitNode', () async {
    final result = await service.splitNode("test", "test", 2, 0);
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<List>());
  });

  test('reprioritiseNode', () async {
    final result = await service.reprioritise("test", "test", 7, 0);
    testNodeDetailView(result);
  });

  test('rescheduleNode', () async {
    final result = await service.reschedule("test", "test", "2099-10-19", 0, 0);
    testNodeDetailView(result);
  });

  test('restoreNode', () async {
    final result = await service.restoreNode("test", "test", true, true);
    testListNodeView(result);
  });

  test('fetchRessourceFromUrl', () async {
    final result = await service.fetchRessourceFromUrl("test", "test", 7);
    testNodeDetailView(result);
  });

  test('updateNode', () async {
    final result = await service.updateNode("test", "test", {});
    testNodeDetailView(result);
  });

  test('updateNodeDismiss', () async {
    final result = await service.updateNodeDismiss("test", "test", value: true);
    testNodeDetailView(result);
  });

  test('createExtract', () async {
    final result = await service.createExtract(
      "test",
      "test",
      "test",
      "test",
      0,
      10,
      "fragment",
      0,
    );
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<Map>());
  });

  test('removeLinks', () async {
    final result = await service.removeLinks(
      "test",
      "test",
      "test",
      "content",
      0,
      10,
    );
    testNodeDetailView(result);
  });

  test('saveNodeContent', () async {
    final result = await service.saveNodeContent("test", "test", {
      "test": "test",
    });
    testNodeDetailView(result);
  });
}
