import 'package:hasura_connect/src/core/interceptors/interceptor.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/entities/snapshot.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/presenter/hasura_connect_base.dart';

///The class [InterceptorExecutor] is responsible for executing the Interceptors
class InterceptorExecutor {
  /// A list of [Interceptor] is created [interceptors]
  final List<Interceptor>? interceptors;

  /// Contructor for [InterceptorExecutor] receiving an [Interceptor] variable
  const InterceptorExecutor(this.interceptors);

  ///The mothd [call] receives a [ClientResolver] variable
  ///and checks if the [interceptors] is null or  empty, in this
  ///case, it returns the [resolver] value.
  ///If [interceptors] is not null, the method checks the [resolver] type,
  ///is it's a [Request] it returns the method [_executeRequestInterceptors]
  ///if it's a [Response] it returns the method [_executeResponseInterceptors]
  ///and if it's a [HasuraError] it returns the method
  /// [_executeHasuraErrorInterceptors]
  /// on default, it returns null.
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

  /// The method [onSubscription] receives [Request] and [Snapshot] variables
  ///and checks if the [interceptors] is null or empty, in this case
  ///returns void
  ///If [interceptors] is not null, the method opens a try/catch bloc
  ///For each interceptor in [interceptors] it calls [onSubscription]
  ///receiving the [request] and [snashot] variables
  /// if an error occurs, throws an [InterceptorError]

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

  ///The method [onConnected] receives a [HasuraConnect] and check if
  ///and checks if the [interceptors] is null or empty, in this case
  ///returns void
  ///If [interceptors] is not null, the method opens a try/catch bloc
  ///For each interceptor in [interceptors] it calls [onConnected]
  ///receiving the [connect] variable.
  ///if an error occurs, throws an [InterceptorError]
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

  ///The method [onTryAgain] receives a [HasuraConnect] and check if
  ///and checks if the [interceptors] is null or empty, in this case
  ///returns void
  ///If [interceptors] is not null, the method opens a try/catch bloc
  ///For each interceptor in [interceptors] it calls [onTryAgain]
  ///receiving the [connect] variable.
  ///if an error occurs, throws an [InterceptorError]
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

  ///The method [onDisconnect] checks if the [interceptors] is null or empty,
  /// in this case, returns void
  ///If [interceptors] is not null, the method opens a try/catch bloc
  ///For each interceptor in [interceptors] it calls onDisconnected from
  ///interceptor.
  ///if an error occurs, throws an [InterceptorError]
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
      var _request = request;
      for (final interceptor in interceptors ?? []) {
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
      var _response = response;
      for (final interceptor in interceptors ?? []) {
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
      var _error = error;
      for (final interceptor in interceptors ?? []) {
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

///The Class [ClientResolver] is responsible for receiving the type of request
class ClientResolver {
  /// the variable [value] is required in the request, response and error
  /// methods
  final dynamic value;

  /// the variable [type] is the type of the request made
  final Type type;

  /// the variable [connect] is required in the request, response and
  ///  error methods
  final HasuraConnect connect;

  /// The method [ClientResolver.request] is created for [type] [Request]
  const ClientResolver.request(this.value, this.connect) : type = Request;

  /// The method [ClientResolver.response] is created for [type] [Response]

  const ClientResolver.response(this.value, this.connect) : type = Response;

  /// The method [ClientResolver.error] is created for [type] [HasuraError]

  const ClientResolver.error(this.value, this.connect) : type = HasuraError;
}
