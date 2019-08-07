import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_connect/src/snapshot.dart';

main() async {
  HasuraConnect conn = HasuraConnect('http://localhost:8080/v1/graphql');

  var r = await conn.query(docQuery);
  print(r);

  Snapshot snap = conn.subscription(docSubscription);
  snap.stream.listen((data) {
    print(data);
  }).onError((err) {
    print(err);
  });
}

String docSubscription = """
  subscription {
    authors {
        id
        email
        name
      }
  }
""";

String docQuery = """
  query {
    authors {
        id2
        email
        name
      }
  }
""";
