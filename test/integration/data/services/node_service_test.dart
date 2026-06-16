import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/services/node_service.dart';

import '../../../helpers/api_client_helper.dart';

void main() {
  late NodeService service;

  setUp(() {
    service = NodeService(createTestApiClient());
  });

  test('getNodes returns success', () async {
    final result = await service.getNodes("test");
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<List>());
      final nodes = (json["data"] as List)
      .map((e) => Node.fromJson(e))
      .toList();
      expect(nodes, isA<List<Node>>());
  });
}
