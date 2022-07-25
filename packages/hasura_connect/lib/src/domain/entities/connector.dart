import 'dart:async';

class Connector extends Stream {
  final Stream _webSocketStram;
  final void Function(List<int> event)? add;
  final Future Function()? close;
  final Future? done;
  final int Function()? closeCodeFunction;
  int get closeCode => closeCodeFunction != null ? closeCodeFunction!() : 0;

  Connector(
    this._webSocketStram, {
    this.add,
    this.close,
    this.done,
    this.closeCodeFunction,
  });

  @override
  StreamSubscription listen(
    void Function(dynamic event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _webSocketStram.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
