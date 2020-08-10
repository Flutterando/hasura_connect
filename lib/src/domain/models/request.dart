import 'package:meta/meta.dart';

import 'query.dart';

class Request {
  final Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final String url;
  final Query query;
  final RequestType type;

  Request(
      {@required this.url,
      @required this.query,
      this.type,
      Map<String, String> headers}) {
    assert(url != null);
    assert(query != null);
    if (headers != null) {
      this.headers.addAll(headers);
    }
  }

  Request copyWith({
    String url,
    Query query,
    RequestType type,
  }) {
    return Request(
      url: url ?? this.url,
      query: query ?? this.query,
      type: type ?? this.type,
    );
  }
}

enum RequestType { query, mutation, subscription }
