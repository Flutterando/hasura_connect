import 'package:hasura_connect/src/core/utils/keys_generator.dart';
import 'package:test/test.dart';

void main() {
  final generator = KeyGenerator();

  test('should generate ramdom string with 32 length', () {
    expect(generator.randomString(32).length, 32);
  });
  test('should generate ramdom string with 16 length', () {
    expect(generator.randomString(16).length, 16);
  });
  test('should generate ramdom string with 10 length', () {
    expect(generator.randomString(10).length, 10);
  });
}
