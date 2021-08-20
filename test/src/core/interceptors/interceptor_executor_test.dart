import 'package:hasura_connect/src/core/interceptors/interceptor.dart';
import 'package:hasura_connect/src/core/interceptors/interceptor_executor.dart';
import 'package:hasura_connect/src/domain/entities/snapshot.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/presenter/hasura_connect_base.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class ResponseMock extends Mock implements Response {}

class SnapshotMock extends Mock implements Snapshot {}

class HasuraConnectMock extends Mock implements HasuraConnect {}

void main() async {
  final request = Request(url: '', query: Query(document: 'query'));
  final response = ResponseMock();
  final error = HasuraRequestError(
    'test',
    null,
    request: Request(
      url: '',
      query: Query(document: ''),
    ),
  );

  tearDown(() {
    reset(response);
  });

  test('should return same object if interceptor list be empty or null', () {
    var exec = InterceptorExecutor(null);
    final resolver = ClientResolver.request(request);
    expect(exec(resolver), completion(request));
    exec = InterceptorExecutor([]);
    expect(exec(resolver), completion(request));
  });

  group('onRequest || ', () {
    test('should exec interceptor request', () async {
      final exec = InterceptorExecutor([InterceptorMock(onRequestF: (r) async => r.copyWith(url: 'test'))]);
      final resolver = ClientResolver.request(request);
      final result = await exec(resolver);
      expect(result, isA<Request>());
      expect(result.url, 'test');
    });

    test('should exec interceptor returning other type', () async {
      final exec = InterceptorExecutor([InterceptorMock(onRequestF: (r) async => response)]);
      final resolver = ClientResolver.request(request);
      final result = await exec(resolver);
      expect(result, isA<Response>());
    });
    test('should exec interceptor throw InterceptorError', () async {
      final exec = InterceptorExecutor([InterceptorMock(onRequestF: (r) async => throw Exception('error'))]);
      final resolver = ClientResolver.request(request);
      expect(exec(resolver), throwsA(isA<InterceptorError>()));
    });
  });
  group('onResponse || ', () {
    test('should exec interceptor ', () async {
      when(response).calls(#statusCode).thenReturn(1);
      final exec = InterceptorExecutor([InterceptorMock(onResponseF: (r) async => response)]);
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

    test('should exec interceptor throw error if return type Request', () async {
      final exec = InterceptorExecutor([InterceptorMock(onResponseF: (r) async => request)]);
      final resolver = ClientResolver.response(response);
      expect(exec(resolver), throwsA(isA<InterceptorError>()));
    });

    test('should exec interceptor throw InterceptorError', () async {
      final exec = InterceptorExecutor([InterceptorMock(onResponseF: (r) async => throw Exception('error'))]);
      final resolver = ClientResolver.response(response);
      expect(exec(resolver), throwsA(isA<InterceptorError>()));
    });
  });

  group('onError || ', () {
    test('should exec interceptor ', () async {
      final exec = InterceptorExecutor([InterceptorMock(onErrorF: (r) async => error)]);
      final resolver = ClientResolver.error(error);
      final result = await exec(resolver);
      expect(result, isA<HasuraError>());
    });

    test('should exec interceptor returning other type', () async {
      final exec = InterceptorExecutor([InterceptorMock(onErrorF: (r) async => response)]);
      final resolver = ClientResolver.error(error);
      final result = await exec(resolver);
      expect(result, isA<Response>());
    });

    test('should exec interceptor throw error if return type Request', () async {
      final exec = InterceptorExecutor([InterceptorMock(onErrorF: (r) async => request)]);
      final resolver = ClientResolver.error(error);
      expect(exec(resolver), throwsA(isA<InterceptorError>()));
    });

    test('should exec interceptor throw InterceptorError', () async {
      final exec = InterceptorExecutor([InterceptorMock(onErrorF: (r) async => throw Exception('error'))]);
      final resolver = ClientResolver.error(error);
      expect(exec(resolver), throwsA(isA<InterceptorError>()));
    });
  });

  group('interceptors | ', () {
    test('onSubscription || should return error after fail', () {
      var exec = InterceptorExecutor([InterceptorMock(onSubscriptionF: (connect, snapshot) => Future.error('error'))]);
      expect(exec.onSubscription(request, SnapshotMock()), throwsA(isA<InterceptorError>()));
    });
    test('onConnected || should return error after fail', () {
      var exec = InterceptorExecutor([InterceptorMock(onConnectedF: (connect) => Future.error('error'))]);
      expect(exec.onConnected(HasuraConnectMock()), throwsA(isA<InterceptorError>()));
    });
    test('onTryAgain || should return error after fail', () {
      var exec = InterceptorExecutor([InterceptorMock(onTryAgainF: (connect) => Future.error('error'))]);
      expect(exec.onTryAgain(HasuraConnectMock()), throwsA(isA<InterceptorError>()));
    });
    test('onDisconnect || should return error after fail', () {
      var exec = InterceptorExecutor([InterceptorMock(onDisconnectedF: () => Future.error('error'))]);
      expect(exec.onDisconnect(), throwsA(isA<InterceptorError>()));
    });
  });
}

class InterceptorMock extends Interceptor {
  final Future Function(HasuraError error)? onErrorF;
  final Future Function(Request request)? onRequestF;
  final Future Function(Response response)? onResponseF;
  final Future<void> Function(HasuraConnect connect)? onConnectedF;
  final Future<void> Function(HasuraConnect connect)? onTryAgainF;
  final Future<void> Function()? onDisconnectedF;
  final Future<void> Function(Request connect, Snapshot snapshot)? onSubscriptionF;

  InterceptorMock(
      {this.onConnectedF, this.onTryAgainF, this.onDisconnectedF, this.onSubscriptionF, this.onErrorF, this.onRequestF, this.onResponseF});
  @override
  Future<dynamic>? onError(HasuraError error) => onErrorF?.call(error);

  @override
  Future? onRequest(Request request) => onRequestF?.call(request);

  @override
  Future? onResponse(Response response) => onResponseF?.call(response);

  @override
  Future<void>? onConnected(HasuraConnect connect) => onConnectedF?.call(connect);

  @override
  Future<void>? onDisconnected() => onDisconnectedF?.call();

  @override
  Future<void>? onSubscription(Request connect, Snapshot snapshot) => onSubscriptionF?.call(connect, snapshot);

  @override
  Future<void>? onTryAgain(HasuraConnect connect) => onTryAgainF?.call(connect);
}
