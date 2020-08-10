import 'package:hasura_connect/src/domain/entities/connector.dart';

abstract class ConnectorDatasource {
  Future<Connector> websocketConnector(String url);
}
