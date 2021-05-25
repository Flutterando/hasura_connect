import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/repositories/request_repository.dart';
import 'package:hasura_connect/src/domain/usecases/query_to_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class RequestRepositoryMock extends Mock implements RequestRepository {}

class ResponseMock extends Mock implements Response {}

void main() {
  late QueryToServer usecase;
  late RequestRepository repository;
  late Response response;

  final url = 'https://hasura-fake.com';

  setUpAll(() {
    repository = RequestRepositoryMock();
    usecase = QueryToServerImpl(repository);
    response = ResponseMock();

    when(repository).calls(#sendRequest).thenAnswer((_) async => Right<HasuraError, Response>(response));
  });

  test('should return Response', () async {
    final result = await usecase(request: Request(url: url, type: RequestType.query, query: Query(document: 'query', key: 'dadas')));
    expect(result.right, equals(response));
  });
  test('should throw InvalidRequestError if Query.document is invalid', () async {
    final result = await usecase(request: Request(url: url, type: RequestType.query, query: Query(document: '', key: 'dadas')));
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should throw InvalidRequestError if Document is not a query', () async {
    final result = await usecase(request: Request(url: url, type: RequestType.query, query: Query(document: 'mutation', key: 'dadas')));
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should throw InvalidRequestError if type request is not query', () async {
    final result = await usecase(request: Request(url: url, type: RequestType.mutation, query: Query(document: 'query', key: 'dadas')));
    expect(result.left, isA<InvalidRequestError>());
  });
}
