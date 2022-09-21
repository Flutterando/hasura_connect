import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/request.dart';

///The [RequestRepository] class is an abstract class acting as
///an interface.
abstract class RequestRepository {
  ///Method [sendRequest] signature

  Future<Either<HasuraError, Response>> sendRequest({required Request request});
}
