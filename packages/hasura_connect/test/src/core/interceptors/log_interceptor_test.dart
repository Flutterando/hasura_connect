import 'package:hasura_connect/hasura_connect.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class HasuraConnectMock extends Mock implements HasuraConnect {}

void main() {
  final log = LogInterceptor();
  test('LogInterceptor onConnect exec ', () => expect(log.onConnected(HasuraConnectMock()), completes));
  test('LogInterceptor onTryAgain exec ', () => expect(log.onTryAgain(HasuraConnectMock()), completes));
}
