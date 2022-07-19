import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:test/test.dart';

void main() {
  final request = Request(url: 'null', query: Query(document: ''));
  test('ConnectionError ', () {
    var error = ConnectionError('test', request: request);
    expect(error.toString(), 'ConnectionError: test');
  });
  test('DatasourceError ', () {
    var error = DatasourceError('test', request: request);
    expect(error.toString(), 'DatasourceError: test');
  });

  test('HasuraRequestError ', () {
    var error = HasuraRequestError('test', null, request: request);
    expect(error.toString(), 'HasuraRequestError: test');
    error = HasuraRequestError.fromException('test', null, request: request);
    expect(error.toString(), 'HasuraRequestError: test');
    error = HasuraRequestError.fromJson({'message': 'test'}, request: request);
    expect(error.toString(), 'HasuraRequestError: test');
  });
  test('InvalidRequestError ', () {
    var error = InvalidRequestError('test');
    expect(error.toString(), 'InvalidRequestError: test');
  });
}
