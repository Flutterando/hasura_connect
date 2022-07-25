List _dependencies = [];

void register(dynamic bind) {
  _dependencies.add(bind);
}

void cleanModule() {
  _dependencies.clear();
}

T get<T>() {
  try {
    return _dependencies.firstWhere((element) => element is T) as T;
  } catch (e) {
    throw Exception('injection error');
  }
}
