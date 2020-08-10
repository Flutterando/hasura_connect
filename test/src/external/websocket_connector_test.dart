import 'package:hasura_connect/src/external/websocket_connector.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:websocket/websocket.dart';

class WrapperMock extends Mock implements WebSocketWrapper {}

class WebSocketMock extends Mock implements WebSocket {}

void main() {
  final wrapper = WrapperMock();
  final datasource = WebsocketConnector(wrapper);

  test('should execute post request and return Connector object', () async {
    when(wrapper.connect(any)).thenAnswer((_) async => WebSocketMock());
    expect(datasource.websocketConnector('request: tRequest'), completes);
  });
}
