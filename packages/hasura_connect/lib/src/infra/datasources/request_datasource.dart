import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/models/request.dart';

///The [RequestDatasource] class is an abstract class acting as
///an interface.
abstract class RequestDatasource {
  ///Method [post] signature

  Future<Response> post({required Request request});
}
