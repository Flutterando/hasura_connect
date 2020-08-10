import 'package:hasura_connect/src/core/interceptors/log_interceptor.dart';
import 'package:hasura_connect/src/di/injection.dart';
import 'package:hasura_connect/src/di/module.dart';
import 'package:hasura_connect/src/domain/entities/snapshot.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/external/websocket_connector.dart';
import 'package:hasura_connect/src/presenter/hasura_connect_base.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:websocket/websocket.dart';

import '../utils/client_response.dart';

class ClientMock extends Mock implements http.Client {}

class WrapperMock extends Mock implements WebSocketWrapper {}

class WebSocketMock extends Mock implements WebSocket {}

void main() {
  HasuraConnect connect;
  final client = ClientMock();
  final wrapper = WrapperMock();

  setUp(() {
    connect = HasuraConnect('https://fake-hasura.com',
        interceptors: [LogInterceptor()]);
    when(client.post(
      any,
      body: anyNamed('body'),
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response(stringJsonReponse, 200));

    when(wrapper.connect(any)).thenAnswer((_) async => WebSocketMock());
    cleanModule();
    startModule(() => client, wrapper);
  });

  tearDownAll(() {
    connect.disconnect();
  });

  group('Query | ', () {
    test('should execute query', () {
      expect(connect.query('query'), completes);
    });

    test('should execute with error', () {
      expect(connect.query('mutation'), throwsA(isA<HasuraError>()));
    });
  });

  group('Mutation | ', () {
    test('should execute', () {
      expect(connect.mutation('mutation'), completes);
    });

    test('should execute with error', () {
      expect(connect.mutation('query'), throwsA(isA<HasuraError>()));
    });
  });

  group('Subscription | ', () {
    test('should return Snapshot and Connect to Websocket', () async {
      final snapshot = await connect.subscription('subscription');
      expect(snapshot, isA<Snapshot>());
      final snapshot2 = await connect.subscription('subscription');
      expect(snapshot2 == snapshot, true);
      await snapshot.close();
      await snapshot2.close();
    });

    test('should execute with error', () {
      expect(connect.subscription('query'), throwsA(isA<HasuraError>()));
    });
  });
}
