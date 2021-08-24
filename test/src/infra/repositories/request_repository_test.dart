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

class ResponseMock extends Mock implements Response {}

void main() {
  late RequestDatasource datasource;
  late RequestRepository repository;
  late Response response;

  final tRequest = Request(url: '', query: Query(document: 'query', key: 'dadas'));

  registerFallbackValue<Request>(tRequest);

  setUpAll(() {
    response = ResponseMock();
    datasource = RequestDatasourceMock();
    repository = RequestRepositoryImpl(datasource: datasource);
  });

  test('should return Response', () async {
    when(() => datasource.post(request: any(named: 'request'))).thenAnswer((_) async => response);
    final result = await repository.sendRequest(request: tRequest);
    expect(result.right, equals(response));
  });

  test('should return DatasourceError when datasource failed', () async {
    when(() => datasource.post(request: any(named: 'request'))).thenThrow(Exception());
    final result = await repository.sendRequest(request: tRequest);
    expect(result.left, isA<DatasourceError>());
  });

  test('should return error from datasource', () async {
    when(() => datasource.post(request: any(named: 'request'))).thenThrow(InvalidRequestError('Error'));
    final result = await repository.sendRequest(request: tRequest);
    expect(result.left, isA<InvalidRequestError>());
  });
}
