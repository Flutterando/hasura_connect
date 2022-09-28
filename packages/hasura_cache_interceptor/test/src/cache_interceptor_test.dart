// ignore_for_file: prefer_single_quotes


import 'package:hasura_cache_interceptor/src/cache_interceptor.dart';
import 'package:hasura_cache_interceptor/src/services/storage_service_interface.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

class MockStorageService extends Mock implements IStorageService {}

class HasuraConnectMock extends Mock implements HasuraConnect {}

void main() {
  late MockStorageService storage;
  late CacheInterceptor cacheInterceptor;
  late HasuraConnect hasuraConnect;
  setUp(() {
    hasuraConnect = HasuraConnectMock();
    storage = MockStorageService();
    cacheInterceptor = CacheInterceptor(storage);
  });

  tearDown(() async {
    // await cacheInterceptor.clearAllCache();
  });

  group('onError -', () {
    test('Erro genérico', () async {
      when(() => storage.containsKey(any())).thenAnswer(
        (realInvocation) async => false,
      );
      final requestMock =
          Request(url: '', query: const Query(document: 'query'));
      final error = HasuraRequestError.fromException(
        'Generic Error',
        Exception('Generic Error'),
        request: requestMock,
      );
      final response = await cacheInterceptor.onError(error, hasuraConnect);
      expect(response, error);
    });
    group('Sem conexão:', () {
      test('Sem cache salvo deve retornar a exceção', () async {
        when(() => storage.containsKey(any()))
            .thenAnswer((realInvocation) async => false);
        final request = Request(url: '', query: const Query(document: 'query'));
        final error = HasuraRequestError.fromException(
          'Connection Rejected',
          Exception('Connection Rejected'),
          request: request,
        );
        final response = await cacheInterceptor.onError(error, hasuraConnect);
        expect(response, error);
      });
      test('Com cache salvo deve retornar o cache', () async {
        final cachedData = {'cache_mock_key': 'cache_mock_value'};

        when(() => storage.containsKey(any()))
            .thenAnswer((realInvocation) async => true);
        when(() => storage.get(any()))
            .thenAnswer((realInvocation) async => cachedData);

        final request = Request(url: '', query: const Query(document: 'query'));
        final error = HasuraRequestError.fromException(
          'Connection Rejected',
          Exception('Connection Rejected'),
          request: request,
        );
        final Response response =
            await cacheInterceptor.onError(error, hasuraConnect);
        expect(response.data, cachedData);
      });
    });
  });

  group('onResponse -', () {
    test('Sem Key na Query - Deve salvar o cache', () async {
      final requestMock = Request(
        url: 'mock_url',
        query: const Query(document: 'mock_request_document'),
      );
      final responseMock = Response(
        request: requestMock,
        statusCode: 200,
        data: {'mock_key': 'mock_value'},
      );
      final key = const Uuid().v5(
        CacheInterceptor.namespaceKey,
        '${requestMock.url}: ${requestMock.query}',
      );
      final cacheMock = {};
      when(() => storage.put(any(), any())).thenAnswer(
        (realInvocation) async {
          final key = realInvocation.positionalArguments[0];
          final value = realInvocation.positionalArguments[1];
          cacheMock[key] = value;
        },
      );

      await cacheInterceptor.onResponse(responseMock, hasuraConnect);
      expect(cacheMock, {key: responseMock.data});
    });

    test('Com Key na Query - Deve salvar o cache', () async {
      final requestMock = Request(
        url: 'mock_url',
        query: const Query(
          document: 'mock_request_document',
          key: 'mock_query_key',
        ),
      );
      final responseMock = Response(
        request: requestMock,
        statusCode: 200,
        data: {'mock_key': 'mock_value'},
      );
      final key = const Uuid().v5(
        CacheInterceptor.namespaceKey,
        '${requestMock.url}: ${requestMock.query.key}',
      );
      final cacheMock = {};
      when(() => storage.put(any(), any())).thenAnswer(
        (realInvocation) async {
          final key = realInvocation.positionalArguments[0];
          final value = realInvocation.positionalArguments[1];
          cacheMock[key] = value;
        },
      );

      await cacheInterceptor.onResponse(responseMock, hasuraConnect);
      expect(cacheMock, {key: responseMock.data});
    });
  });

  group('onSubscription -', () {
    test('Deve mostrar o cache e depois o response original', () async {
      final requestMock =
          Request(url: 'mock_url', query: const Query(document: 'query'));
      final snapshotMock = Snapshot(query: requestMock.query);
      final key = const Uuid().v5(
        CacheInterceptor.namespaceKey,
        '${requestMock.url}: ${requestMock.query}',
      );
      final cacheMock = {key: '{"cache_mock_key": "cache_mock_value"}'};
      final responseMock = {'mock_key': 'mock_value'};

      when(() => storage.containsKey(any())).thenAnswer(
        (realInvocation) async =>
            cacheMock.containsKey(realInvocation.positionalArguments.first),
      );
      when(() => storage.get(any())).thenAnswer(
        (realInvocation) async =>
            cacheMock[realInvocation.positionalArguments.first],
      );
      when(() => storage.put(any(), any()))
          .thenAnswer((realInvocation) async {});

      await cacheInterceptor.onSubscription(requestMock, snapshotMock);

      final firstValue = await snapshotMock.first
          .timeout(const Duration(seconds: 1), onTimeout: () => null);
      snapshotMock.add(responseMock);
      final seccondValue = await snapshotMock.first
          .timeout(const Duration(seconds: 1), onTimeout: () => null);
      expect(firstValue, cacheMock[key]);
      expect(seccondValue, responseMock);
    });

    test('Deve salvar o cache', () async {
      final requestMock =
          Request(url: 'mock_url', query: const Query(document: 'query'));
      final snapshotMock = Snapshot(query: requestMock.query);
      final key = const Uuid().v5(
        CacheInterceptor.namespaceKey,
        '${requestMock.url}: ${requestMock.query}',
      );
      final cacheMock = {key: {'cache_mock_key': 'cache_mock_value'}};

      final responseMock = {'mock_key': 'mock_value'};

      when(() => storage.containsKey(any()))
          .thenAnswer((realInvocation) async => true);
      when(() => storage.get(any()))
          .thenAnswer((realInvocation) async => cacheMock);
      when(() => storage.put(any(), any())).thenAnswer(
        (realInvocation) async {
          final key = realInvocation.positionalArguments[0];
          final value = realInvocation.positionalArguments[1];
          cacheMock[key] =  value;
        },
      );

      await cacheInterceptor.onSubscription(requestMock, snapshotMock);
      snapshotMock
        ..listen((_) {})
        ..add(responseMock);

      await Future.delayed(const Duration(milliseconds: 500));

      expect(cacheMock[key], responseMock);
    });
  });
}
