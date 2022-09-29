import 'package:example/app/modules/home/home_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:hasura_connect/hasura_connect.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({Key? key, this.title = 'Home Page'}) : super(key: key);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final HomeStore store = Modular.get();
  final HasuraConnect connect = Modular.get();
  Snapshot<List<Books>>? books;

  @override
  void initState() {
    super.initState();
    store.loadData();
    getBook(1).then((value) {
      books = value;
      setState(() {
          
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          StreamBuilder<List<Books>>(
            stream: books,
            builder: (context, snapshot) {
            return Text(snapshot.data?.first.name ?? '');
          },),
          Expanded(
            child: ScopedBuilder<HomeStore, Exception, List<Books>>.transition(
              store: store,
              onLoading: (_) => const Center(
                child: CircularProgressIndicator(),
              ),
              onError: (context, error) => const Center(
                child: Text('Deu Ruim'),
              ),
              onState: (context, state) => ListView.builder(
                itemCount: state.length,
                itemBuilder: (context, index) => ElevatedButton(
                  onPressed: () {
                    books?.changeVariables({'id': state[index].id});
                  },
                  child: Text(state[index].name),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Snapshot<List<Books>>> getBook(int id) async {
    const query = r'''
             subscription getBooks($id: Int) {
  books(where: {id: {_eq: $id}}) {
    id
    name
    authors {
      name
      id
    }
  }
}''';

    final snapshot = await connect.subscription(query, variables: {'id': id});
    return snapshot.map((data) {
      return Books.fromJsonList(data['data']['books']) ?? [];
    });
  }
}
