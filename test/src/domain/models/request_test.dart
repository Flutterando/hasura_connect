import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:test/test.dart';

void main() {
  final request = Request(
      headers: {'Authorization': 'bearer'},
      url: 'https://flutterando.com',
      query: Query(document: 'query'));
  test('should create request and add news headers', () {
    expect(request.headers.containsKey('Authorization'), true);
  });

  test('copywith', () {
    expect(request, request);
    expect(request.copyWith() != request, true);
  });
}
