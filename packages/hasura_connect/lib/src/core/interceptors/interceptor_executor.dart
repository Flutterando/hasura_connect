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
        return _executeRequestInterceptors(resolver.value, resolver.connect);
      case Response:
        return _executeResponseInterceptors(resolver.value, resolver.connect);
      case HasuraError:
        return _executeHasuraErrorInterceptors(
          resolver.value,
          resolver.connect,
        );
      default:
        return null;
    }
  }

  Future<void> onSubscription(Request request, Snapshot snashot) async {
    if (interceptors == null || interceptors!.isEmpty) {
      return;
    }
    try {
      for (final interceptor in interceptors!) {
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
      for (final interceptor in interceptors!) {
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
      for (final interceptor in interceptors!) {
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
      for (final interceptor in interceptors!) {
        await interceptor.onDisconnected();
      }
    } catch (e) {
      throw InterceptorError(e.toString());
    }
  }

  Future<dynamic> _executeRequestInterceptors(
    Request request,
    HasuraConnect connect,
  ) async {
    try {
      Request _request = request;
      for (final Interceptor interceptor in interceptors ?? []) {
        final result = await interceptor.onRequest.call(_request, connect);
        if (result is Request) {
          _request = result;
        } else {
          return result;
        }
      }
      return _request;
    } catch (e) {
      throw InterceptorError(e.toString());
    }
  }

  Future<dynamic> _executeResponseInterceptors(
    Response response,
    HasuraConnect connect,
  ) async {
    try {
      Response _response = response;
      for (final Interceptor interceptor in interceptors ?? []) {
        final result = await interceptor.onResponse.call(_response, connect);
        if (result is Response) {
          _response = result;
        } else {
          if (result is Request) {
            throw InterceptorError("Don't return Request");
          } else {
            return result;
          }
        }
      }
      return _response;
    } catch (e) {
      throw InterceptorError(e.toString());
    }
  }

  Future<dynamic> _executeHasuraErrorInterceptors(
    HasuraError error,
    HasuraConnect connect,
  ) async {
    try {
      HasuraError _error = error;
      for (final Interceptor interceptor in interceptors ?? []) {
        final result = await interceptor.onError.call(_error, connect);
        if (result is HasuraError) {
          _error = result;
        } else {
          if (result is Request) {
            throw InterceptorError("Don't return Request");
          } else {
            return result;
          }
        }
      }
      return _error;
    } catch (e) {
      throw InterceptorError(e.toString());
    }
  }
}

class ClientResolver {
  final dynamic value;
  final Type type;
  final HasuraConnect connect;

  const ClientResolver.request(this.value, this.connect) : type = Request;

  const ClientResolver.response(this.value, this.connect) : type = Response;

  const ClientResolver.error(this.value, this.connect) : type = HasuraError;
}
