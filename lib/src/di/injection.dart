List _dependencies = [];

void register(dynamic bind) {
  _dependencies.add(bind);
}

void cleanModule() {
  _dependencies.clear();
}

T get<T>() {
  return _dependencies.firstWhere(
    (element) => element is T,
    orElse: () => null,
  );
}
