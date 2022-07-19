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

    var listBooks = (result['data']['books'] as List).map((e) => Books.fromMap(e)).toList();

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
