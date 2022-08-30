import 'package:collection/collection.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:meta/meta.dart';

@immutable
class Response {
  final Map data;
  final int statusCode;
  final Request request;

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
