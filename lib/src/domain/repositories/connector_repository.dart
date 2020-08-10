import 'package:dartz/dartz.dart';
import '../errors/errors.dart';
import '../entities/connector.dart';

abstract class ConnectorRepository {
  Future<Either<HasuraError, Connector>> getConnector(String url);
}
