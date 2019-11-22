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

  T value;
  HasuraConnect _conn;
  final SnapshotInfo info;
  HydratedSubject<T> _controller;
  final Stream<T> _streamInit;
  StreamSubscription _streamSubscription;

  ValueObservable<T> get stream => _controller.stream;

  Snapshot(this.info, this._streamInit, this._close, this._renew,
      {StreamController<T> controllerTest, HasuraConnect conn, this.value}) {
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
        value = data;
        if (!_controller.isClosed) {
          _controller.add(data);
        }
      },
    );
  }

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
      S value,
      Function(Snapshot) renew}) {
    return Snapshot<S>(info ?? this.info, streamInit ?? this._streamInit,
        close ?? this.close, renew ?? this._renew,
        conn: conn ?? this._conn,
        value: value,
        controllerTest: controller ?? this._controller);
  }

  Snapshot<S> map<S>(S Function(dynamic) convert,
      {@required String Function(S object) cachePersist}) {
    assert(cachePersist != null);

    var valueParse = this.value != null ? convert(this.value) : null;

    final controller = HydratedSubject<S>(
      info.key,
      hydrate: (String s) {
        return s == null ? null : convert(jsonDecode(s));
      },
      persist: (S obj) {
        return obj == null ? null : cachePersist(obj);
      },
    );

    var v = _copyWith<S>(
      streamInit: _streamInit.map<S>(convert),
      controller: controller,
      value: valueParse,
    );
    return v;
  }

  changeVariable(Map<String, dynamic> v) {
    info.variables = v;
    _renew(this);
  }

  Future cleanCache() async {
    LocalStorage _localStorage = LocalStorage();
    // await _localStorage.remove("subscriptions-${info.key}");
    await _localStorage.remove("${info.key}");
  }

  Future close() async {
    await _streamSubscription.cancel();
    await _controller.close();
    await _close();
  }
}

class SnapshotInfo {
  final String query;
  final String key;
  Map<String, dynamic> variables;

  SnapshotInfo({this.query, this.key, this.variables});

  toJson() {
    return {
      "key": key,
      "query": query,
      "variables": variables,
    };
  }

  factory SnapshotInfo.fromJson(Map json) => SnapshotInfo(
        query: json['query'],
        key: json['key'],
        variables: json['variables'],
      );
}
