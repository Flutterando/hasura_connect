List _dependencies = [];

///The method [register] receives a [dynamic] variable called [bind]
///when called, it adds the [bind] into the _dependencies [List] using
void register(dynamic bind) {
  _dependencies.add(bind);
}
///When the method [cleanModule] is called, it clears the _dependencies [List]
void cleanModule() {
  _dependencies.clear();
}

///The method type [T] [get] opens a try/catch bloc
///it tries to return the first element in the _dependencies [List] where
///the element is a [T] as [T]
///if an error occurs it throws a [Exception]
T get<T>() {
  try {
    return _dependencies.firstWhere((element) => element is T) as T;
  } catch (e) {
    throw Exception('injection error');
  }
}
