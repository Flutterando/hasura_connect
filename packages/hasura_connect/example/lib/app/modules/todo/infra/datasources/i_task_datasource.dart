import 'package:example/app/modules/todo/domain/entities/task.dart';

abstract class ITaskDatasource {
  Future<Stream<List<Task>>> watch();
}
