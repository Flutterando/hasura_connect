import 'package:dartz/dartz.dart';

import '../entities/response.dart';
import '../errors/errors.dart';

import '../models/request.dart';

abstract class RequestRepository {
  Future<Either<HasuraError, Response>> sendRequest({Request request});
}
