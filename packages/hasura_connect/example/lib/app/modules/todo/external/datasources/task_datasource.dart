import 'package:example/app/modules/todo/domain/entities/task.dart';
import 'package:example/app/modules/todo/external/mapper/task_mapper.dart';
import 'package:example/app/modules/todo/infra/datasources/i_task_datasource.dart';
import 'package:hasura_connect/hasura_connect.dart';

class TaskDatasource implements ITaskDatasource {
  final HasuraConnect connect;

  TaskDatasource(this.connect);

  @override
  Stream<List<Task>> watch() async* {}
}
