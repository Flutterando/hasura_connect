import 'package:example/app/modules/todo/domain/entities/task.dart';

abstract class TaskMapper {
  static List<Task> fromJson(List<dynamic> tasks) {
    return tasks.map((e) => _make(e)).toList();
  }

  static Task _make(Map<String, dynamic> task) {
    return Task(
      id: task['id'],
      //description: task['description'],
      title: task['todo'],
      //idStatus: task['id_status'],
      // createdAt: DateTime.tryParse(task['created_at']),
    );
  }
}
