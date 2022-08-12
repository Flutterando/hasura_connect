import 'package:dartz/dartz.dart';
import 'package:example/app/core/exceptions/failure.dart';

abstract class ITaskRepository {
  Stream<Either<List<Task>, Failure>> watch();
}
