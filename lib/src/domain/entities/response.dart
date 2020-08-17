import '../models/request.dart';

class Response {
  final Map data;
  final int statusCode;
  final Request request;

  const Response({this.data, this.statusCode, this.request});
}
