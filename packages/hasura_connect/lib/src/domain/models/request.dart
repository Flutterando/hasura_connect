import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:meta/meta.dart';

///Class [Request]
/// a request object, overrides the [==] operator and the hashcode
/// usign the url, query and type hashcode
@immutable
class Request {
  ///variable [headers] setting the content type and accept for the
  ///request
  final Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  ///variable [url]
  final String url;

  ///variable [query]
  final Query query;

  ///variable [type]
  final RequestType type;

  /// [Request] class constructor
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

  ///[copyWith] will copy [Request] into a new object, changing the variable
  ///values
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

    return other is Request &&
        other.url == url &&
        other.query == query &&
        other.type == type;
  }

  @override
  int get hashCode => url.hashCode ^ query.hashCode ^ type.hashCode;
}

/// [RequestType] enum with the variables:
enum RequestType {
  /// [query],
  query,

  ///[mutation],
  mutation,

  ///[subscription] and
  subscription,

  ///[none]
  none,
}
