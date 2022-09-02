import 'dart:async';

///The class [Connector] extends the [Stream] class
class Connector extends Stream {
  final Stream _webSocketStram;

  ///Creates the void Function [add]
  final void Function(List<int> event)? add;

  ///Creates the Future Function [close]
  final Future Function()? close;

  ///Creates the Future variable [done]
  final Future? done;

  ///Creates the int Function [closeCodeFunction]
  final int Function()? closeCodeFunction;

  ///Creates a get to [closeCode], it checks if [closeCodeFunction] is different
  ///from null, if yes, calls [closeCodeFunction] else the value will be 0
  int get closeCode => closeCodeFunction != null ? closeCodeFunction!() : 0;

  /// [Connector] class constructor
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
