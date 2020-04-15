abstract class LocalStorage {
  Future init(String name);
  Future close();
  Future clear();
  Future<bool> remove(String key);
  Future put(String key, Map query);
  Future<Map> getValue(String key);
  Future<Map<String, dynamic>> getAll();
}
