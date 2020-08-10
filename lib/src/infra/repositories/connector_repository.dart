import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:dartz/dartz.dart';
import 'package:hasura_connect/src/domain/repositories/connector_repository.dart';
import 'package:hasura_connect/src/infra/datasources/connector_datasource.dart';

class ConnectorRepositoryImpl implements ConnectorRepository {
  final ConnectorDatasource datasource;

  ConnectorRepositoryImpl({this.datasource});

  @override
  Future<Either<HasuraError, Connector>> getConnector(String url) async {
    try {
      final result = await datasource.websocketConnector(url);
      return Right(result);
    } on HasuraError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(const DatasourceError('Datasource Error'));
    }
  }
}
