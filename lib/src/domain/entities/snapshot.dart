import 'dart:async';

import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:meta/meta.dart';

class Snapshot<T> extends Stream<T> implements EventSink<T> {
  final _controller = StreamController.broadcast();
  final Query query;
  final void Function(Snapshot) closeConnection;
  T _value;

  Snapshot({@required this.query, this.closeConnection, T defaultValue}) {
    _value = defaultValue;
  }

  @override
  StreamSubscription<T> listen(void Function(T event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    return _controller.stream
        .transform(StartWithStreamTransformer(_value))
        .listen(onData,
            onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  void add(T event) {
    _value = event;
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

  StartWithStreamTransformer(T startValue)
      : transformer = _buildTransformer(startValue);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(T startValue) {
    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            try {
              controller.add(startValue);
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
