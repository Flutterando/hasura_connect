import 'package:example/app/modules/todo/domain/entities/task.dart';
import 'package:example/app/modules/todo/domain/params/i_params.dart';
import 'package:example/app/modules/todo/external/graphql/task_docs.dart';
import 'package:example/app/modules/todo/external/mapper/task_mapper.dart';
import 'package:example/app/modules/todo/infra/datasources/i_task_datasource.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'dart:async';

import '../../domain/failures/watch_task_snapshot_failure.dart';

class TaskDatasource implements ITaskDatasource {
  final HasuraConnect connect;

  TaskDatasource(this.connect);

  @override
  Future<Stream<List<Task>>> watch() async {
    final tasksSnapshot = await connect.subscription(TaskDocs.watch()).onError(
      (error, stackTrace) {
        throw WatchTaskSnapshotFailure(
          message: error.toString(),
          stackTrace: stackTrace,
          error: error,
        );
      },
    );

    return tasksSnapshot.map<List<Task>>(
      (event) {
        final data = event['data']['todo'] as List;
        final taskList = TaskMapper.fromJson(data);
        return taskList;
      },
    );
  }

  @override
  Future<Task> create(IParams params) async {
    final createResult = await connect.mutation(
      TaskDocs.create(),
      variables: params.toMap(),
    );
    final data = createResult["data"]["insert_todo"]["returning"];
    final task = TaskMapper.fromJson(data).first;
    return task;
  }
}
