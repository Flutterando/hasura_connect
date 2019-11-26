import 'package:flutter/foundation.dart';

abstract class Snapshot<T> extends Stream<T> {
  ///Perform Caching Mutation
  ///
  ///Use [onNotify] param for custom update your method.
  Future mutation(String doc,
      {Map<String, dynamic> variables, T Function(T) onNotify});

  ///Transform [Snapshot] in other type
  Snapshot<S> convert<S>(S Function(dynamic) convert,
      {@required Map Function(S object) cachePersist});

  ///change variables of subscription query
  void changeVariable(Map<String, dynamic> v);

  ///remove [Snapshot] local cache
  Future cleanCache();

  ///close [Snapshot] Connection
  Future close();

  ///get last [Stream] value
  T get value;
}
