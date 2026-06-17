import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/local/api_preferences.dart';
import 'package:mycelium/data/local/token_preferences.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/check_api_usecase.dart';
import 'package:mycelium/domain/init_api_usecase.dart';
import 'package:mycelium/domain/init_data_usecase.dart';

class MockApiPreferences extends Mock implements ApiPreferences {}
class MockApiStore extends Mock implements ApiStore {}
class MockCheckApiUseCase extends Mock implements CheckApiUseCase {}
class MockInitDataUseCase extends Mock implements InitDataUseCase {}

void main() {
  late InitApiUseCase sut;
  late MockApiPreferences apiPreferences;
  late MockApiStore apiStore;
  late MockCheckApiUseCase checkApiUseCase;
  late MockInitDataUseCase initDataUseCase;
  late TokenPreferences tokenPreferences;

  setUp(() {
      apiPreferences = MockApiPreferences();
      apiStore = MockApiStore();
      checkApiUseCase = MockCheckApiUseCase();
      initDataUseCase = MockInitDataUseCase();
      tokenPreferences = TokenPreferences();
      sut = InitApiUseCase(apiStore, checkApiUseCase, apiPreferences, initDataUseCase, tokenPreferences);
  });

  group('initUrl', () {
      test('stored url → apiStore.setBaseUrl called with correct url', () async {
          when(() => apiPreferences.getBaseUrl()).thenAnswer((_) async => 'https://myapi.com');

          await sut.initApiUrl();

          verify(() => apiStore.setBaseUrl('https://myapi.com')).called(1);
      });

      test('empty url → apiStore.setBaseUrl called with empty string', () async {
          when(() => apiPreferences.getBaseUrl()).thenAnswer((_) async => null);

          await sut.initApiUrl();

          verify(() => apiStore.setBaseUrl('')).called(1);
      });
  });

  group('execute', () {
      test('empty url → checkApi and initData not called', () async {
          when(() => apiPreferences.getBaseUrl()).thenAnswer((_) async => '');
          when(() => apiStore.baseUrl).thenReturn('');

          await sut.execute();

          verifyNever(() => checkApiUseCase.execute());
          verifyNever(() => initDataUseCase.execute());
      });

      test('api reachable → initData called', () async {
          when(() => apiPreferences.getBaseUrl()).thenAnswer((_) async => 'https://myapi.com');
          when(() => apiStore.baseUrl).thenReturn('https://myapi.com');
          when(() => apiStore.status).thenReturn(ApiStatus.reachable);
          when(() => checkApiUseCase.execute()).thenAnswer((_) async => ApiStatus.reachable);
          when(() => initDataUseCase.execute()).thenAnswer((_) async {});

          await sut.execute();

          verify(() => initDataUseCase.execute()).called(1);
      });

      test('api non reachable → initData not called', () async {
          when(() => apiPreferences.getBaseUrl()).thenAnswer((_) async => 'https://myapi.com');
          when(() => apiStore.baseUrl).thenReturn('https://myapi.com');
          when(() => apiStore.status).thenReturn(ApiStatus.unreachable);
          when(() => checkApiUseCase.execute()).thenAnswer((_) async => ApiStatus.reachable);

          await sut.execute();

          verifyNever(() => initDataUseCase.execute());
      });
  });
}
