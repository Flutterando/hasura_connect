import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/entities/snapshot.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/presenter/hasura_connect_base.dart';

import '../../domain/models/request.dart';

abstract class Interceptor {
  Future<dynamic>? onRequest(Request request, HasuraConnect connect);
  Future<dynamic>? onResponse(Response data, HasuraConnect connect);
  Future<dynamic>? onError(HasuraError request, HasuraConnect connect);
  Future<void>? onSubscription(Request request, Snapshot snapshot);
  Future<void>? onConnected(HasuraConnect connect);
  Future<void>? onTryAgain(HasuraConnect connect);
  Future<void>? onDisconnected();
}

abstract class InterceptorBase extends Interceptor {
  @override
  Future<void> onConnected(HasuraConnect connect) async {}

  @override
  Future<void> onDisconnected() async {}

  @override
  Future onError(HasuraError error, HasuraConnect connect) async => error;

  @override
  Future onRequest(Request request, HasuraConnect connect) async => request;

  @override
  Future onResponse(Response data, HasuraConnect connect) async => data;

  @override
  Future<void> onSubscription(Request request, Snapshot snapshot) async {}

  @override
  Future<void> onTryAgain(HasuraConnect connect) async {}
}
