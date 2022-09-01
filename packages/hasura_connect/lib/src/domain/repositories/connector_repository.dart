import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';

///The [ConnectorRepository] class is an abstract class acting as
///the interface.
abstract class ConnectorRepository {
  ///Method [getConnector] signature

  Future<Either<HasuraError, Connector>> getConnector(String url);
}
