import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/services/review_service.dart';

import '../../../helpers/api_client_helper.dart';

void main() {
  late ReviewService service;

  setUp(() {
    service = ReviewService(createTestApiClient());
  });

  test('getClozeRegex', () async {
    final result = await service.getClozeRegex();
    expect(result, isA<ApiSuccess>());
    final data = (result as ApiSuccess).data;
    expect(data, isA<String>());
  });

  test('getNextReview', () async {
    final result = await service.getNextReview("test", 0);
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<Map>());
    final node = Node.fromJson(json["data"]["node"]);
    expect(node, isA<Node>());
    final slot = json["data"]["slot"];
    expect(slot, isA<int>());
  });

  test('undoReview', () async {
    final result = await service.undoReview("test");
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<Map>());
    final node = Node.fromJson(json["data"]["node"]);
    expect(node, isA<Node>());
    final slot = json["data"]["slot"];
    expect(slot, isA<int>());
  });

  test('getCalendar', () async {
    final result = await service.getCalendar("test", 0);
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<List>());
  });

  test('reviewNode', () async {
    final result = await service.completeFragmentReview("test", "test", 10, 1, 0);
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<Map>());
    final node = Node.fromJson(json["data"]);
    expect(node, isA<Node>());
  });
}
