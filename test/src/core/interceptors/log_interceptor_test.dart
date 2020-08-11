import 'package:hasura_connect/hasura_connect.dart';
import 'package:test/test.dart';

void main() {
  final log = LogInterceptor();
  test('LogInterceptor onConnect exec ',
      () => expect(log.onConnected(null), completes));
  test('LogInterceptor onTryAgain exec ',
      () => expect(log.onTryAgain(null), completes));
}
