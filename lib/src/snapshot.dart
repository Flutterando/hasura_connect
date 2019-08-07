
import 'startwith_stream_transformer.dart';

class Snapshot {
  final Stream _streamInit;
  final Function close;
  final String document;
  dynamic value = double.infinity;

  Stream get stream => _streamInit.map((v) {
    value = v;
    return v;
  }).transform(StartWithStreamTransformer(value)).where((v) => v != double.infinity);

  Snapshot(this.document, this._streamInit, this.close);
}