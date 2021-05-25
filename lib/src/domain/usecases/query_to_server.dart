import 'package:either_dart/either.dart';
import 'package:string_validator/string_validator.dart';
import '../repositories/request_repository.dart';
import '../errors/errors.dart';
import '../models/request.dart';
import '../entities/response.dart';

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
    return await repository.sendRequest(request: request);
  }
}
