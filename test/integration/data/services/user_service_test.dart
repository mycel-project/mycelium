import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/user_conf_update.dart';
import 'package:mycelium/data/services/user_service.dart';
import '../../../helpers/api_client_helper.dart';

void main() {
  late UserService service;

  setUp(() {
    service = UserService(createTestApiClient());
  });

  test('getCurrentUser returns valid user', () async {
    final result = await service.getCurrentUser();
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<Map>());
    expect(json["data"]["id"], isA<String>());
    expect(json["data"]["name"], isA<String>());
  });

  test('updateUserConfig returns success', () async {
    final result = await service.updateUserConfig(UserConfUpdate({}));
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<Map>());
    expect(json["data"]["id"], isA<String>());
    expect(json["data"]["name"], isA<String>());
  });

  test('getUserConfigSchema returns success', () async {
    final result = await service.getUserConfigSchema();
    expect(result, isA<ApiSuccess>());
    final json = jsonDecode((result as ApiSuccess).data);
    expect(json["data"], isA<Map>());
  });
}
