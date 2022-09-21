import 'package:collection/collection.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:meta/meta.dart';

///Class [Response] overrides the operator [==]
@immutable
class Response {
  /// variable [data] type [Map]
  final Map data;

  /// variable [statusCode] type [int]

  final int statusCode;

  /// variable [request] type [Request]

  final Request request;

  /// [Response] class constructor
  const Response({
    required this.data,
    required this.statusCode,
    required this.request,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other is Response &&
        mapEquals(other.data, data) &&
        other.statusCode == statusCode &&
        other.request == request;
  }

  @override
  int get hashCode => data.hashCode ^ statusCode.hashCode ^ request.hashCode;
}
