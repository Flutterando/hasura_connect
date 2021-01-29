import 'package:either_dart/either.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/repositories/request_repository.dart';
import 'package:hasura_connect/src/domain/usecases/mutation_to_server.dart';

class RequestRepositoryMock extends Mock implements RequestRepository {}

class ResponseMock extends Mock implements Response {}

void main() {
  late MutationToServer usecase;
  late RequestRepository repository;
  late Response response;
  final url = 'https://hasura-fake.com';
  setUpAll(() {
    repository = RequestRepositoryMock();
    usecase = MutationToServerImpl(repository);
    response = ResponseMock();
    when(repository).calls(#sendRequest).thenAnswer((_) async => Right<HasuraError, Response>(response));
  });

  test('should return Response', () async {
    final result = await usecase(request: Request(type: RequestType.mutation, url: url, query: Query(document: 'mutation', key: 'dfsfsd')));
    expect(result.right, equals(response));
  });
  test('should throw InvalidRequestError if Query.document is invalid', () async {
    final result = await usecase(request: Request(type: RequestType.mutation, url: url, query: Query(document: '', key: 'dfsfsd')));
    expect(result.left, isA<InvalidRequestError>());
  });
  test('should throw InvalidRequestError if Document is not a mutation', () async {
    final result = await usecase(request: Request(type: RequestType.mutation, url: url, query: Query(document: 'query', key: 'dsadsad')));
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should throw InvalidRequestError if invalid key', () async {
    final result = await usecase(request: Request(type: RequestType.mutation, url: url, query: Query(document: 'mutation', key: '')));
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should throw InvalidRequestError if type request is not mutation', () async {
    final result = await usecase(request: Request(url: url, type: RequestType.query, query: Query(document: 'mutation', key: 'dadas')));
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should throw InvalidRequestError if Url is invalid', () async {
    final result = await usecase(request: Request(url: '', type: RequestType.mutation, query: Query(document: 'mutation', key: 'fdsfsffs')));
    expect(result.left, isA<InvalidRequestError>());
  });
}
