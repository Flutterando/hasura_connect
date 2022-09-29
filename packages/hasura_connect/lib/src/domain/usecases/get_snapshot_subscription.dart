import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/entities/snapshot.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:string_validator/string_validator.dart';

///The [GetSnapshotSubscription] class is an abstract class acting as
///an interface.
abstract class GetSnapshotSubscription {
  ///Method [call] signature
  Either<HasuraError, Snapshot> call({
    required Request request,
    void Function(Snapshot)? closeConnection,
    void Function(Snapshot)? changeVariables,
  });
}

///Class [GetSnapshotSubscriptionImpl] implements the interface
///[GetSnapshotSubscription]
///implements the method [call]
class GetSnapshotSubscriptionImpl implements GetSnapshotSubscription {
  ///checks if the request query is valid, if
  ///invalid, returns a [InvalidRequestError]
  ///else if the request query document don't start with subscription, will return
  ///a [InvalidRequestError], else if
  ///the request query key is null or empty, returns a [InvalidRequestError], else
  ///if request type is different from subscription, returns a
  ///[InvalidRequestError], else, if the url is invalid returns a
  ///[InvalidRequestError]
  ///otherwise, will return a Right [Snapshot]
  @override
  Either<HasuraError, Snapshot> call({
    required Request request,
    void Function(Snapshot)? closeConnection,
    void Function(Snapshot)? changeVariables,
  }) {
    if (!request.query.isValid) {
      return Left(InvalidRequestError('Invalid Query document'));
    } else if (!request.query.document.startsWith('subscription')) {
      return Left(InvalidRequestError('Document is not a subscription'));
    } else if (request.query.key == null || request.query.key!.isEmpty) {
      return Left(InvalidRequestError('Invalid key'));
    } else if (request.type != RequestType.subscription) {
      return Left(
        InvalidRequestError('Request type is not RequestType.subscription'),
      );
    } else if (!isURL(request.url)) {
      return Left(InvalidRequestError('Invalid url'));
    }
    return Right(
      Snapshot(
        query: request.query,
        closeConnection: closeConnection,
        changeVariablesF: changeVariables,
      ),
    );
  }
}
