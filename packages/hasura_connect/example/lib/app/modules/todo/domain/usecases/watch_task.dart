import 'package:example/app/modules/todo/domain/entities/task.dart';
import 'package:example/app/core/exceptions/failure.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:example/app/modules/todo/domain/usecases/interfaces/i_watch_task.dart';

import '../repositories/i_task_repository.dart';

class WatchTask implements IWatchTask {
  final ITaskRepository repository;
  WatchTask(this.repository);

  @override
  Future<Either<Failure, Stream<List<Task>>>> call() async {
    final result = await repository.watch();
    return result;
  }
}
