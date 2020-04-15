import 'dart:async';
import 'package:rxdart/rxdart.dart';

import '../../hasura_connect.dart';

class HydratedSubject<T> extends Subject<T> implements ValueStream<T> {
  String _key;
  T _seedValue;
  _Wrapper<T> _wrapper;
  LocalStorage _cacheLocal;

  T Function(Map value) _hydrate;
  Map Function(T value) _persist;
  void Function() _onHydrate;

  HydratedSubject._(
      this._key,
      this._seedValue,
      this._hydrate,
      this._persist,
      this._onHydrate,
      StreamController<T> controller,
      Stream<T> observable,
      this._wrapper,
      this._cacheLocal)
      : super(controller, observable) {
    _hydrateSubject();
  }

  factory HydratedSubject(
    String key, {
    T seedValue,
    LocalStorage cacheLocal,
    T Function(Map value) hydrate,
    Map Function(T value) persist,
    void Function() onHydrate,
    void Function() onListen,
    void Function() onCancel,
    bool sync = false,
  }) {
    // assert that T is a type compatible with shared_preferences,
    // or that we have hydrate and persist mapping functions
    assert(T == int ||
        T == double ||
        T == bool ||
        T == String ||
        [''] is T ||
        (hydrate != null && persist != null));

    // ignore: close_sinks
    final controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final wrapper = _Wrapper<T>(seedValue);

    return HydratedSubject<T>._(
        key,
        seedValue,
        hydrate,
        persist,
        onHydrate,
        controller,
        Rx.defer<T>(
            () => wrapper.latestValue == null
                ? controller.stream
                : controller.stream.startWith(wrapper.latestValue),
            reusable: true),
        wrapper,
        cacheLocal);
  }

  @override
  void onAdd(T event) {
    _wrapper.latestValue = event;
    _persistValue(event);
  }

  @override
  ValueStream<T> get stream => this;

  /// Get the latest value emitted by the Subject
  @override
  T get value => _wrapper.latestValue;

  /// Set and emit the new value
  set value(T newValue) => add(newValue);

  @override
  bool get hasValue => _wrapper.latestValue != null;

  /// Hydrates the HydratedSubject with a value stored on the user's device.
  ///
  /// Must be called to retreive values stored on the device.
  Future<void> _hydrateSubject() async {
    var val;
    var value = await _cacheLocal.getValue(_key);
    if (_hydrate != null) {
      val = _hydrate(value);
    } else {
      val = value;
    }

    if (val != null && val != _seedValue) {
      add(val);
    }

    if (_onHydrate != null) {
      _onHydrate();
    }
  }

  Future changeKey(String newKey) async {
    _key = newKey;
    _wrapper.latestValue = null;
    await _hydrateSubject();
  }

  void _persistValue(T val) async {
    if (_persist != null) {
      await _cacheLocal.put(_key, _persist(val));
    } else if (val is Map) {
      await _cacheLocal.put(_key, val);
    }
  }

  /// A unique key that references a storage container for a value persisted on the device.
  String get key => _key;
}

class _Wrapper<T> {
  T latestValue;

  _Wrapper(this.latestValue);
}
