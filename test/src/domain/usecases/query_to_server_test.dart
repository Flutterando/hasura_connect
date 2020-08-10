import 'package:dartz/dartz.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/repositories/request_repository.dart';
import 'package:hasura_connect/src/domain/usecases/query_to_server.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class RequestRepositoryMock extends Mock implements RequestRepository {}

void main() {
  QueryToServer usecase;
  RequestRepository repository;
  final url = 'https://hasura-fake.com';

  setUpAll(() {
    repository = RequestRepositoryMock();
    usecase = QueryToServerImpl(repository);
    when(repository.sendRequest(request: anyNamed('request')))
        .thenAnswer((_) async => Right(const Response()));
  });

  test('should return Response', () async {
    final result = await usecase(
        request: Request(
            url: url,
            type: RequestType.query,
            query: Query(document: 'query', key: 'dadas')));
    expect(result | null, equals(const Response()));
  });
  test('should throw InvalidRequestError if Query.document is invalid',
      () async {
    final result = await usecase(
        request: Request(
            url: url,
            type: RequestType.query,
            query: Query(document: '', key: 'dadas')));
    expect(result.fold(id, id),
        equals(const InvalidRequestError('Invalid document')));
  });

  test('should throw InvalidRequestError if Document is not a query', () async {
    final result = await usecase(
        request: Request(
            url: url,
            type: RequestType.query,
            query: Query(document: 'mutation', key: 'dadas')));
    expect(result.fold(id, id),
        equals(const InvalidRequestError('Document is not a query')));
  });

  test('should throw InvalidRequestError if type request is not query',
      () async {
    final result = await usecase(
        request: Request(
            url: url,
            type: RequestType.mutation,
            query: Query(document: 'query', key: 'dadas')));
    expect(
        result.fold(id, id),
        equals(const InvalidRequestError(
            'Request type is not RequestType.query')));
  });
  test('should throw InvalidRequestError if Url is invalid', () async {
    final result = await usecase(
        request: Request(
            url: '',
            type: RequestType.query,
            query: Query(document: 'query', key: 'fdsfsffs')));
    expect(
      result.fold(id, id),
      equals(const InvalidRequestError('Invalid url')),
    );
  });
}
