import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/models/request.dart';

abstract class RequestDatasource {
  Future<Response> post({required Request request});
}
