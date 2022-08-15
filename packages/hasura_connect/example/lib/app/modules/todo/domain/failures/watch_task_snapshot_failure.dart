import 'package:example/app/core/exceptions/failure.dart';

class WatchTaskSnapshotFailure extends Failure {
  WatchTaskSnapshotFailure({
    required super.message,
    super.error,
    super.stackTrace,
  });
}
