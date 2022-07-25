import 'package:collection/collection.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_connect/src/domain/models/request.dart';

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
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return o is Response &&
        mapEquals(o.data, data) &&
        o.statusCode == statusCode &&
        o.request == request;
  }

  @override
  int get hashCode => data.hashCode ^ statusCode.hashCode ^ request.hashCode;
}
