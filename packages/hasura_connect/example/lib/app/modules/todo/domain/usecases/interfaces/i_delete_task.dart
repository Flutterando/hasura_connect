import 'package:dartz/dartz.dart' hide Task;
import 'package:example/app/modules/todo/domain/entities/task.dart';
import 'package:example/app/modules/todo/domain/params/i_params.dart';

import '../../../../../core/exceptions/failure.dart';

abstract class IDeleteTask {
  Future<Either<Failure, Task>> call(IParams params);
}
