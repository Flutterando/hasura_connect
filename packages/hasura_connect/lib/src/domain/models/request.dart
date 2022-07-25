import 'package:hasura_connect/src/domain/models/query.dart';

class Request {
  final Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final String url;
  final Query query;
  final RequestType type;

  Request({
    required this.url,
    required this.query,
    this.type = RequestType.none,
    Map<String, String>? headers,
  }) {
    if (headers != null) {
      this.headers.addAll(headers);
    }
  }

  Request copyWith({
    String? url,
    Query? query,
    RequestType? type,
  }) {
    return Request(
      url: url ?? this.url,
      query: query ?? this.query,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Request && o.url == url && o.query == query && o.type == type;
  }

  @override
  int get hashCode => url.hashCode ^ query.hashCode ^ type.hashCode;
}

enum RequestType { query, mutation, subscription, none }
