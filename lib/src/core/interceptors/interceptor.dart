import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/entities/snapshot.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/presenter/hasura_connect_base.dart';

import '../../domain/models/request.dart';

abstract class Interceptor {
  Future onRequest(Request request);
  Future onResponse(Response data);
  Future onError(HasuraError request);
  Future<void> onSubscription(Request request, Snapshot snapshot);
  Future<void> onConnected(HasuraConnect connect);
  Future<void> onTryAgain(HasuraConnect connect);
  Future<void> onDisconnected();
}
