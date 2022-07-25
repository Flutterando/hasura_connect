import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/repositories/connector_repository.dart';
import 'package:hasura_connect/src/domain/usecases/get_connector.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class ConnectorRepositoryMock extends Mock implements ConnectorRepository {}

void main() {
  late GetConnector usecase;
  late ConnectorRepositoryMock repository;
  setUpAll(() {
    repository = ConnectorRepositoryMock();
    usecase = GetConnectorImpl(repository);
    when(() => repository.getConnector(any())).thenAnswer(
      (_) async =>
          Right<HasuraError, Connector>(Connector(const Stream.empty())),
    );
  });

  test('should return Connector', () async {
    final result = await usecase('https://flutterando.com.br');
    expect(result.right, isA<Connector>());
  });
  test('should throw InvalidRequestError if Url is invalid', () async {
    final result = await usecase('');
    expect(result.isLeft, true);
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should return Connector with -', () async {
    final result = await usecase('http://hasura-master.server:8080/v1/graphql');
    expect(result.right, isA<Connector>());
  });
}
