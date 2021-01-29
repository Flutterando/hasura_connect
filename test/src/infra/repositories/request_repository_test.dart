import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/repositories/request_repository.dart';
import 'package:hasura_connect/src/infra/datasources/request_datasource.dart';
import 'package:hasura_connect/src/infra/repositories/request_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class RequestDatasourceMock extends Mock implements RequestDatasource {}

void main() {
  RequestDatasource datasource;
  RequestRepository repository;
  final tRequest = Request(url: '', query: Query(document: 'query', key: 'dadas'));
  setUpAll(() {
    datasource = RequestDatasourceMock();
    repository = RequestRepositoryImpl(datasource: datasource);
  });

  test('should return Response', () async {
    when(datasource.post(request: anyNamed('request'))).thenAnswer((_) async => const Response());
    final result = await repository.sendRequest(request: tRequest);
    expect(result | null, equals(const Response()));
  });

  test('should return DatasourceError when datasource failed', () async {
    when(datasource.post(request: anyNamed('request'))).thenThrow(Exception());
    final result = await repository.sendRequest(request: tRequest);
    expect(result.fold(id, id), isA<DatasourceError>());
  });

  test('should return error from datasource', () async {
    when(datasource.post(request: anyNamed('request'))).thenThrow(InvalidRequestError('Error'));
    final result = await repository.sendRequest(request: tRequest);
    expect(result.fold(id, id), isA<InvalidRequestError>());
  });
}
