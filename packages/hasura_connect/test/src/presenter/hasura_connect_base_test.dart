import 'package:dart_websocket/websocket.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_connect/src/di/injection.dart';
import 'package:hasura_connect/src/di/module.dart';
import 'package:hasura_connect/src/external/websocket_connector.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../utils/client_response.dart';

class ClientMock extends Mock implements http.Client {
  @override
  void close() {}
}

class WrapperMock extends Mock implements WebSocketWrapper {}

class WebSocketMock extends Mock implements WebSocket {}

void main() {
  late HasuraConnect connect;
  final client = ClientMock();
  final wrapper = WrapperMock();
  final websocket = WebSocketMock();
  when(() => websocket.stream).thenAnswer((invocation) => const Stream.empty());
  when(() => websocket.addUtf8Text([])).thenReturn((List<int> list) {});
  when(websocket.close).thenAnswer((_) => Future.value(0));
  when(() => websocket.closeCode).thenReturn(0);
  when(() => websocket.done).thenAnswer((_) async => 0);

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://fake-hasura.com'));
  });
  setUp(() {
    connect = HasuraConnect(
      'https://fake-hasura.com',
      interceptors: [LogInterceptor()],
    );
    when(
      () => client.post(
        any(),
        body: any(named: 'body'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer((_) async => http.Response(stringJsonReponse, 200));
    when(() => wrapper.connect(any())).thenAnswer((_) async => websocket);
    cleanModule();
    startModule(() => client, wrapper);
  });

  tearDownAll(() {
    connect.dispose();
  });
  group(
    HasuraConnect,
    () {
      test(
        'Should execute a query',
        () async {
           const documentMock ='query';

          final query = Query(
            key: 'sddddddd',
            headers: {'header1': '1', 'header2': '2'},
            document: documentMock.trim(),
            variables: {'variable1': '1', 'variable2': '2'},
          );
          expect(connect.executeQuery(query), completes);
        },
      );

      test(
        'Should throw and error when executing a query',
        () async {
           const documentMock ='error';

          final query = Query(
            key: 'sddddddd',
            headers: {'header1': '1', 'header2': '2'},
            document: documentMock.trim(),
            variables: {'variable1': '1', 'variable2': '2'},
          );
          expect(connect.executeQuery(query), throwsA(isA<HasuraError>()));
        },
      );

      test(
        'Should execute a mutation',
        () async {
           const documentMock ='mutation';

          final query = Query(
            key: 'sddddddd',
            headers: {'header1': '1', 'header2': '2'},
            document: documentMock.trim(),
            variables: {'variable1': '1', 'variable2': '2'},
          );
          expect(connect.executeMutation(query), completes);
        },
      );

      test(
        'Should throw and error when executing a mutation',
        () async {
           const documentMock ='error';

          final query = Query(
            key: 'sddddddd',
            headers: {'header1': '1', 'header2': '2'},
            document: documentMock.trim(),
            variables: {'variable1': '1', 'variable2': '2'},
          );
          expect(connect.executeMutation(query), throwsA(isA<HasuraError>()));
        },
      );

      test(
        'Should execute a subscription',
        () async {
           const documentMock ='subscription';

          final query = Query(
            key: 'sddddddd',
            headers: {'header1': '1', 'header2': '2'},
            document: documentMock.trim(),
            variables: {'variable1': '1', 'variable2': '2'},
          );
          expect(connect.executeSubscription(query), completes);
        },
      );

      test(
        'Should throw and error when executing a subscription',
        () async {
           const documentMock ='error';

          final query = Query(
            key: 'sddddddd',
            headers: {'header1': '1', 'header2': '2'},
            document: documentMock.trim(),
            variables: {'variable1': '1', 'variable2': '2'},
          );
          expect(connect.executeSubscription(query), throwsA(isA<HasuraError>()));
        },
      );
      
      test(
        'Should disconnect',
        () async {
          expect(connect.disconnect(), completes);
        },
      );
       test(
        'Should dispose',
        () async {
          expect(connect.dispose(), completes);
        },
      );
    },
  );
}
