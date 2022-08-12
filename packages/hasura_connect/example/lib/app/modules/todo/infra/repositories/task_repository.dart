import 'package:example/app/core/exceptions/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:example/app/modules/todo/domain/repositories/i_task_repository.dart';

class TaskRepository implements ITaskRepository {
  @override
  Stream<Either<List<Task>, Failure>> watch() {
    // TODO: implement watch
    throw UnimplementedError();
  }
}
