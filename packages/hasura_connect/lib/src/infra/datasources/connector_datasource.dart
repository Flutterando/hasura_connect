import 'package:hasura_connect/src/domain/entities/connector.dart';

///The [ConnectorDatasource] class is an abstract class acting as
///an interface.
abstract class ConnectorDatasource {
  ///Method [websocketConnector] signature

  Future<Connector> websocketConnector(String url);
}
