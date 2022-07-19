import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_triple/flutter_triple.dart';

import 'home_store.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({Key? key, this.title = 'Home Page'}) : super(key: key);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final HomeStore store = Modular.get();

  @override
  void initState() {
    super.initState();
    store.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ScopedBuilder<HomeStore, Exception, List<Books>>.transition(
        store: store,
        onLoading: (_) => Center(
          child: CircularProgressIndicator(),
        ),
        onError: (context, error) => Center(
          child: Text('Deu Ruim'),
        ),
        onState: (context, state) => ListView.builder(
          itemCount: state.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(state[index].name),
          ),
        ),
      ),
    );
  }
}
