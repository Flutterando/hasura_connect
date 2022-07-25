import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_cache_interceptor/src/hive_storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MockBox<T> extends Mock implements Box<T> {
  Map data = {};

  @override
  Future<void> put(dynamic key, T value) async => data[key] = value;

  @override
  Future<int> clear() async {
    data.clear();
    return 0;
  }

  @override
  Future<void> delete(dynamic key) async {
    if (data.containsKey(key)) {
      data.remove(key);
    }
  }

  @override
  T get(dynamic key, {T? defaultValue}) => data[key] ?? defaultValue;

  @override
  bool containsKey(dynamic key) => data.containsKey(key);
}

void main() {
  late MockBox box;
  late HiveStorageService storage;

  setUp(() {
    box = MockBox();
    storage = HiveStorageService.test(box);
  });

  test('get', () async {
    box.data['mock_key'] = {
      'value': 'mock_value'
    };
    final response = await storage.get('mock_key');
    expect(response, 'mock_value');
  });

  test('put', () async {
    await storage.put('mock_key', 'mock_value');
    expect(box.data['mock_key'], {
      'value': 'mock_value'
    });
  });

  test('remove', () async {
    box.data['mock_key'] = {
      'value': 'mock_value'
    };
    await storage.remove('mock_key');
    expect(box.data, {});
  });

  group('containsKey', () {
    test('true', () async {
      box.data['mock_key'] = {
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
    box.data['mock_key'] = {
      'value': 'mock_value'
    };
    await storage.clear();
    expect(box.data, {});
  });
}
