import 'package:example/app/modules/todo/domain/entities/task.dart';
import 'package:example/app/modules/todo/domain/params/i_params.dart';

abstract class ITaskDatasource {
  Future<Stream<List<Task>>> watch();
  Future<Task> create(IParams params);
  Future<Task> delete(IParams params);
}
