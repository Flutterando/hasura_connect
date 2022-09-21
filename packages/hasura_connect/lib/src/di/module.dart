import 'package:hasura_connect/src/di/injection.dart' as sl;
import 'package:hasura_connect/src/domain/usecases/get_connector.dart';
import 'package:hasura_connect/src/domain/usecases/get_snapshot_subscription.dart';
import 'package:hasura_connect/src/domain/usecases/mutation_to_server.dart';
import 'package:hasura_connect/src/domain/usecases/query_to_server.dart';
import 'package:hasura_connect/src/external/post_http_request.dart';
import 'package:hasura_connect/src/external/websocket_connector.dart';
import 'package:hasura_connect/src/infra/repositories/connector_repository.dart';
import 'package:hasura_connect/src/infra/repositories/request_repository.dart';
import 'package:http/http.dart';

///The method [startModule] receives a [Client] and a [WebSocketWrapper].
///It's responsible for starting the modules for external, repository and
/// usecases
void startModule([Client Function()? client, WebSocketWrapper? wrapper]) {
  //external
  sl.register(client ?? () => Client());
  sl.register(wrapper);
  sl.register(WebsocketConnector(sl.get()));
  sl.register(PostHttpRequest(sl.get()));

  //repository
  sl.register(ConnectorRepositoryImpl(datasource: sl.get()));
  sl.register(RequestRepositoryImpl(datasource: sl.get()));

  //usecases
  sl.register(QueryToServerImpl(sl.get()));
  sl.register(MutationToServerImpl(sl.get()));
  sl.register(GetConnectorImpl(sl.get()));
  sl.register(GetSnapshotSubscriptionImpl());
}
