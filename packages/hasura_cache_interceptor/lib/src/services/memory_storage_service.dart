import 'package:hasura_cache_interceptor/src/services/storage_service_interface.dart';

/// The class [MemoryStorageService] implements [IStorageService]
class MemoryStorageService implements IStorageService {
  /// The variable [db] is created as an empty dynamic, dynamic [Map],
  /// responsible for storing the key
  final db = {};

  @override
  Future get(String key) async => db[key];

  @override
  Future<bool> containsKey(String key) async => db.containsKey(key);

  @override
  Future<void> put(String key, dynamic value) async => db[key] = value;

  @override
  Future<void> remove(String key) async {
    if (db.containsKey(key)) db.remove(key);
  }

  @override
  Future<void> clear() async => db.clear();
}
