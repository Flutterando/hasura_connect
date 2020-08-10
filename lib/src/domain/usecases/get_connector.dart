import 'package:dartz/dartz.dart';
import '../repositories/connector_repository.dart';
import '../errors/errors.dart';
import '../entities/connector.dart';
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
      return left(const InvalidRequestError('Invalid URL'));
    }

    return await repository.getConnector(url);
  }
}
