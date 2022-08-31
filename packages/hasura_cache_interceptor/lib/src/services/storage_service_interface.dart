///The [IStorageService] class is an abstract class acting as
///the interface.
abstract class IStorageService {
  ///Method [get] signature
  Future<dynamic> get(String key);

  ///Method [containsKey] signature
  Future<bool> containsKey(String key);

  ///Method [put] signature
  Future<void> put(String key, dynamic value);

  ///Method [remove] signature

  Future<void> remove(String key);

  ///Method [clear] signature

  Future<void> clear();
}
