import 'package:dart_websocket/websocket.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/infra/datasources/connector_datasource.dart';

///Class [WebsocketConnector] implements the interface [ConnectorDatasource]
///implements the [websocketConnector] method which is responsible for
///connect the websocket
///in case of error, throws a [ConnectionError]
class WebsocketConnector implements ConnectorDatasource {
  ///Variable [wrapper] type [WebSocketWrapper]
  final WebSocketWrapper? wrapper;

  ///[WebsocketConnector] constructor
  WebsocketConnector(this.wrapper);

  @override
  Future<Connector> websocketConnector(String url) async {
    try {
      final _wrapper = wrapper ?? _WebSocketWrapper();
      final _channelPromisse = await _wrapper
          .connect(url.replaceFirst('https', 'wss').replaceFirst('http', 'ws'));
      return Connector(
        _channelPromisse.stream,
        add: _channelPromisse.addUtf8Text,
        close: _channelPromisse.close,
        closeCodeFunction: () => _channelPromisse.closeCode ?? -1,
        done: _channelPromisse.done,
      );
    } catch (e) {
      throw ConnectionError(
        'Websocket Error',
        request: Request(
          url: url,
          query: const Query(document: ''),
        ),
      );
    }
  }
}

///The [WebSocketWrapper] class is an abstract class acting as
///an interface.
abstract class WebSocketWrapper {
  ///Method [connect] signature
  Future<WebSocket> connect(String url);
}

class _WebSocketWrapper implements WebSocketWrapper {
  @override
  Future<WebSocket> connect(String url) {
    return WebSocket.connect(
      url,
      protocols: ['graphql-ws'],
    );
  }
}
