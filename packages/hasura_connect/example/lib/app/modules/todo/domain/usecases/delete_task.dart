import 'package:dartz/dartz.dart' hide Task;

import 'package:example/app/core/exceptions/failure.dart';
import 'package:example/app/modules/todo/domain/entities/task.dart';
import 'package:example/app/modules/todo/domain/params/i_params.dart';
import 'package:example/app/modules/todo/domain/repositories/i_task_repository.dart';

import 'interfaces/i_delete_task.dart';

class DeleteTask implements IDeleteTask {
  final ITaskRepository _repository;
  DeleteTask(this._repository);

  @override
  Future<Either<Failure, Task>> call(IParams params) {
    //TODO: implement: verify params

    final result = _repository.delete(params);
    return result;
  }
}
