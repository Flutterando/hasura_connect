import 'package:dartz/dartz.dart' hide Task;
import 'package:example/app/modules/todo/domain/entities/task.dart';

import '../../../../../core/exceptions/failure.dart';

abstract class IWatchTask {
  Future<Either<Failure, Stream<List<Task>>>> call();
}
