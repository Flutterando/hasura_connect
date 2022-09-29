import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/repositories/request_repository.dart';
import 'package:hasura_connect/src/infra/datasources/request_datasource.dart';

///Class [RequestRepositoryImpl] implements the interface
///[RequestRepository]
///implements the method [sendRequest]
class RequestRepositoryImpl implements RequestRepository {
  ///variable [datasource] type [RequestDatasource]

  final RequestDatasource datasource;

  ///[RequestRepositoryImpl] constructor
  RequestRepositoryImpl({required this.datasource});

  ///Receives the result of [datasource], and return a [Right]
  ///with the result, if an [HasuraError] occurs, returns [Left] with the error
  ///if other error occurs, returns a Left [DatasourceError] with the error and
  ///[Request]
  @override
  Future<Either<HasuraError, Response>> sendRequest({
    required Request request,
  }) async {
    try {
      final result = await datasource.post(request: request);
      return Right(result);
    } on HasuraError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        DatasourceError(
          'DatasourceError: ${e.toString()}',
          request: request,
        ),
      );
    }
  }
}
