import 'package:example/app/core/exceptions/failure.dart';
import 'package:example/app/modules/home/states/task_state.dart';
import 'package:flutter_triple/flutter_triple.dart';

import '../../todo/domain/usecases/interfaces/i_watch_task.dart';

class TaskStore extends StreamStore<Failure, TaskState> {
  final IWatchTask _watchTask;
  TaskStore(this._watchTask) : super(TaskState());

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
}
