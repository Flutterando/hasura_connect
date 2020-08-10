import 'package:dartz/dartz.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/repositories/request_repository.dart';
import 'package:hasura_connect/src/domain/usecases/mutation_to_server.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class RequestRepositoryMock extends Mock implements RequestRepository {}

void main() {
  MutationToServer usecase;
  RequestRepository repository;
  final url = 'https://hasura-fake.com';
  setUpAll(() {
    repository = RequestRepositoryMock();
    usecase = MutationToServerImpl(repository);
    when(repository.sendRequest(request: anyNamed('request')))
        .thenAnswer((_) async => Right(const Response()));
  });

  test('should return Response', () async {
    final result = await usecase(
        request: Request(
            type: RequestType.mutation,
            url: url,
            query: Query(document: 'mutation', key: 'dfsfsd')));
    expect(result | null, equals(const Response()));
  });
  test('should throw InvalidRequestError if Query.document is invalid',
      () async {
    final result = await usecase(
        request: Request(
            type: RequestType.mutation,
            url: url,
            query: Query(document: '', key: 'dfsfsd')));
    expect(result.fold(id, id),
        equals(const InvalidRequestError('Invalid Query document')));
  });
  test('should throw InvalidRequestError if Document is not a mutation',
      () async {
    final result = await usecase(
        request: Request(
            type: RequestType.mutation,
            url: url,
            query: Query(document: 'query', key: 'dsadsad')));
    expect(result.fold(id, id),
        equals(const InvalidRequestError('Document is not a mutation')));
  });

  test('should throw InvalidRequestError if invalid key', () async {
    final result = await usecase(
        request: Request(
            type: RequestType.mutation,
            url: url,
            query: Query(document: 'mutation', key: '')));
    expect(
        result.fold(id, id), equals(const InvalidRequestError('Invalid key')));
  });

  test('should throw InvalidRequestError if type request is not mutation',
      () async {
    final result = await usecase(
        request: Request(
            url: url,
            type: RequestType.query,
            query: Query(document: 'mutation', key: 'dadas')));
    expect(
        result.fold(id, id),
        equals(const InvalidRequestError(
            'Request type is not RequestType.mutation')));
  });

  test('should throw InvalidRequestError if Url is invalid', () async {
    final result = await usecase(
        request: Request(
            url: '',
            type: RequestType.mutation,
            query: Query(document: 'mutation', key: 'fdsfsffs')));
    expect(
      result.fold(id, id),
      equals(const InvalidRequestError('Invalid url')),
    );
  });
}
