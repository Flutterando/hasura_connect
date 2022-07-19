// ignore_for_file: void_checks

import 'package:dart_websocket/websocket.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_connect/src/external/websocket_connector.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class WebSocketMock extends Mock implements WebSocket {}

class WrapperMock extends Mock implements WebSocketWrapper {}

void main() {
  final wrapper = WrapperMock();
  final websocket = WebSocketMock();
  final datasource = WebsocketConnector(wrapper);
  const url = 'http://test.com';

  when(() => websocket.stream).thenAnswer((_) => const Stream.empty());
  when(() => websocket.addUtf8Text([])).thenReturn((List<int> list) {});
  when(() => websocket.close()).thenAnswer((invocation) => Future.value(0));
  when(() => websocket.closeCode).thenReturn(0);
  when(() => websocket.done).thenAnswer((_) async => 0);

  test('should execute post request and return Connector object', () async {
    when(() => wrapper.connect(any())).thenAnswer((_) async => websocket);
    expect(datasource.websocketConnector(url), completes);
  });

  test('should return ConnectionError when WebSocketWrapper is fail', () async {
    when(() => wrapper.connect(any())).thenThrow(Exception());
    expect(datasource.websocketConnector('request: tRequest'), throwsA(isA<ConnectionError>()));
  });
}
