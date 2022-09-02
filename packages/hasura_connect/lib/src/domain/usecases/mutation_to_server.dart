import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/repositories/request_repository.dart';
import 'package:string_validator/string_validator.dart';

///The [MutationToServer] class is an abstract class acting as
///an interface.
abstract class MutationToServer {
  ///Method [call] signature

  Future<Either<HasuraError, Response>> call({required Request request});
}

///Class [MutationToServerImpl] implements the interface
///[MutationToServer]
//////implements the method [call]
class MutationToServerImpl implements MutationToServer {
  /// variable [repository] type [RequestRepository]
  final RequestRepository repository;

  /// [MutationToServerImpl] constructor
  MutationToServerImpl(this.repository);

  ///checks if the request query is valid, if
  ///invalid, returns a [InvalidRequestError]
  ///else if the request query document don't start with mutation, will return
  ///a [InvalidRequestError], else if
  ///the request query key is null or empty, returns a [InvalidRequestError], else
  ///if request type is different from mutation, returns a
  ///[InvalidRequestError], else, if the url is invalid returns a
  ///[InvalidRequestError]
  ///otherwise, will result of the [repository] send request method
  @override
  Future<Either<HasuraError, Response>> call({required Request request}) async {
    if (!request.query.isValid) {
      return Left(InvalidRequestError('Invalid Query document'));
    } else if (!request.query.document.startsWith('mutation')) {
      return Left(InvalidRequestError('Document is not a mutation'));
    } else if (request.query.key == null || request.query.key!.isEmpty) {
      return Left(InvalidRequestError('Invalid key'));
    } else if (request.type != RequestType.mutation) {
      return Left(
        InvalidRequestError('Request type is not RequestType.mutation'),
      );
    } else if (!isURL(request.url)) {
      return Left(InvalidRequestError('Invalid url'));
    }

    return repository.sendRequest(request: request);
  }
}
