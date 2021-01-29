import '../models/request.dart';

class Response {
  final Map data;
  final int statusCode;
  final Request request;

  const Response({required this.data, required this.statusCode, required this.request});
}
