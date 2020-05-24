import 'package:hasura_connect/src/snapshot/snapshot.dart';

import '../../hasura_connect.dart';
import 'hasura_connect_base.dart';

abstract class HasuraConnect {
  ///[url] -> url to graph client
  ///[header] -> set header elements for request
  ///[token] -> change token jwt
  ///[reconnectionAttemp] -> Default is 0 = unlimited connection attempt;
  factory HasuraConnect(String url,
      {Future<String> Function(bool isError) token,
      LocalStorage Function() localStorageDelegate,
      Map<String, String> headers,
      int reconnectionAttempt = 0}) {
    return HasuraConnectBase(url,
        headers: headers,
        token: token,
        reconnectionAttemp: reconnectionAttempt,
        localStorageDelegate:
            localStorageDelegate ?? () => LocalStorageSharedPreferences());
  }

  bool get isConnected;

  Stream<bool> get isConnectedStream;

  Map<String, String> get headers;

  ///change function listener for token
  void changeToken(Future<String> Function(bool isError) token);

  ///add new header
  void addHeader(String key, String value);

  ///remove new header
  void removeHeader(String key);

  ///clear all headers
  void removeAllHeader();

  ///try to reconnect
  void reconnect();

    ///try to reconnect
  void disconnect();

  ///get [Snapshot] from Subscription connection
  Snapshot subscription(String query,
      {String key, Map<String, dynamic> variables});

  ///get cached query [Snapshot]
  Snapshot cachedQuery(String query,
      {String key, Map<String, dynamic> variables});

  ///exec query in Graphql Engine
  Future query(String doc, {Map<String, dynamic> variables});

  ///exec mutation in Graphql Engine
  Future mutation(String doc,
      {Map<String, dynamic> variables, bool tryAgain = true});
}
