import 'startwith_stream_transformer.dart';

class Snapshot {
  final Function close;
  final String document;
  dynamic value = double.infinity;

  Stream stream;

  Snapshot(this.document, Stream streamInit, this.close) {
    stream = streamInit
        .map((v) {
          value = v;
          return v;
        })
        .transform(StartWithStreamTransformer(value))
        .where((v) => v != double.infinity);
  }
}
