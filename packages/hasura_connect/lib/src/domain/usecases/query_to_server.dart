import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/repositories/request_repository.dart';

///The [QueryToServer] class is an abstract class acting as
///an interface.
abstract class QueryToServer {
  ///Method [call] signature
  Future<Either<HasuraError, Response>> call({required Request request});
}

///Class [QueryToServerImpl] implements the interface
///[QueryToServer]
//////implements the method [call]
class QueryToServerImpl implements QueryToServer {
  ///Variable [repository] type [RequestRepository]
  final RequestRepository repository;

  /// [QueryToServerImpl] constructor
  QueryToServerImpl(this.repository);

  ///checks if the request query is valid, if
  ///invalid, returns a [InvalidRequestError]
  ///else if the request query document don't start with query, will return
  ///an [InvalidRequestError], else if
  ///request type is different from query, returns an
  ///[InvalidRequestError], otherwise, will return the [repository]
  ///send request method
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
