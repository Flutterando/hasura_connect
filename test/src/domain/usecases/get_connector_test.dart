import 'package:dartz/dartz.dart';
import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/repositories/connector_repository.dart';
import 'package:hasura_connect/src/domain/usecases/get_connector.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class ConnectorRepositoryMock extends Mock implements ConnectorRepository {}

void main() {
  GetConnector usecase;
  ConnectorRepositoryMock repository;
  setUpAll(() {
    repository = ConnectorRepositoryMock();
    usecase = GetConnectorImpl(repository);
    when(repository.getConnector(any))
        .thenAnswer((_) async => Right(Connector(null)));
  });

  test('should return Connector', () async {
    final result = await usecase('https://flutterando.com.br');
    expect(result | null, isA<Connector>());
  });
  test('should throw InvalidRequestError if Url is invalid', () async {
    final result = await usecase('');
    expect(
        result.fold(id, id), equals(const InvalidRequestError('Invalid URL')));
  });
}
