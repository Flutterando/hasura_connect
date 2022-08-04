---
sidebar_position: 6
---

# Interceptors

This is a good strategy to control the flow of requests. With that we can create interceptors for logs or cache for example.
The community has already provided some interceptors for caching. Interceptors are highly customizable.

- [hive_cache_interceptor](https://pub.dev/packages/hive_cache_interceptor)
- [shared_preferences_cache_interceptor](https://pub.dev/packages/shared_preferences_cache_interceptor)
- [hasura_cache_interceptor](https://pub.dev/packages/hasura_cache_interceptor)

[View Hasura's official Authorization documentation](https://docs.hasura.io/1.0/graphql/manual/auth/index.html).

```dart
class TokenInterceptor extends Interceptor {
  final FirebaseAuth auth;
  TokenInterceptor(this.auth);

  @override
  Future<void> onConnected(HasuraConnect connect) {}

  @override
  Future<void> onDisconnected() {}

  @override
  Future onError(HasuraError request) async {
    return request;
  }

  @override
  Future<Request> onRequest(Request request) async {
    var user = await auth.currentUser();
    var token = await user.getIdToken(refresh: true);
    if (token != null) {
      try {
        request.headers["Authorization"] = "Bearer ${token.token}";
        return request;
      } catch (e) {
        return null;
      }
    } else {
      Modular.to.pushReplacementNamed("/login");
    }
  }

  @override
  Future onResponse(Response data) async {
    return data;
  }

  @override
  Future<void> onSubscription(Request request, Snapshot snapshot) {}

  @override
  Future<void> onTryAgain(HasuraConnect connect) {}
}
```

Or:

```dart
class TokenInterceptor extends InterceptorBase {
  final FirebaseAuth auth;
  TokenInterceptor(this.auth);

  @override
  Future<Request> onRequest(Request request) async {
    var user = await auth.currentUser();
    var token = await user.getIdToken(refresh: true);
    if (token != null) {
      try {
        request.headers["Authorization"] = "Bearer ${token.token}";
        return request;
      } catch (e) {
        return null;
      }
    } else {
      Modular.to.pushReplacementNamed("/login");
    }
  }
}
```

# INTERCEPTOR

Now you can intercept all requests, erros, subscritions.... all states of your hasura_connect connection.

- onConnected
- onDisconnected
- onError
- onRequest
- onResponse
- onSubscription
- onTryAgain
