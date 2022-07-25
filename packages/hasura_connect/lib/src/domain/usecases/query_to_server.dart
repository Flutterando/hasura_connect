import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/repositories/request_repository.dart';

abstract class QueryToServer {
  Future<Either<HasuraError, Response>> call({required Request request});
}

class QueryToServerImpl implements QueryToServer {
  final RequestRepository repository;

  QueryToServerImpl(this.repository);

  @override
  Future<Either<HasuraError, Response>> call({required Request request}) async {
    if (!request.query.isValid) {
      return Left(InvalidRequestError('Invalid document'));
    } else if (!request.query.document.startsWith('query')) {
      return Left(InvalidRequestError('Document is not a query'));
    } else if (request.type != RequestType.query) {
      return Left(InvalidRequestError('Request type is not RequestType.query'));
    }
    return repository.sendRequest(request: request);
  }
}
