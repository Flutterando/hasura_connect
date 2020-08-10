import 'package:hasura_connect/src/domain/entities/response.dart';
import '../../domain/models/request.dart';

import '../../domain/entities/response.dart';

abstract class RequestDatasource {
  Future<Response> post({Request request});
}
