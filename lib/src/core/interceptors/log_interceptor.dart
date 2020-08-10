import 'package:hasura_connect/src/core/interceptors/interceptor.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/entities/snapshot.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/presenter/hasura_connect_base.dart';

class LogInterceptor extends Interceptor {
  @override
  Future onError(HasuraError error) async {
    return error;
  }

  @override
  Future onRequest(Request request) async {
    return request;
  }

  @override
  Future onResponse(Response response) async {
    return response;
  }

  @override
  Future<void> onSubscription(Request request, Snapshot snapshot) async {}

  @override
  Future<void> onConnected(HasuraConnect connect) async {
    print('📡HASURA CONNECT📡');
  }

  @override
  Future<void> onDisconnected() async {
    print('HASURA DISCONNECTED');
  }

  @override
  Future<void> onTryAgain(HasuraConnect connect) async {
    print('hasura trying reconnect...');
  }
}
