import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hasura_connect/src/core/hasura.dart';
import 'package:hasura_connect/src/snapshot/snapshot_info.dart';
import 'package:hasura_connect/src/utils/hydrated.dart';

import '../services/local_storage_hasura.dart';
import 'snapshot.dart';

class SnapshotData<T> extends Snapshot<T> {
  final Function _close;
  final void Function(SnapshotData) _renew;

  HasuraConnect _conn;

  ///Info about Snapshot [query] [variables] and [key]
  final SnapshotInfo info;
  HydratedSubject<T> _controller;
  T Function(Map) _hydrated;
  Map Function(T) _persist;
  LocalStorageHasura _localStorageCache;

  @override
  T get value => _controller.value;

  final Stream<T> _streamInit;
  StreamSubscription _streamSubscription;

  SnapshotData(this.info, this._streamInit, this._close, this._renew,
      {LocalStorageHasura localStorageCache,
      HasuraConnect conn,
      T Function(Map) hydrated,
      Map Function(T) persist}) {
    _localStorageCache = localStorageCache;
    _conn = conn;
    _hydrated = hydrated;
    _persist = persist;

    _controller = HydratedSubject<T>(info.key,
        hydrate: _hydrated, persist: _persist, cacheLocal: _localStorageCache);

    _streamSubscription = _streamInit.listen((data) {
      if (!_controller.isClosed) {
        _controller.add(data);
      }
    }, onError: (e) {
      _controller.addError(e);
    });
  }

  SnapshotData<S> _copyWith<S>(
      {SnapshotInfo info,
      LocalStorageHasura localStorageCache,
      Stream streamInit,
      Function close,
      HasuraConnect conn,
      S Function(Map) hydrated,
      Map Function(S) persist,
      Function(Snapshot) renew}) {
    return SnapshotData<S>(
      info ?? this.info,
      streamInit ?? this._streamInit,
      close ?? this.close,
      renew ?? this._renew,
      conn: conn ?? this._conn,
      hydrated: hydrated ?? this._hydrated,
      persist: persist ?? this._persist,
      localStorageCache: localStorageCache ?? this._localStorageCache,
    );
  }

  @override
  Snapshot<S> convert<S>(S Function(dynamic) convert,
      {@required Map Function(S object) cachePersist}) {
    assert(cachePersist != null);

    var _h = (Map s) {
      return s == null ? null : convert(s);
    };

    var _p = (S obj) {
      return obj == null ? null : cachePersist(obj);
    };

    var v = _copyWith<S>(
        streamInit: _streamInit.map<S>(convert), hydrated: _h, persist: _p);
    return v;
  }

  @override
  void changeVariable(Map<String, dynamic> v) {
    info.variables = v;
    if (info.isQuery) {
      _sendNewQuery();
    } else {
      _renew(this);
    }
  }

  _sendNewQuery() async {
    final data = await _conn.query(info.query, variables: info.variables);
    _controller.add(data);
  }

  @override
  Future cleanCache() async {
    await _localStorageCache.remove(info.key);
  }

  @override
  StreamSubscription<T> listen(void Function(T event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    return _controller.listen(onData,
        cancelOnError: cancelOnError, onError: onError, onDone: onDone);
  }

  @override
  Future close() async {
    await _streamSubscription.cancel();
    await _controller.close();
    await _close();
  }

  @override
  void add(T newValue) {
    _controller.add(newValue);
  }
}
