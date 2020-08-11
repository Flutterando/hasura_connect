import 'dart:async';

import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:meta/meta.dart';

class Snapshot<T> extends Stream<T> implements EventSink<T> {
  StreamController controller;
  Stream<T> rootStream;
  Query query;
  final _WrapperStartWith<T> _wrapper = _WrapperStartWith<T>();
  final void Function(Snapshot) closeConnection;
  final void Function(Snapshot) changeVariablesF;

  Snapshot({
    @required Query query,
    this.closeConnection,
    this.rootStream,
    this.controller,
    T defaultValue,
    this.changeVariablesF,
  }) {
    _wrapper.value = defaultValue;
    this.query = query;
    controller = controller ?? StreamController.broadcast();
    rootStream = rootStream ??
        controller.stream.transform(StartWithStreamTransformer<T>(_wrapper));
  }
  Future changeVariables(Map<String, dynamic> variables) async {
    query = query.copyWith(variables: variables);
    changeVariablesF(this);
  }

  @override
  StreamSubscription<T> listen(void Function(T event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    return rootStream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Snapshot<S> map<S>(S Function(T event) convert) {
    return Snapshot<S>(
        query: query,
        rootStream: rootStream.map((e) => convert(e)),
        controller: controller,
        closeConnection: closeConnection,
        changeVariablesF: changeVariablesF,
        defaultValue: convert(_wrapper.value));
  }

  @override
  void add(T event) {
    _wrapper.value = event;
    controller.add(event);
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    controller.addError(error, stackTrace);
  }

  @mustCallSuper
  @override
  void close() {
    controller.stream.drain();
    controller.close();
    closeConnection?.call(this);
  }
}

class StartWithStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  StartWithStreamTransformer(_WrapperStartWith<T> wrapper)
      : transformer = _buildTransformer<T>(wrapper);

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
