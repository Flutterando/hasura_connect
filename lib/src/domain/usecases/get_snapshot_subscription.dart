import 'package:either_dart/either.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:string_validator/string_validator.dart';
import '../entities/snapshot.dart';
import '../errors/errors.dart';

abstract class GetSnapshotSubscription {
  Either<HasuraError, Snapshot> call({
    required Request request,
    void Function(Snapshot)? closeConnection,
    void Function(Snapshot)? changeVariables,
  });
}

class GetSnapshotSubscriptionImpl implements GetSnapshotSubscription {
  @override
  Either<HasuraError, Snapshot> call({required Request request, void Function(Snapshot)? closeConnection, void Function(Snapshot)? changeVariables}) {
    if (!request.query.isValid) {
      return Left(InvalidRequestError('Invalid Query document'));
    } else if (!request.query.document.startsWith('subscription')) {
      return Left(InvalidRequestError('Document is not a subscription'));
    } else if (request.query.key == null || request.query.key!.isEmpty) {
      return Left(InvalidRequestError('Invalid key'));
    } else if (request.type != RequestType.subscription) {
      return Left(InvalidRequestError('Request type is not RequestType.subscription'));
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
