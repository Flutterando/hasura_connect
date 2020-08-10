import 'package:dartz/dartz.dart';
import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/repositories/connector_repository.dart';
import 'package:hasura_connect/src/infra/datasources/connector_datasource.dart';
import 'package:hasura_connect/src/infra/repositories/connector_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class ConnectorDataourceMock extends Mock implements ConnectorDatasource {}

void main() {
  ConnectorDatasource datasource;
  ConnectorRepository repository;
  setUpAll(() {
    datasource = ConnectorDataourceMock();
    repository = ConnectorRepositoryImpl(datasource: datasource);
  });

  test('should return Response', () async {
    when(datasource.websocketConnector(''))
        .thenAnswer((_) async => Connector(null));
    final result = await repository.getConnector('');
    expect(result | null, isA<Connector>());
  });

  test('should return DatasourceError when datasource failed', () async {
    when(datasource.websocketConnector('')).thenThrow(Exception());
    final result = await repository.getConnector('');
    expect(
        result.fold(id, id), equals(const DatasourceError('Datasource Error')));
  });
}
