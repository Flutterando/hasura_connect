import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_cache_interceptor/src/shared_preferences_storage_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {
  Map data = {};

  @override
  get(String key) => data[key];

  @override
  String getString(String key) => data[key];

  @override
  Future<bool> remove(String key) async {
    data.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    data.clear();
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    data[key] = value;
    return true;
  }

  @override
  bool containsKey(String key) => data.containsKey(key);
}

void main() {
  late MockSharedPreferences service;
  late SharedPreferencesStorageService storage;

  setUp(() {
    service = MockSharedPreferences();
    storage = SharedPreferencesStorageService.test(service);
  });

  test("get", () async {
    service.data["mock_key"] = '{"mock":"value"}';
    final response = await storage.get("mock_key");
    expect(response, {"mock": "value"});
  });

  test("put", () async {
    await storage.put("mock_key", {"mock": "value"});
    expect(service.data["mock_key"], '{"mock":"value"}');
  });

  test("remove", () async {
    service.data["mock_key"] = 'mock_value';
    await storage.remove("mock_key");
    expect(service.data, {});
  });

  group("containsKey", () {
    test("true", () async {
      service.data["mock_key"] = {'value': 'mock_value'};
      final response = await storage.containsKey("mock_key");
      expect(response, true);
    });
    test("false", () async {
      final response = await storage.containsKey("mock_key");
      expect(response, false);
    });
  });

  test("clear", () async {
    service.data["mock_key"] = {'value': 'mock_value'};
    await storage.clear();
    expect(service.data, {});
  });
}
