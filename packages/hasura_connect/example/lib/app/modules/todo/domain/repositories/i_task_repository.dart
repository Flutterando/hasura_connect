import 'package:dartz/dartz.dart' hide Task;
import 'package:example/app/core/exceptions/failure.dart';
import 'package:example/app/modules/todo/domain/params/i_params.dart';

import '../entities/task.dart';

abstract class ITaskRepository {
  Future<Either<Failure, Stream<List<Task>>>> watch();
  Future<Either<Failure, Task>> create(IParams params);
  Future<Either<Failure, Task>> delete(IParams params);
}
