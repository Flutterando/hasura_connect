import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/repositories/connector_repository.dart';
import 'package:string_validator/string_validator.dart' as validator;

///The [GetConnector] class is an abstract class acting as
///an interface.
abstract class GetConnector {
  ///Method [call] signature

  Future<Either<HasuraError, Connector>> call(String url);
}

///Class [GetConnectorImpl] implements the [GetConnector] interface
///implements the method [call] which will check if the url received
///is valid, if it's valid, will return the repository.getConnector call
///otherwise, Will return a [Left] with a [InvalidRequestError] error.
class GetConnectorImpl implements GetConnector {
  ///Variable [repository] type [ConnectorRepository]
  final ConnectorRepository repository;

  ///[GetConnectorImpl] constructor
  GetConnectorImpl(this.repository);

  @override
  Future<Either<HasuraError, Connector>> call(String url) async {
    if (!validator.isURL(url)) {
      return Left(InvalidRequestError('Invalid URL'));
    }

    return repository.getConnector(url);
  }
}
