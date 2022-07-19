import 'dart:async';
import 'dart:convert';

import 'package:hasura_cache_interceptor/hasura_cache_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesStorageService implements IStorageService {
  final _instance = Completer<SharedPreferences>();

  factory SharedPreferencesStorageService() => SharedPreferencesStorageService._();

  factory SharedPreferencesStorageService.test(SharedPreferences instance) => SharedPreferencesStorageService._(instance);

  SharedPreferencesStorageService._([SharedPreferences? instance]) {
    if (instance == null) {
      _initInstance();
    } else {
      _instance.complete(instance);
    }
  }

  Future<void> _initInstance() async {
    final instance = await SharedPreferences.getInstance();
    _instance.complete(instance);
  }

  @override
  Future<bool> containsKey(String key) async {
    final instance = await _instance.future;
    return instance.containsKey(key);
  }

  @override
  Future<dynamic> get(String key) async {
    final instance = await _instance.future;
    final data = instance.getString(key);
    return data == null ? null : json.decode(data);
  }

  @override
  Future<void> put(String key, dynamic value) async {
    final instance = await _instance.future;
    if (value != null) {
      await instance.setString(key, json.encode(value));
    }
  }

  @override
  Future<void> clear() async {
    final instance = await _instance.future;
    await instance.clear();
  }

  @override
  Future<void> remove(String key) async {
    final instance = await _instance.future;
    await instance.remove(key);
  }
}
