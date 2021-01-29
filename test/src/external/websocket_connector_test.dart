import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_connect/src/external/websocket_connector.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:dart_websocket/websocket.dart';

class WebSocketMock extends Mock implements WebSocket {}

class WrapperMock extends Mock implements WebSocketWrapper {}

void main() {
  final wrapper = WrapperMock();
  final websocket = WebSocketMock();
  final datasource = WebsocketConnector(wrapper);
  final url = 'http://test.com';

  when(websocket).calls(#stream).thenReturn(Stream.empty());
  when(websocket).calls(#addUtf8Text).thenReturn((List<int> list) {});
  when(websocket).calls(#close).thenReturn(([int? code, String? reason]) async => 0);
  when(websocket).calls(#closeCode).thenReturn(0);
  when(websocket).calls(#done).thenAnswer((_) async => 0);

  test('should execute post request and return Connector object', () async {
    when(wrapper).calls(#connect).thenAnswer((_) async => websocket);
    expect(datasource.websocketConnector(url), completes);
  });

  test('should return ConnectionError when WebSocketWrapper is fail', () async {
    when(wrapper).calls(#connect).thenThrow(Exception());
    expect(datasource.websocketConnector('request: tRequest'), throwsA(isA<ConnectionError>()));
  });
}
