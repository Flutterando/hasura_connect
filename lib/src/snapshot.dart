import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_connect/src/hydrated.dart';
import 'package:rxdart/rxdart.dart';

import 'local_storage.dart';

class Snapshot<T> {
  final Function _close;
  final void Function(Snapshot) _renew;

  HasuraConnect _conn;

  ///Info about Snapshot [query] [variables] and [key]
  final SnapshotInfo info;
  HydratedSubject<T> _controller;
  final Stream<T> _streamInit;
  StreamSubscription _streamSubscription;

  ///get subscription stream for listener graphql data
  ValueObservable<T> get stream => _controller.stream;

  Snapshot(this.info, this._streamInit, this._close, this._renew,
      {StreamController<T> controllerTest, HasuraConnect conn}) {
    _conn = conn;

    if (controllerTest == null) {
      _controller = HydratedSubject<T>(
        info.key,
        hydrate: (String i) {
          return i == null ? null : jsonDecode(i);
        },
        persist: (obj) {
          return obj == null ? null : jsonEncode(obj);
        },
      );
    } else {
      _controller = controllerTest;
    }

    _streamSubscription = _streamInit.listen(
      (data) {
        if (!_controller.isClosed) {
          _controller.add(data);
        }
      },
    );
  }

  ///Perform Caching Mutation
  ///
  ///Use [onNotify] param for custom update your method.
  Future mutation(String doc,
      {Map<String, dynamic> variables, T Function(T) onNotify}) {
    if (onNotify != null) {
      T data = onNotify(_controller.value);
      _controller.add(data);
    }
    return _conn.mutation(doc, variables: variables, cache: true);
  }

  Snapshot<S> _copyWith<S>(
      {SnapshotInfo info,
      Stream streamInit,
      Function close,
      StreamController<S> controller,
      HasuraConnect conn,
      Function(Snapshot) renew}) {
    return Snapshot<S>(info ?? this.info, streamInit ?? this._streamInit,
        close ?? this.close, renew ?? this._renew,
        conn: conn ?? this._conn,
        controllerTest: controller ?? this._controller);
  }

  ///Transform [Snapshot] in other type
  Snapshot<S> map<S>(S Function(dynamic) convert,
      {@required String Function(S object) cachePersist}) {
    assert(cachePersist != null);

    var v = _copyWith<S>(
      streamInit: _streamInit.map<S>(convert),
      controller: HydratedSubject<S>(
        info.key,
        hydrate: (String s) {
          return s == null ? null : convert(jsonDecode(s));
        },
        persist: (S obj) {
          return obj == null ? null : cachePersist(obj);
        },
      ),
    );
    return v;
  }

  ///change variables of subscription query
  changeVariable(Map<String, dynamic> v) {
    info.variables = v;
    _renew(this);
  }

  ///remove [Snapshot] local cache
  Future cleanCache() async {
    LocalStorage _localStorage = LocalStorage();
    // await _localStorage.remove("subscriptions-${info.key}");
    await _localStorage.remove("${info.key}");
  }

  ///close [Snapshot]
  Future close() async {
    await _streamSubscription.cancel();
    await _controller.close();
    await _close();
  }
}

class SnapshotInfo {
  ///[query] used in [Snapshot]
  final String query;

  ///[key] used in [Snapshot]
  final String key;

  ///[variables] used in [Snapshot]
  Map<String, dynamic> variables;

  SnapshotInfo({this.query, this.key, this.variables});

  ///return object [SnapshotInfo] as Json
  toJson() {
    return {
      "key": key,
      "query": query,
      "variables": variables,
    };
  }

  ///create [SnapshotInfo] from json
  factory SnapshotInfo.fromJson(Map json) => SnapshotInfo(
        query: json['query'],
        key: json['key'],
        variables: json['variables'],
      );
}
