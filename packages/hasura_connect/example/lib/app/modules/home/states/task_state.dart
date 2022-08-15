import 'package:example/app/core/exceptions/failure.dart';
import 'package:example/app/modules/todo/domain/entities/task.dart';

class TaskState {
  List<Task> tasks;
  Failure? error;
  TaskState({
    this.tasks = const <Task>[],
    this.error,
  });

  TaskState copyWith({
    List<Task>? tasks,
    Failure? error,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      error: error ?? this.error,
    );
  }
}
