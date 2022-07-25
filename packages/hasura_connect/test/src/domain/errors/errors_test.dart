import 'package:hasura_connect/hasura_connect.dart';
import 'package:test/test.dart';

void main() {
  final request = Request(url: 'null', query: const Query(document: ''));
  test('ConnectionError ', () {
    final error = ConnectionError('test', request: request);
    expect(error.toString(), 'ConnectionError: test');
  });
  test('DatasourceError ', () {
    final error = DatasourceError('test', request: request);
    expect(error.toString(), 'DatasourceError: test');
  });

  test('HasuraRequestError ', () {
    var error = HasuraRequestError('test', null, request: request);
    expect(error.toString(), 'HasuraRequestError: test');
    error = HasuraRequestError.fromException('test', null, request: request);
    expect(error.toString(), 'HasuraRequestError: test');
    error = HasuraRequestError.fromJson(
      {
        'message': 'test'
      },
      request: request,
    );
    expect(error.toString(), 'HasuraRequestError: test');
  });
  test('InvalidRequestError ', () {
    final error = InvalidRequestError('test');
    expect(error.toString(), 'InvalidRequestError: test');
  });
}
