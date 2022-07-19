import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/repositories/connector_repository.dart';
import 'package:hasura_connect/src/infra/datasources/connector_datasource.dart';
import 'package:hasura_connect/src/infra/repositories/connector_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class ConnectorDataourceMock extends Mock implements ConnectorDatasource {}

void main() {
  late ConnectorDatasource datasource;
  late ConnectorRepository repository;
  setUpAll(() {
    datasource = ConnectorDataourceMock();
    repository = ConnectorRepositoryImpl(datasource: datasource);
  });

  test('should return Response', () async {
    when(() => datasource.websocketConnector('')).thenAnswer((_) async => Connector(const Stream.empty()));
    final result = await repository.getConnector('');
    expect(result.right, isA<Connector>());
  });

  test('should return DatasourceError when datasource failed', () async {
    when(() => datasource.websocketConnector('')).thenThrow(Exception());
    final result = await repository.getConnector('');
    expect(result.left, isA<DatasourceError>());
  });

  test('should return error from datasource', () async {
    when(() => datasource.websocketConnector('')).thenThrow(InvalidRequestError('error'));
    final result = await repository.getConnector('');
    expect(result.left, isA<InvalidRequestError>());
  });
}
