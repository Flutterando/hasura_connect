import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/repositories/connector_repository.dart';
import 'package:string_validator/string_validator.dart' as validator;

abstract class GetConnector {
  Future<Either<HasuraError, Connector>> call(String url);
}

class GetConnectorImpl implements GetConnector {
  final ConnectorRepository repository;

  GetConnectorImpl(this.repository);

  @override
  Future<Either<HasuraError, Connector>> call(String url) async {
    if (!validator.isURL(url)) {
      return Left(InvalidRequestError('Invalid URL'));
    }

    return repository.getConnector(url);
  }
}
