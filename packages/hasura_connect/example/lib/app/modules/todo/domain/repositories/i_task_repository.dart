import 'package:dartz/dartz.dart' hide Task;
import 'package:example/app/core/exceptions/failure.dart';

import '../entities/task.dart';

abstract class ITaskRepository {
  Future<Either<Failure, Stream<List<Task>>>> watch();
}
