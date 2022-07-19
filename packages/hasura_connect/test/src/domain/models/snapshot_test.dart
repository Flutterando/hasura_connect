import 'package:hasura_connect/src/domain/entities/snapshot.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:test/test.dart';

void main() {
  final snapshot = Snapshot(query: Query(document: '''query {
        author(
          where: {name: {_eq: "Sidney"}}
        ) {
          id
          name
        }
      }
    ''', key: 'fdsfd'));

  test('should be valid Query if start with "query"', () {
    snapshot.add('test');
    expect(snapshot, emits('test'));
  });
}
