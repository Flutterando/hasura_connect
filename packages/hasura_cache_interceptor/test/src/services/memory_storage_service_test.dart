import 'package:hasura_cache_interceptor/hasura_cache_interceptor.dart';
import 'package:test/test.dart';

void main() {
  MemoryStorageService storage = MemoryStorageService();

  setUp(() {
    storage = MemoryStorageService();
  });

  test('get', () async {
    storage.db['mock_key'] = 'mock_value';
    final response = await storage.get('mock_key');
    expect(response, 'mock_value');
  });

  test('put', () async {
    await storage.put('mock_key', 'mock_value');
    expect(storage.db['mock_key'], 'mock_value');
  });

  test('remove', () async {
    storage.db['mock_key'] = 'mock_value';
    await storage.remove('mock_key');
    expect(storage.db, {});
  });

  group('containsKey', () {
    test('true', () async {
      storage.db['mock_key'] = {
        'value': 'mock_value'
      };
      final response = await storage.containsKey('mock_key');
      expect(response, true);
    });
    test('false', () async {
      final response = await storage.containsKey('mock_key');
      expect(response, false);
    });
  });

  test('clear', () async {
    storage.db['mock_key'] = {
      'value': 'mock_value'
    };
    await storage.clear();
    expect(storage.db, {});
  });
}
