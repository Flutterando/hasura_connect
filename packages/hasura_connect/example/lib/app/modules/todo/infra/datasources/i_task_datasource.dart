import 'package:example/app/modules/todo/domain/entities/task.dart';

abstract class ITaskDatasource {
  Stream<List<Task>> watch();
}
