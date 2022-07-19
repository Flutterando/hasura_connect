# Example

### Page

```dart

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
```

### Store

```dart
import 'package:flutter_triple/flutter_triple.dart';
import 'package:hasura_connect/hasura_connect.dart';

class HomeStore extends StreamStore<Exception, List<Books>> {
  final HasuraConnect hasuraConnect;

  HomeStore(this.hasuraConnect) : super([]);

  Future<void> loadData() async {
    setLoading(true);
    var result = await hasuraConnect.query('''
    query getBooks {
        books {
          id
          name
        }
      }''');

    var listBooks =
        (result['data']['books'] as List).map((e) => Books.fromMap(e)).toList();

    update(listBooks);

    setLoading(false);
  }
}

class Books {
  Books({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory Books.fromMap(Map<String, dynamic> json) => Books(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
      };
}

```

Welcome to Hasura
