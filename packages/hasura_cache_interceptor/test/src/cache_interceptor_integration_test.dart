// ignore_for_file: void_checks

import 'dart:convert';

import 'package:hasura_cache_interceptor/hasura_cache_interceptor.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockStorageService extends Mock implements IStorageService {}

class MockHttpClient extends Mock implements http.Client {}

void main() {
  final storage = MockStorageService();
  final httpClient = MockHttpClient();
  final cacheInterceptor = CacheInterceptor(storage);
  late HasuraConnect service;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    when(httpClient.close).thenReturn(() {});
    service = HasuraConnect(
      'https://www.youtube.com/c/flutterando',
      httpClientFactory: () => httpClient,
      interceptors: [cacheInterceptor],
    );
  });

  tearDown(() async {
    //await cacheInterceptor.clearAllCache();
  });

  group('no connection and', () {
    test(' no cache, throws exception', () async {
      final mockResponse = http.Response('', 404);
      when(
        () => httpClient.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((realInvocation) async => mockResponse);
      when(() => storage.containsKey(any())).thenAnswer(
        (realInvocation) async => false,
      );
      expect(service.query('query'), throwsException);
    });

    test(' have cache, return cache', () async {
      final cache = {'cache_mock_key': 'cache_mock_value'};
      final mockResponse = http.Response('', 404);
      when(
        () => httpClient.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((realInvocation) async => mockResponse);
      when(() => storage.containsKey(any())).thenAnswer(
        (realInvocation) async => true,
      );
      when(() => storage.get(any())).thenAnswer(
        (realInvocation) async => cache,
      );
      expect(await service.query('query'), cache);
    });
  });

  group('have connection and', () {
    test('no cache, return real response', () async {
      final realResponse = {'mock_key': 'mock_value'};

      when(
        () => httpClient.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (realInvocation) async => http.Response(jsonEncode(realResponse), 200),
      );
      when(() => storage.containsKey(any())).thenAnswer(
        (realInvocation) async => false,
      );
      when(() => storage.put(any(), any()))
          .thenAnswer((realInvocation) async {});
      expect(await service.query('query'), realResponse);
    });

    test('have cache, return real response', () async {
      final realResponse = {'mock_key': 'mock_value'};
      final cache = {'cache_mock_key': 'cache_mock_value'};
      //final mockResponse = http.Response("", 200);

      when(
        () => httpClient.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (realInvocation) async => http.Response(jsonEncode(realResponse), 200),
      );
      when(() => storage.containsKey(any())).thenAnswer(
        (realInvocation) async => true,
      );
      when(() => storage.get(any())).thenAnswer(
        (realInvocation) async => cache,
      );
      when(() => storage.put(any(), any()))
          .thenAnswer((realInvocation) async {});
      expect(await service.query('query'), realResponse);
    });
  });
}
