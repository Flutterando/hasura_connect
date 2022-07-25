// ignore_for_file: avoid_implementing_value_types

import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/repositories/request_repository.dart';
import 'package:hasura_connect/src/domain/usecases/mutation_to_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class RequestRepositoryMock extends Mock implements RequestRepository {}

class ResponseMock extends Mock implements Response {}

void main() {
  late MutationToServer usecase;
  late RequestRepository repository;
  late Response response;
  const url = 'https://hasura-fake.com';
  setUpAll(() {
    registerFallbackValue(
      Request(url: '', query: const Query(document: 'query', key: 'dadas')),
    );

    repository = RequestRepositoryMock();
    usecase = MutationToServerImpl(repository);
    response = ResponseMock();
    when(() => repository.sendRequest(request: any(named: 'request')))
        .thenAnswer((_) async => Right<HasuraError, Response>(response));
  });

  test('should return Response', () async {
    final result = await usecase(
      request: Request(
        type: RequestType.mutation,
        url: url,
        query: const Query(document: 'mutation', key: 'dfsfsd'),
      ),
    );
    expect(result.right, equals(response));
  });
  test('should throw InvalidRequestError if Query.document is invalid',
      () async {
    final result = await usecase(
      request: Request(
        type: RequestType.mutation,
        url: url,
        query: const Query(document: '', key: 'dfsfsd'),
      ),
    );
    expect(result.left, isA<InvalidRequestError>());
  });
  test('should throw InvalidRequestError if Document is not a mutation',
      () async {
    final result = await usecase(
      request: Request(
        type: RequestType.mutation,
        url: url,
        query: const Query(document: 'query', key: 'dsadsad'),
      ),
    );
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should throw InvalidRequestError if invalid key', () async {
    final result = await usecase(
      request: Request(
        type: RequestType.mutation,
        url: url,
        query: const Query(document: 'mutation', key: ''),
      ),
    );
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should throw InvalidRequestError if type request is not mutation',
      () async {
    final result = await usecase(
      request: Request(
        url: url,
        type: RequestType.query,
        query: const Query(document: 'mutation', key: 'dadas'),
      ),
    );
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should throw InvalidRequestError if Url is invalid', () async {
    final result = await usecase(
      request: Request(
        url: '',
        type: RequestType.mutation,
        query: const Query(document: 'mutation', key: 'fdsfsffs'),
      ),
    );
    expect(result.left, isA<InvalidRequestError>());
  });
}
