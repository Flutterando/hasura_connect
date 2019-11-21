import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:hydrated/hydrated.dart';
import 'startwith_stream_transformer.dart';

class Snapshot<T> {
  final Function _close;
  final void Function(Snapshot) _renew;
  final String query;
  final String key;
  Map<String, dynamic> variables;

  T value;
  HasuraConnect _conn;

  HydratedSubject<T> _controller;
  final Stream<T> _streamInit;
  StreamSubscription _streamSubscription;

  Stream<T> get stream => _controller.stream.where((v) => value != null);

  // Stream<T> get stream => _controller.stream
  //     .transform(StartWithStreamTransformer(value))
  //     .where((v) => value != null);

  Snapshot(this.key, this.query, this.variables, this._streamInit, this._close,
      this._renew,
      {StreamController<T> controllerTest, HasuraConnect conn, this.value}) {
    _conn = conn;

    if (controllerTest == null) {
      //_controller = StreamController<T>.broadcast();
      _controller = HydratedSubject<T>(
        key,
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
      T data = onNotify(value);
      _controller.add(data);
    }
    return _conn.mutation(doc, variables: variables);
  }

  Snapshot<S> _copyWith<S>(
      {String key,
      String query,
      Map<String, dynamic> variables,
      Stream streamInit,
      Function close,
      StreamController<S> controller,
      HasuraConnect conn,
      S value,
      Function(Snapshot) renew}) {
    return Snapshot<S>(
        key ?? this.key,
        query ?? this.query,
        variables ?? this.variables,
        streamInit ?? this._streamInit,
        close ?? this.close,
        renew ?? this._renew,
        conn: conn ?? this._conn,
        value: value,
        controllerTest: controller ?? this._controller);
  }

  Snapshot<S> map<S>(S Function(dynamic) convert,
      {@required String Function(S object) cachePersist}) {
    assert(cachePersist != null);

    var valueParse = this.value != null ? convert(this.value) : null;

    var v = _copyWith<S>(
      streamInit: _streamInit.map<S>(convert),
      controller: HydratedSubject<S>(
        key,
        hydrate: (String s) {
          return s == null ? null : convert(jsonDecode(s));
        },
        persist: (S obj) {
          return obj == null ? null : cachePersist(obj);
        },
      ),
      value: valueParse,
    );
    return v;
  }

  changeVariable(Map<String, dynamic> v) {
    variables = v;
    _renew(this);
  }

  Future close() async {
    await _streamSubscription.cancel();
    await _controller.close();
    await _close();
  }
}
