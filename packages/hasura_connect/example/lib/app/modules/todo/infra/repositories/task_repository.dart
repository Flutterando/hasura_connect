import 'package:dartz/dartz.dart' hide Task;

import 'package:example/app/core/exceptions/failure.dart';
import 'package:example/app/modules/todo/domain/repositories/i_task_repository.dart';

import '../../domain/entities/task.dart';
import '../../domain/failures/watch_task_snapshot_failure.dart';
import '../datasources/i_task_datasource.dart';

class TaskRepository implements ITaskRepository {
  final ITaskDatasource datasource;
  TaskRepository(this.datasource);

  @override
  Future<Either<Failure, Stream<List<Task>>>> watch() async {
    try {
      final result = await datasource.watch();
      return Right(result);
    } on WatchTaskSnapshotFailure catch (failure) {
      return Left(failure);
    }
  }
}
