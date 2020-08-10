import 'dart:convert';
import 'dart:io';

import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/external/post_http_request.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import '../utils/client_response.dart';

class ClientMock extends Mock implements http.Client {}

void main() {
  final client = ClientMock();
  final datasource = PostHttpRequest(client);
  final tRequest =
      Request(url: '', query: Query(document: 'query', key: 'dadas'));

  test('should execute post request and return Response object', () async {
    when(client.post(
      any,
      body: anyNamed('body'),
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response(stringJsonReponse, 200));
    expect(datasource.post(request: tRequest), completes);
    final result = await datasource.post(request: tRequest);
    expect(result.statusCode, 200);
    expect(result.data.containsKey('data'), true);
  });

  group('Connection Errors | ', () {
    test('should ConnectionError if connection gonna be rejected', () async {
      when(client.post(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(stringJsonReponse, 401));
      expect(
        datasource.post(request: tRequest),
        throwsA(
          const ConnectionError('Connection Rejected'),
        ),
      );
    });

    test('should throw ConnectionError when socket fail connection', () async {
      when(client.post(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenThrow(SocketException('error'));
      expect(datasource.post(request: tRequest),
          throwsA(const ConnectionError('Verify your internet connection')));
    });

    test('should throw HasuraRequestError when server reject connection',
        () async {
      when(client.post(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
          jsonEncode({
            'errors': [
              {
                'message': 'error',
                'extensions': {'path': 'nao sei', 'code': 'tb nao sei'}
              }
            ]
          }),
          200));
      expect(
        datasource.post(request: tRequest),
        throwsA(
          isA<HasuraRequestError>(),
        ),
      );
    });
  });
}
