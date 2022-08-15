import 'package:example/app/modules/home/home_Page.dart';
import 'package:example/app/modules/home/home_store.dart';
import 'package:example/app/modules/home/stores/task_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../todo/domain/repositories/i_task_repository.dart';
import '../todo/domain/usecases/interfaces/i_watch_task.dart';
import '../todo/domain/usecases/watch_task.dart';
import '../todo/external/datasources/task_datasource.dart';
import '../todo/infra/datasources/i_task_datasource.dart';
import '../todo/infra/repositories/task_repository.dart';

class HomeModule extends Module {
  @override
  final List<Bind> binds = [
    //books binds
    Bind.lazySingleton((i) => HomeStore(i())),
    //task binds
    Bind<ITaskDatasource>((i) => TaskDatasource(i())),
    Bind<ITaskRepository>((i) => TaskRepository(i())),
    Bind<IWatchTask>((i) => (WatchTask(i()))),
    Bind((i) => TaskStore(i())),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, args) => HomePage()),
  ];
}
