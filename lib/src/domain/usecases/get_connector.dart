import 'package:either_dart/either.dart';
import '../repositories/connector_repository.dart';
import '../errors/errors.dart';
import '../entities/connector.dart';

abstract class GetConnector {
  Future<Either<HasuraError, Connector>> call(String url);
}

class GetConnectorImpl implements GetConnector {
  final ConnectorRepository repository;

  GetConnectorImpl(this.repository);

  @override
  Future<Either<HasuraError, Connector>> call(String url) async {
    return await repository.getConnector(url);
  }
}
