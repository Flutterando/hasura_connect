import 'package:either_dart/either.dart';
import 'package:string_validator/string_validator.dart';
import '../repositories/request_repository.dart';
import '../errors/errors.dart';
import '../models/request.dart';
import '../entities/response.dart';

abstract class MutationToServer {
  Future<Either<HasuraError, Response>> call({required Request request});
}

class MutationToServerImpl implements MutationToServer {
  final RequestRepository repository;

  MutationToServerImpl(this.repository);

  @override
  Future<Either<HasuraError, Response>> call({required Request request}) async {
    if (!request.query.isValid) {
      return Left(InvalidRequestError('Invalid Query document'));
    } else if (!request.query.document.startsWith('mutation')) {
      return Left(InvalidRequestError('Document is not a mutation'));
    } else if (request.query.key == null || request.query.key!.isEmpty) {
      return Left(InvalidRequestError('Invalid key'));
    } else if (request.type != RequestType.mutation) {
      return Left(InvalidRequestError('Request type is not RequestType.mutation'));
    }

    return await repository.sendRequest(request: request);
  }
}
