import 'package:hasura_connect/src/di/injection.dart' as sl;
import 'package:hasura_connect/src/di/module.dart';
import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/usecases/mutation_to_server.dart';
import 'package:hasura_connect/src/domain/usecases/query_to_server.dart';
import 'package:hasura_connect/src/domain/usecases/get_connector.dart';
import 'package:hasura_connect/src/external/websocket_connector.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:dart_websocket/websocket.dart';

import '../utils/client_response.dart';

class ClientMock extends Mock implements http.Client {
  @override
  void close() {}
}

class WrapperMock extends Mock implements WebSocketWrapper {}

class WebSocketMock extends Mock implements WebSocket {}

void main() {
  final client = ClientMock();
  final wrapper = WrapperMock();
  final websocket = WebSocketMock();

  final url = 'https://hasura-fake.com';
  final tRequestQuery = Request(type: RequestType.query, url: url, query: Query(document: 'query', key: 'jfslfj'));
  final tRequestMutation = Request(type: RequestType.mutation, url: url, query: Query(document: 'mutation', key: 'jfslfj'));

  setUpAll(() {
    startModule(() => client, wrapper);
    when(client).calls(#post).thenAnswer((_) async => http.Response(stringJsonReponse, 200));

    when(wrapper).calls(#connect).thenAnswer((_) async => websocket);
    when(websocket).calls(#stream).thenReturn(Stream.empty());
    when(websocket).calls(#addUtf8Text).thenReturn((List<int> list) {});
    when(websocket).calls(#close).thenReturn(([int? code, String? reason]) async => 0);
    when(websocket).calls(#closeCode).thenReturn(0);
    when(websocket).calls(#done).thenAnswer((_) async => 0);
  });

  test('should execute usecase QueryToServer by DI', () async {
    final usecase = sl.get<QueryToServer>();
    final result = await usecase(request: tRequestQuery);
    expect(result.right, isA<Response>());
  });
  test('should execute usecase MutationToServer by DI', () async {
    final usecase = sl.get<MutationToServer>();
    final result = await usecase(request: tRequestMutation);
    expect(result.right, isA<Response>());
  });
  test('should execute usecase QueryToServer by DI', () async {
    final usecase = sl.get<GetConnector>();
    final result = await usecase('https://flutterando.com.br');
    expect(result.right, isA<Connector>());
  });
}
