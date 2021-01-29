import 'package:hasura_connect/src/di/injection.dart' as sl;
import 'package:test/test.dart';

void main() {
  test('should register injection bind', () {
    sl.register('teste');
    sl.register(0);
    expect(sl.get<String>(), 'teste');
    expect(sl.get<int>(), 0);
  });
  test('should return null', () {
    expect(() => sl.get<bool>(), throwsA(isA<Exception>()));
  });
}
