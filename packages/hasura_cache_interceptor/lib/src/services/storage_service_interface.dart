abstract class IStorageService {
  Future<dynamic> get(String key);
  Future<bool> containsKey(String key);
  Future<void> put(String key, dynamic value);
  Future<void> remove(String key);
  Future<void> clear();
}
