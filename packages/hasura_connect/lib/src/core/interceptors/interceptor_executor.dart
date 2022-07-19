import 'package:hasura_connect/src/core/interceptors/interceptor.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/entities/snapshot.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/presenter/hasura_connect_base.dart';

class InterceptorExecutor {
  final List<Interceptor>? interceptors;

  const InterceptorExecutor(this.interceptors);

  Future<dynamic> call(ClientResolver resolver) async {
    if (interceptors == null || interceptors!.isEmpty) {
      return resolver.value;
    }

    switch (resolver.type) {
      case Request:
        return await _executeRequestInterceptors(
            resolver.value, resolver.connect);
      case Response:
        return await _executeResponseInterceptors(
            resolver.value, resolver.connect);
      case HasuraError:
        return await _executeHasuraErrorInterceptors(
            resolver.value, resolver.connect);
      default:
        return null;
    }
  }

  Future<void> onSubscription(Request request, Snapshot snashot) async {
    if (interceptors == null || interceptors!.isEmpty) {
      return;
    }
    try {
      for (var interceptor in interceptors!) {
        await interceptor.onSubscription(request, snashot);
      }
      return;
    } catch (e) {
      throw InterceptorError(e.toString());
    }
  }

  Future<void>? onConnected(HasuraConnect connect) async {
    if (interceptors == null || interceptors!.isEmpty) {
      return;
    }
    try {
      for (var interceptor in interceptors!) {
        await interceptor.onConnected(connect);
      }
    } catch (e) {
      throw InterceptorError(e.toString());
    }
  }

  Future<void>? onTryAgain(HasuraConnect connect) async {
    if (interceptors == null || interceptors!.isEmpty) {
      return;
    }
    try {
      for (var interceptor in interceptors!) {
        await interceptor.onTryAgain(connect);
      }
    } catch (e) {
      throw InterceptorError(e.toString());
    }
  }

  Future<void>? onDisconnect() async {
    if (interceptors == null || interceptors!.isEmpty) {
      return;
    }
    try {
      for (var interceptor in interceptors!) {
        await interceptor.onDisconnected();
      }
    } catch (e) {
      throw InterceptorError(e.toString());
    }
  }

  Future<dynamic> _executeRequestInterceptors(
      Request request, HasuraConnect connect) async {
    try {
      for (var interceptor in interceptors ?? []) {
        final result = await interceptor.onRequest?.call(request, connect);
        if (result is Request) {
          request = result;
        } else {
          return result;
        }
      }
      return request;
    } catch (e) {
      throw InterceptorError(e.toString());
    }
  }

  Future<dynamic> _executeResponseInterceptors(
      Response response, HasuraConnect connect) async {
    try {
      for (var interceptor in interceptors ?? []) {
        final result = await interceptor.onResponse?.call(response, connect);
        if (result is Response) {
          response = result;
        } else {
          if (result is Request) {
            throw InterceptorError('Don\'t return Request');
          } else {
            return result;
          }
        }
      }
      return response;
    } catch (e) {
      throw InterceptorError(e.toString());
    }
  }

  Future<dynamic> _executeHasuraErrorInterceptors(
      HasuraError error, HasuraConnect connect) async {
    try {
      for (var interceptor in interceptors ?? []) {
        final result = await interceptor.onError?.call(error, connect);
        if (result is HasuraError) {
          error = result;
        } else {
          if (result is Request) {
            throw InterceptorError('Don\'t return Request');
          } else {
            return result;
          }
        }
      }
      return error;
    } catch (e) {
      throw InterceptorError(e.toString());
    }
  }
}

class ClientResolver {
  final dynamic value;
  final Type type;
  final HasuraConnect connect;

  const ClientResolver._(this.value, this.type, this.connect);

  factory ClientResolver.request(Request value, HasuraConnect connect) {
    return ClientResolver._(value, Request, connect);
  }
  factory ClientResolver.response(Response value, HasuraConnect connect) {
    return ClientResolver._(value, Response, connect);
  }
  factory ClientResolver.error(HasuraError value, HasuraConnect connect) {
    return ClientResolver._(value, HasuraError, connect);
  }
}
