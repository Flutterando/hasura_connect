import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:test/test.dart';

void main() {
  test('should be valid Query if start with "query"', () {
    const query = Query(
      document: '''
query {
        author(
          where: {name: {_eq: "Sidney"}}
        ) {
          id
          name
        }
      }
    ''',
      key: 'fdsfd',
    );

    expect(query.isValid, true);
  });
  test('should be valid Query if start with "mutation"', () {
    const query = Query(
      document: '''
mutation {
        author(
          where: {name: {_eq: "Sidney"}}
        ) {
          id
          name
        }
      }
    ''',
      key: 'dfsfdsf',
    );

    expect(query.isValid, true);
  });
  test('should be valid Query if start with "subscription"', () {
    const query = Query(
      document: '''
subscription {
        author(
          where: {name: {_eq: "Sidney"}}
        ) {
          id
          name
        }
      }
    ''',
      key: 'dfszfsd',
    );

    expect(query.isValid, true);
  });
  test('should convert to map', () {
    const query = Query(
      document: '''
subscription {
        author(
          where: {name: {_eq: "Sidney"}}
        ) {
          id
          name
        }
      }
    ''',
      key: 'fdsfds',
      variables: {},
    );
    final map = query.toJson();
    expect(map, isA<Map>());
    expect(map['query'], isNotNull);
    expect(map['variables'], isA<Map>());
  });

  test('should change variable', () {
    var query = const Query(
      document: '''
subscription {
        author(
          where: {name: {_eq: "Sidney"}}
        ) {
          id
          name
        }
      }
    ''',
      key: 'fdsfds',
    );
    expect(query.variables, null);
    query = query.copyWith(
      variables: {
        'test': 'test'
      },
    );
    expect(query.variables, isA<Map>());
    query = query.copyWith(variables: {});
    expect(query.variables?.length, 0);
  });

  test('copywith', () {
    const query = Query(
      document: '''
subscription {
        author(
          where: {name: {_eq: "Sidney"}}
        ) {
          id
          name
        }
      }
    ''',
      key: 'fdsfds',
    );
    expect(query, query);
    expect(query.copyWith() != query, true);
  });
}
