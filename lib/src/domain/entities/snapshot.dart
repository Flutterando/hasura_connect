import 'dart:async';

import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:meta/meta.dart';

class Snapshot<T> extends Stream<T> implements EventSink<T> {
  final _controller = StreamController.broadcast();
  final Query query;
  final _WrapperStartWith<T> _wrapper = _WrapperStartWith<T>();
  final void Function(Snapshot) closeConnection;

  Snapshot({@required this.query, this.closeConnection, T defaultValue}) {
    _wrapper.value = defaultValue;
  }

  @override
  StreamSubscription<T> listen(void Function(T event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    return _controller.stream
        .transform(StartWithStreamTransformer(_wrapper))
        .listen(onData,
            onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  void add(T event) {
    _wrapper.value = event;
    _controller.add(event);
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    _controller.addError(error, stackTrace);
  }

  @mustCallSuper
  @override
  void close() {
    _controller.stream.drain();
    _controller.close();
    closeConnection?.call(this);
  }
}

class StartWithStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  StartWithStreamTransformer(_WrapperStartWith wrapper)
      : transformer = _buildTransformer(wrapper);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
      _WrapperStartWith wrapper) {
    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            try {
              if (wrapper.value != null) {
                controller.add(wrapper.value);
              }
            } catch (e, s) {
              controller.addError(e, s);
            }

            subscription = input.listen(controller.add,
                onError: controller.addError,
                onDone: controller.close,
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}

class _WrapperStartWith<T> {
  T value;
}
