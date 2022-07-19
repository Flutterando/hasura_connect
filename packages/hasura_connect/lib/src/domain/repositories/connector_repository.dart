import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';

abstract class ConnectorRepository {
  Future<Either<HasuraError, Connector>> getConnector(String url);
}
