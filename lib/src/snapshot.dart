import 'startwith_stream_transformer.dart';

class Snapshot {
  final Function close;
  final Function(Snapshot) _renew;
  final String query;
  final String key;
  Map<String, dynamic> variables;

  dynamic value = double.infinity;

  Stream _stream;

  Stream get stream => _stream;

  Snapshot(this.key, this.query, this.variables, Stream streamInit, this.close,
      this._renew) {
    _stream = streamInit
        .map((v) {
          value = v;
          return v;
        })
        .transform(StartWithStreamTransformer(value))
        .where((v) => v != double.infinity);
  }

  changeVariable(Map<String, dynamic> v) {
    variables = v;
    _renew(this);
  }
}
