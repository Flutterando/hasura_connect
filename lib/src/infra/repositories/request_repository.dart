import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:dartz/dartz.dart';
import 'package:hasura_connect/src/domain/repositories/request_repository.dart';
import 'package:hasura_connect/src/infra/datasources/request_datasource.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestDatasource datasource;

  RequestRepositoryImpl({this.datasource});

  @override
  Future<Either<HasuraError, Response>> sendRequest({Request request}) async {
    try {
      final result = await datasource.post(request: request);
      return Right(result);
    } on HasuraError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DatasourceError('DatasourceError: ${e.toString()}'));
    }
  }
}
