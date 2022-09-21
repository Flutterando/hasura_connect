import 'package:hasura_cache_interceptor/src/services/storage_service_interface.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:uuid/uuid.dart';

///The class [CacheInterceptor] extends [InterceptorBase] and implements
/// [Interceptor]
class CacheInterceptor extends InterceptorBase implements Interceptor {
  /// The variable [namespaceKey] receives a const value and is used as
  /// the namespace in version 5 UUID
  static const namespaceKey = 'b34a217c-f439-50b1-b1c1-4e491a72d05f';
  final IStorageService _storage;

  ///[CacheInterceptor] constructor, receives a [IStorageService] variable.
  CacheInterceptor(this._storage);

  ///The method [clearAllCache] is responsible for cleaning all in storage 
  Future<void> clearAllCache() async => _storage.clear();

  @override
  Future onError(HasuraError error, HasuraConnect connect) async {
    var isConnectionError = [
      'Connection Rejected',
      'Websocket Error',
    ].contains(error.message);

    isConnectionError = isConnectionError ||
        error.message
            .contains('No address associated with hostname, errno = 7');

    final key = _generateKey(error.request);
    final containsCache = await _storage.containsKey(key);
    if (isConnectionError && containsCache) {
      final cachedData = await _storage.get(key);
      return Response(
        data: cachedData,
        statusCode: 500,
        request: error.request,
      );
    }
    return error;
  }

  @override
  Future onResponse(Response data, HasuraConnect connect) async {
    final key = _generateKey(data.request);
    await _storage.put(key, data.data);
    return data;
  }

  @override
  Future<void> onSubscription(Request request, Snapshot snapshot) async {
    final key = _generateKey(request);

    final containsCache = await _storage.containsKey(key);
    if (containsCache) {
      final cachedData = await _storage.get(key);
      snapshot.add(cachedData);
    }
    final subscription = snapshot.listen(
      (data) => _updateSubscriptionCache(key, data),
    );
    snapshot.listen((_) {}, onDone: subscription.cancel);
  }

  Future _updateSubscriptionCache(String key, dynamic data) async {
    final cachedData = await _storage.get(key);
    if (cachedData != data) {
      await _storage.put(key, data);
    }
    return data;
  }

  String _generateKey(Request request) {
    final keyIsNullOrEmpty =
        request.query.key == null || request.query.key!.isEmpty;
    final key = const Uuid().v5(
      namespaceKey,
      '${request.url}: ${keyIsNullOrEmpty ? request.query : request.query.key}',
    );
    return key;
  }
}
