import 'package:hasura_connect/src/core/interceptors/interceptor.dart';
import 'package:hasura_connect/src/core/interceptors/interceptor_executor.dart';
import 'package:hasura_connect/src/domain/entities/snapshot.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/presenter/hasura_connect_base.dart';
import 'package:test/test.dart';

void main() async {
  final request = Request(url: '', query: Query(document: 'query'));
  final response = Response();
  final error = HasuraRequestError(
    'test',
    null,
    request: Request(
      url: '',
      query: Query(document: ''),
    ),
  );

  test('should return same object if interceptor list be empty or null', () {
    var exec = InterceptorExecutor(null);
    final resolver = ClientResolver.request(request);
    expect(exec(resolver), completion(request));
    exec = InterceptorExecutor([]);
    expect(exec(resolver), completion(request));
  });

  group('onRequest || ', () {
    test('should exec interceptor request', () async {
      final exec = InterceptorExecutor(
          [InterceptorMock(onRequestF: (r) async => r.copyWith(url: 'test'))]);
      final resolver = ClientResolver.request(request);
      final result = await exec(resolver);
      expect(result, isA<Request>());
      expect(result.url, 'test');
    });

    test('should exec interceptor returning other type', () async {
      final exec = InterceptorExecutor(
          [InterceptorMock(onRequestF: (r) async => Response())]);
      final resolver = ClientResolver.request(request);
      final result = await exec(resolver);
      expect(result, isA<Response>());
    });
    test('should exec interceptor throw InterceptorError', () async {
      final exec = InterceptorExecutor(
          [InterceptorMock(onRequestF: (r) async => throw Exception('error'))]);
      final resolver = ClientResolver.request(request);
      expect(exec(resolver), throwsA(isA<InterceptorError>()));
    });
  });
  group('onResponse || ', () {
    test('should exec interceptor ', () async {
      final exec = InterceptorExecutor(
          [InterceptorMock(onResponseF: (r) async => Response(statusCode: 1))]);
      final resolver = ClientResolver.response(response);
      final result = await exec(resolver);
      expect(result, isA<Response>());
      expect(result.statusCode, 1);
    });

    test('should exec interceptor returning other type', () async {
      final exec = InterceptorExecutor([
        InterceptorMock(
          onResponseF: (r) async => HasuraRequestError(
            'test',
            null,
            request: Request(
              url: '',
              query: Query(document: ''),
            ),
          ),
        )
      ]);
      final resolver = ClientResolver.response(response);
      final result = await exec(resolver);
      expect(result, isA<HasuraRequestError>());
    });

    test('should exec interceptor throw error if return type Request',
        () async {
      final exec = InterceptorExecutor(
          [InterceptorMock(onResponseF: (r) async => request)]);
      final resolver = ClientResolver.response(response);
      expect(exec(resolver), throwsA(isA<InterceptorError>()));
    });

    test('should exec interceptor throw InterceptorError', () async {
      final exec = InterceptorExecutor([
        InterceptorMock(onResponseF: (r) async => throw Exception('error'))
      ]);
      final resolver = ClientResolver.response(response);
      expect(exec(resolver), throwsA(isA<InterceptorError>()));
    });
  });

  group('onError || ', () {
    test('should exec interceptor ', () async {
      final exec =
          InterceptorExecutor([InterceptorMock(onErrorF: (r) async => error)]);
      final resolver = ClientResolver.error(error);
      final result = await exec(resolver);
      expect(result, isA<HasuraError>());
    });

    test('should exec interceptor returning other type', () async {
      final exec = InterceptorExecutor(
          [InterceptorMock(onErrorF: (r) async => Response())]);
      final resolver = ClientResolver.error(error);
      final result = await exec(resolver);
      expect(result, isA<Response>());
    });

    test('should exec interceptor throw error if return type Request',
        () async {
      final exec = InterceptorExecutor(
          [InterceptorMock(onErrorF: (r) async => request)]);
      final resolver = ClientResolver.error(error);
      expect(exec(resolver), throwsA(isA<InterceptorError>()));
    });

    test('should exec interceptor throw InterceptorError', () async {
      final exec = InterceptorExecutor(
          [InterceptorMock(onErrorF: (r) async => throw Exception('error'))]);
      final resolver = ClientResolver.error(error);
      expect(exec(resolver), throwsA(isA<InterceptorError>()));
    });
  });

  test('onSubscription || should return error after fail', () {
    var exec = InterceptorExecutor([InterceptorMock()]);
    expect(
        exec.onSubscription(request, null), throwsA(isA<InterceptorError>()));
  });
  test('onConnected || should return error after fail', () {
    var exec = InterceptorExecutor([InterceptorMock()]);
    expect(exec.onConnected(null), throwsA(isA<InterceptorError>()));
  });
  test('onTryAgain || should return error after fail', () {
    var exec = InterceptorExecutor([InterceptorMock()]);
    expect(exec.onTryAgain(null), throwsA(isA<InterceptorError>()));
  });
  test('onDisconnect || should return error after fail', () {
    var exec = InterceptorExecutor([InterceptorMock()]);
    expect(exec.onDisconnect(), throwsA(isA<InterceptorError>()));
  });
}

class InterceptorMock extends Interceptor {
  final Future Function(HasuraError error) onErrorF;
  final Future Function(Request request) onRequestF;
  final Future Function(Response response) onResponseF;
  final Future<void> Function(HasuraConnect connect) onConnectedF;
  final Future<void> Function(HasuraConnect connect) onTryAgainF;
  final Future<void> Function() onDisconnectedF;
  final Future<void> Function(Request connect, Snapshot snapshot)
      onSubscriptionF;

  InterceptorMock(
      {this.onConnectedF,
      this.onTryAgainF,
      this.onDisconnectedF,
      this.onSubscriptionF,
      this.onErrorF,
      this.onRequestF,
      this.onResponseF});
  @override
  Future onError(HasuraError error) => onErrorF(error);

  @override
  Future onRequest(Request request) => onRequestF(request);

  @override
  Future onResponse(Response response) => onResponseF(response);

  @override
  Future<void> onConnected(HasuraConnect connect) => onConnectedF(connect);

  @override
  Future<void> onDisconnected() => onDisconnectedF();

  @override
  Future<void> onSubscription(Request connect, Snapshot snapshot) =>
      onSubscriptionF(connect, snapshot);

  @override
  Future<void> onTryAgain(HasuraConnect connect) => onTryAgainF(connect);
}
