import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/repositories/connector_repository.dart';
import 'package:hasura_connect/src/infra/datasources/connector_datasource.dart';

///Class [ConnectorRepositoryImpl] implements the interface
///[ConnectorRepository]
///implements the method [getConnector]
class ConnectorRepositoryImpl implements ConnectorRepository {
  ///variable [datasource] type [ConnectorDatasource]
  final ConnectorDatasource datasource;

  ///[ConnectorRepositoryImpl] constructor
  ConnectorRepositoryImpl({required this.datasource});

  ///Receives the result of [datasource], and return a [Right]
  ///with the result, if an [HasuraError] occurs, returns [Left] with the error
  ///if other error occurs, returns a Left [DatasourceError] with the error
  ///and [Request]
  @override
  Future<Either<HasuraError, Connector>> getConnector(String url) async {
    try {
      final result = await datasource.websocketConnector(url);
      return Right(result);
    } on HasuraError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        DatasourceError(
          'Datasource Error',
          request: Request(
            url: url,
            query: const Query(document: ''),
          ),
        ),
      );
    }
  }
}
