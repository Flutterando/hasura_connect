import 'package:dartz/dartz.dart' hide Task;

import 'package:example/app/core/exceptions/failure.dart';
import 'package:example/app/modules/todo/domain/entities/task.dart';
import 'package:example/app/modules/todo/domain/params/i_params.dart';
import 'package:example/app/modules/todo/domain/repositories/i_task_repository.dart';
import 'package:example/app/modules/todo/domain/usecases/interfaces/i_create_task.dart';

class CreateTask implements ICreateTask {
  final ITaskRepository _repository;
  CreateTask(this._repository);

  @override
  Future<Either<Failure, Task>> call(IParams params) {
    //TODO: implement: verify params

    final result = _repository.create(params);
    return result;
  }
}
