import 'dart:async';

class DeferStream<T> extends Stream<T> {
  final Stream<T> Function() _factory;
  final bool _isReusable;

  @override
  bool get isBroadcast => _isReusable;

  /// Constructs a [Stream] lazily, at the moment of subscription, using
  /// the [streamFactory]
  DeferStream(Stream<T> Function() streamFactory, {bool reusable = false})
      : _isReusable = reusable,
        _factory = reusable
            ? streamFactory
            : (() {
                Stream<T> stream;
                return () => stream ??= streamFactory();
              }());

  @override
  StreamSubscription<T> listen(void Function(T event) onData,
          {Function onError, void Function() onDone, bool cancelOnError}) =>
      _factory().listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}
