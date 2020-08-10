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
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:websocket/websocket.dart';

import '../utils/client_response.dart';

class ClientMock extends Mock implements http.Client {}

class WrapperMock extends Mock implements WebSocketWrapper {}

class WebSocketMock extends Mock implements WebSocket {}

void main() {
  final client = ClientMock();
  final wrapper = WrapperMock();
  final url = 'https://hasura-fake.com';
  final tRequestQuery = Request(
      type: RequestType.query,
      url: url,
      query: Query(document: 'query', key: 'jfslfj'));
  final tRequestMutation = Request(
      type: RequestType.mutation,
      url: url,
      query: Query(document: 'mutation', key: 'jfslfj'));

  setUpAll(() {
    startModule(client, wrapper);
    when(client.post(
      any,
      body: anyNamed('body'),
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response(stringJsonReponse, 200));

    when(wrapper.connect(any)).thenAnswer((_) async => WebSocketMock());
  });

  test('should execute usecase QueryToServer by DI', () async {
    final usecase = sl.get<QueryToServer>();
    final result = await usecase(request: tRequestQuery);
    expect(result | null, isA<Response>());
  });
  test('should execute usecase MutationToServer by DI', () async {
    final usecase = sl.get<MutationToServer>();
    final result = await usecase(request: tRequestMutation);
    expect(result | null, isA<Response>());
  });
  test('should execute usecase QueryToServer by DI', () async {
    final usecase = sl.get<GetConnector>();
    final result = await usecase('https://flutterando.com.br');
    expect(result | null, isA<Connector>());
  });
}
