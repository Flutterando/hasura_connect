import 'package:example/app/core/exceptions/failure.dart';
import 'package:example/app/modules/home/states/task_state.dart';
import 'package:example/app/modules/home/stores/task_store.dart';
import 'package:example/app/modules/todo/domain/entities/task.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/material.dart';
import 'package:flutter_triple/flutter_triple.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({Key? key, this.title = 'Home Page'}) : super(key: key);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TaskStore store = Modular.get();

  @override
  void initState() {
    super.initState();
    store.watchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ScopedBuilder<TaskStore, Failure, TaskState>.transition(
        store: store,
        onLoading: (_) => Center(
          child: CircularProgressIndicator(),
        ),
        onError: (context, error) => Center(
          child: Text('Deu Ruim'),
        ),
        onState: (context, state) => ListView.builder(
            itemCount: state.tasks.length,
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return ListTile(
                title: Text(task.title),
              );
            }),
      ),
    );
  }
}
