///The [IStorageService] class is an abstract class acting as
///the interface.
abstract class IStorageService {
  ///Method [get] signature
  ///get the [key] values
  Future<dynamic> get(String key);

  ///Method [containsKey] signature
  ///get the value using the given [key]
  Future<bool> containsKey(String key);

  ///Method [put] signature
  ///Add the given [key] and [value]
  Future<void> put(String key, dynamic value);

  ///Method [remove] signature
  ///removes the value with the given [key]
  Future<void> remove(String key);

  ///Method [clear] signature
  Future<void> clear();
}
