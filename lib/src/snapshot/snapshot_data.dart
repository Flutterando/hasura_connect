import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hasura_connect/src/core/hasura.dart';
import 'package:hasura_connect/src/exceptions/hasura_error.dart';
import 'package:hasura_connect/src/services/local_storage.dart';
import 'package:hasura_connect/src/snapshot/snapshot_info.dart';
import 'package:hasura_connect/src/utils/hydrated.dart';

import '../../hasura_connect.dart';
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
  LocalStorage _localStorageCache;
  final _initHydrated = Completer<bool>();

  @override
  T get value => _controller.value;

  final Stream<T> _streamInit;
  StreamSubscription _streamSubscription;

  SnapshotData(this.info, this._streamInit, this._close, this._renew,
      {LocalStorage localStorageCache,
      HasuraConnect conn,
      T Function(Map) hydrated,
      Map Function(T) persist}) {
    _localStorageCache = localStorageCache;
    _conn = conn;
    _hydrated = hydrated;
    _persist = persist;

    _controller = HydratedSubject<T>(info.keyCache,
        hydrate: _hydrated,
        persist: _persist,
        cacheLocal: _localStorageCache, onHydrate: () {
      if (!_initHydrated.isCompleted) _initHydrated.complete(true);
    });

    _streamSubscription = _streamInit.listen((data) async {
      await _initHydrated.future;
      if (!_controller.isClosed) {
        _controller.add(data);
      }
    }, onError: (e) {
      _controller.addError(e);
    });
  }

  SnapshotData<S> _copyWith<S>(
      {SnapshotInfo info,
      LocalStorage localStorageCache,
      Stream streamInit,
      Function close,
      HasuraConnect conn,
      S Function(Map) hydrated,
      Map Function(S) persist,
      Function(Snapshot) renew}) {
    return SnapshotData<S>(
      info ?? this.info,
      streamInit ?? _streamInit,
      close ?? close,
      renew ?? _renew,
      conn: conn ?? _conn,
      hydrated: hydrated ?? _hydrated,
      persist: persist ?? _persist,
      localStorageCache: localStorageCache ?? _localStorageCache,
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
  Future changeVariable(Map<String, dynamic> v) async {
    info.variables = v;
    await _controller.changeKey(info.keyCache);
    if (info.isQuery) {
      _sendNewQuery();
    } else {
      _renew(this);
    }
  }

  void _sendNewQuery() async {
    try {
      final data = await _conn.query(info.query, variables: info.variables);
      var newData = _hydrated != null ? _hydrated(data) : data;
      _controller.add(newData);
    } on HasuraError catch (e) {
      if (value == null) {
        _controller.addError(e);
      }
    }
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
    await _close();
    await _streamSubscription.cancel();
    await _controller.close();
  }

  @override
  void add(T newValue) {
    _controller.add(newValue);
  }
}
