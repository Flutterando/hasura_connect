import 'dart:async';

import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:meta/meta.dart';

///Class [Snapshot] extends [Stream] and implements [EventSink].
///The class implements a new method called [changeVariables]
class Snapshot<T> extends Stream<T> implements EventSink<T> {
  late StreamController _controller;
  late Stream<T> _rootStream;
  late Query _query;

  /// Variable [query] type [Query]
  Query get query => _query;
  final WrapperStartWith<T> _wrapper = WrapperStartWith<T>();

  ///Void Function Snapshot [closeConnection]
  final void Function(Snapshot)? closeConnection;

  ///Void Function Snapshot [changeVariablesF]
  final void Function(Snapshot)? changeVariablesF;

  ///Variable [value] type [T]
  T? get value => _wrapper.value;

  ///Class [Snapshot] constructor
  Snapshot({
    required Query query,
    Stream<T>? rootStream,
    StreamController? controller,
    this.closeConnection,
    T? defaultValue,
    this.changeVariablesF,
  }) {
    _wrapper.value = defaultValue;
    _query = query;
    _controller = controller ?? StreamController.broadcast();
    _rootStream = rootStream ??
        _controller.stream.transform(StartWithStreamTransformer<T>(_wrapper));
  }

  ///The method [changeVariables] receives a [Map]
  ///query value will be it's own value but setting [variables] as [variables]
  ///received
  ///if [changeVariablesF] is different from null, runs [changeVariablesF]
  ///call method
  Future changeVariables(Map<String, dynamic> variables) async {
    _query = _query.copyWith(variables: variables);
    if (changeVariablesF != null) {
      changeVariablesF?.call(this);
    }
  }

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _rootStream.listen(
      (T event) {
        _wrapper.value = event;
        onData?.call(event);
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Snapshot<S> map<S>(S Function(T event) convert) {
    return Snapshot<S>(
      query: _query,
      rootStream: _rootStream.map((e) => convert(e)),
      controller: _controller,
      closeConnection: closeConnection,
      changeVariablesF: changeVariablesF,
      defaultValue:
          _wrapper.value == null ? null : convert(_wrapper.value as T),
    );
  }

  @override
  void add(T event) {
    _wrapper.value = event;
    _controller.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
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

///Class [StartWithStreamTransformer] extends [StreamTransformerBase]
///implements [bind] in accordance with is necessary
class StartWithStreamTransformer<T> extends StreamTransformerBase<T, T> {
  ///Variable [transformer] type [StreamTransformer]
  final StreamTransformer<T, T> transformer;

  ///[StartWithStreamTransformer] constructor
  StartWithStreamTransformer(WrapperStartWith<T> wrapper)
      : transformer = _buildTransformer<T>(wrapper);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
    WrapperStartWith wrapper,
  ) {
    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      late StreamController<T> controller;
      late StreamSubscription<T> subscription;

      controller = StreamController<T>(
        sync: true,
        onListen: () {
          if (wrapper.value != null) {
            controller.add(wrapper.value);
          }

          subscription = input.listen(
            controller.add,
            onError: controller.addError,
            onDone: controller.close,
            cancelOnError: cancelOnError,
          );
        },
        onPause: ([Future<dynamic>? resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel(),
      );

      return controller.stream.listen(null);
    });
  }
}

/// Class [WrapperStartWith] responsible for acting as a wrapper
class WrapperStartWith<T> {
  ///Variable [value] type [T]
  T? value;
}
