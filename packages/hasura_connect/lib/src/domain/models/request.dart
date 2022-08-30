import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:meta/meta.dart';

@immutable
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Request && other.url == url && other.query == query &&
    other.type == type;
  }

  @override
  int get hashCode => url.hashCode ^ query.hashCode ^ type.hashCode;
}

enum RequestType { query, mutation, subscription, none }
