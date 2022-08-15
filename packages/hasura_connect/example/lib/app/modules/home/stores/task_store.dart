import 'package:example/app/core/exceptions/failure.dart';
import 'package:example/app/modules/home/states/task_state.dart';
import 'package:example/app/modules/todo/domain/params/create_task_params.dart';
import 'package:example/app/modules/todo/domain/usecases/interfaces/i_create_task.dart';
import 'package:flutter_triple/flutter_triple.dart';

import '../../todo/domain/usecases/interfaces/i_watch_task.dart';

class TaskStore extends StreamStore<Failure, TaskState> {
  final IWatchTask _watchTask;
  final ICreateTask _createTask;
  TaskStore(this._watchTask, this._createTask) : super(TaskState());

  Future<void> watchTasks() async {
    setLoading(true);
    final result = await _watchTask();
    result.fold(
      (failure) {
        setError(failure);
      },
      (stream) {
        stream.listen(
          (listTasks) {
            update(
              state.copyWith(
                tasks: listTasks,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> createTask(String description) async {
    final params = CreateTaskParams(description: description);
    _createTask(params);
  }
}
