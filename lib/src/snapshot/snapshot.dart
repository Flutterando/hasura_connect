import 'package:flutter/foundation.dart';

abstract class Snapshot<T> extends Stream<T> {
  ///Transform [Snapshot] in other type
  Snapshot<S> convert<S>(S Function(dynamic) convert,
      {@required Map Function(S object) cachePersist});

  ///change variables of subscription query
  void changeVariable(Map<String, dynamic> variables);

  ///remove [Snapshot] local cache
  Future cleanCache();

  ///close [Snapshot] Connection
  Future close();

  ///get last [Stream] value
  T get value;

  ///add to [Snapshot] [Stream] and cache value
  void add(T newValue);
}
