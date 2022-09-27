import 'dart:async';
import 'dart:convert';

import 'package:hasura_connect/src/core/interceptors/interceptor.dart';
import 'package:hasura_connect/src/core/interceptors/interceptor_executor.dart';
import 'package:hasura_connect/src/core/utils/keys_generator.dart';
import 'package:hasura_connect/src/di/injection.dart' as sl;
import 'package:hasura_connect/src/di/module.dart';
import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/entities/snapshot.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/usecases/get_connector.dart';
import 'package:hasura_connect/src/domain/usecases/get_snapshot_subscription.dart';
import 'package:hasura_connect/src/domain/usecases/mutation_to_server.dart';
import 'package:hasura_connect/src/domain/usecases/query_to_server.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

///Base Class [HasuraConnect]
class HasuraConnect {
  @visibleForTesting

  /// [controller] variable receiving a StreamController.broadcast()
  final controller = StreamController.broadcast();

  /// [url] variable type [String]
  final String url;
  @visibleForTesting

  /// [snapmap] variable type [Map]
  final Map<String, Snapshot> snapmap = {};
  final KeyGenerator _keyGenerator = KeyGenerator();
  late InterceptorExecutor _interceptorExecutor;
  bool _isConnected = false;
  bool _disconnectionFlag = false;
  final _init = {
    'payload': {
      'headers': {'content-type': 'application/json'}
    },
    'type': 'connection_init'
  };

  ///[isConnected] variable type [bool]

  bool get isConnected => _isConnected;
  int _numbersOfConnectionAttempts = 0;

  Connector? _connector;

  late StreamSubscription _subscription;

  ///[reconnectionAttempt] variable type [int]

  final int? reconnectionAttempt;

  ///[headers] variable type [Map]

  final Map<String, String>? headers;

  /// [HasuraConnect] constructor
  HasuraConnect(
    this.url, {
    this.reconnectionAttempt,
    List<Interceptor>? interceptors,
    this.headers,
    http.Client Function()? httpClientFactory,
  }) {
    startModule(httpClientFactory);
    _interceptorExecutor = InterceptorExecutor(interceptors);

    _subscription = controller.stream
        .where((data) => data is Map)
        .map((data) => data as Map)
        .where((data) => data.containsKey('id'))
        .where((data) => snapmap.containsKey(data['id']))
        .listen(rootStreamListener);
  }

  ///Method [rootStreamListener]
  ///Receives a [data] and creates a [Snapshot]
  @visibleForTesting
  void rootStreamListener(dynamic data) {
    final snapshot = snapmap[data['id']];
    if (snapshot == null) return;

    if (data['type'] == 'data') {
      snapshot.add(data['payload']);
    } else if (data['type'] == 'error') {
      if ((data['payload'] as Map).containsKey('errors')) {
        snapshot.addError(
          HasuraRequestError.fromJson(
            data['payload']['errors'][0],
            request: Request(
              url: '',
              query: const Query(document: ''),
            ),
          ),
        );
      } else {
        snapshot.addError(
          HasuraRequestError.fromJson(
            data['payload'],
            request: Request(
              url: '',
              query: const Query(document: ''),
            ),
          ),
        );
      }
    }
  }

  ///Execute a Query from a Document
  Future query(
    String document, {
    String? key,
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
  }) async {
    final _key = key ?? _keyGenerator.generateBase(document);
    return executeQuery(
      Query(
        key: _key,
        headers: headers,
        document: document.trimLeft(),
        variables: variables,
      ),
    );
  }

///Execute a Query
///the method receives a type [Query] value
  Future executeQuery(Query query) async {
///Get the query to server using hasura injection
    final usecase = sl.get<QueryToServer>();

///Receive a headers map
    final _headers = Map<String, String>.from(headers ?? {});

///If the headers from the [query] received are different from null
///the header map will add all the [query] headers
    if (query.headers != null) {
      _headers.addAll(query.headers!);
    }
///A request type request is created
    var request = Request(
      headers: _headers,
      type: RequestType.query,
      url: url,
      query: query,
    );
///[interceptedValue] receives the value from a [ClientResolver] request

    final interceptedValue = await _interceptorExecutor(
      ClientResolver.request(request, this),
    );

/// if the [interceptedValue] is a [Response], returns the interceptedValue
/// if the [interceptedValue] is a [HasuraError], returns the interceptedValue
/// else, the request will be the [interceptedValue]
    if (interceptedValue is Response) {
      return interceptedValue;
    } else if (interceptedValue is HasuraError) {
      throw interceptedValue;
    } else {
      request = interceptedValue;
    }

///The [result] will receive the data from an interceptError or 
///interceptResponse
    final result = await usecase(request: request);
    return (await result.fold(_interceptError, _interceptResponse)).data;
  }

///Intercepts the response when a [HasuraError] occurs
  Future<Response> _interceptError(HasuraError error) async {
///Receives the intercepted value from a [ClientResolver] error

    final interceptedValue = await _interceptorExecutor(
      ClientResolver.error(error, this),
    );
///if the intercepted value is a [Response], return the value
///else, will throw the intercepted value
    if (interceptedValue is Response) {
      return interceptedValue;
    } else {
      throw interceptedValue;
    }
  }

///Intercepts the reponse when a [Response] occurs
  Future<Response> _interceptResponse(Response response) async {
///Receives the intercepted value from a [ClientResolver] response
    final interceptedValue = await _interceptorExecutor(
      ClientResolver.response(response, this),
    );
///if the intercept value is a [Response], returns the intercepted value
///else, throws the intercepted value
    if (interceptedValue is Response) {
      return interceptedValue;
    } else {
      throw interceptedValue;
    }
  }

  ///Execute a Mutation from a Document
  Future mutation(
    String document, {
    Map<String, dynamic>? variables,
    bool tryAgain = true,
    String? key,
    Map<String, String>? headers,
  }) async {
    final _key = key ?? _keyGenerator.randomString(15);

    return executeMutation(
      Query(
        key: _key,
        headers: headers,
        document: document.trimLeft(),
        variables: variables,
      ),
    );
  }

  ///Execute a Mutation from a Query
  Future executeMutation(Query query) async {
    final usecase = sl.get<MutationToServer>();

    final _headers = Map<String, String>.from(headers ?? {});
    if (query.headers != null) {
      _headers.addAll(query.headers!);
    }

    var request = Request(
      headers: _headers,
      type: RequestType.mutation,
      url: url,
      query: query,
    );

    final interceptedValue = await _interceptorExecutor(
      ClientResolver.request(request, this),
    );

    if (interceptedValue is Response) {
      return interceptedValue;
    } else if (interceptedValue is HasuraError) {
      throw interceptedValue;
    } else {
      request = interceptedValue;
    }

    final result = await usecase(request: request);
    return (await result.fold(_interceptError, _interceptResponse)).data;
  }

  ///Execute a Subscription from a Document
  Future<Snapshot> subscription(
    String document, {
    String? key,
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
  }) async {
    final _document = document.trim();
    final _key = key ?? _keyGenerator.generateBase(document);

    return executeSubscription(
      Query(
        key: _key,
        headers: headers,
        document: _document,
        variables: variables,
      ),
    );
  }

  ///Execute a Subscription from a Query
  Future<Snapshot> executeSubscription(Query query) async {
    Snapshot snapshot;
    if (snapmap.containsKey(query.key)) {
      return snapmap[query.key]!;
    } else {
      final usecase = sl.get<GetSnapshotSubscription>();
      final request = Request(
        url: url,
        type: RequestType.subscription,
        query: query,
      );
      final result = usecase(
        closeConnection: _removeSnapshot,
        changeVariables: _changeVariables,
        request: request,
      );
      snapshot = result.fold((l) => throw l, (s) => s);
      snapmap[query.key!] = snapshot;
      await _interceptorExecutor.onSubscription(request, snapshot);
    }

    if (snapmap.keys.isNotEmpty && !_isConnected) {
      // ignore: unawaited_futures
      _connect();
      await Future.delayed(const Duration(milliseconds: 500));
    } else if (_isConnected) {
      final input = querySubscription(snapshot.query);
      sendToWebSocketServer(input);
    }
    return snapshot;
  }
///Removes the snapshot
  void _removeSnapshot(Snapshot snapshot) {
    final stop = {'id': snapshot.query.key, 'type': 'stop'};
///removes the snapshot from [snapmap]
    snapmap.remove(snapshot.query.key);
///if connected, send the stop do the web socket server as json
///if the keys in [snapmap] are empty, disconnects
    if (isConnected) sendToWebSocketServer(jsonEncode(stop));
    if (snapmap.keys.isEmpty) disconnect();
  }

  ///Change the variables in a snapshot
  Future _changeVariables(Snapshot snapshot) async {
    final stop = {'id': snapshot.query.key, 'type': 'stop'};
  ///if connected, send to the web socketw server a stop request as json
  ///is connected, send to the web socketw server a query subscription with
  ///the snapshot query
    if (isConnected) sendToWebSocketServer(jsonEncode(stop));
    if (isConnected) sendToWebSocketServer(querySubscription(snapshot.query));
  }

  ///Method [sendToWebSocketServer]
  ///Receives an [input], verifies if [_connector] is different from
  ///null, in this case, will add into the [_connector] the [input]
  @visibleForTesting
  void sendToWebSocketServer(String input) {
    if (_connector != null) {
      _connector!.add!(utf8.encode(input));
    }
  }

///Renew the connector in case of null
  Future<void> _renewConnector() async {
///if conector is null, get the connector from it's usecase
///receives the result, set the connector with the result
///if it returns a error, throw the error, otherwise
///returns the connector
    if (_connector == null) {
      final usecase = sl.get<GetConnector>();
      final result = await usecase(url);
      _connector = result.fold((l) => throw l, (c) => c);
    }
  }
///Completes the connection
  Future<void> _connect() async {
    await _renewConnector();
///if the connector is null, returns the method, else
    if (_connector == null) {
      return;
    }
    final connector = _connector!;
    _disconnectionFlag = false;
/// if the reconnection attempt is different from null or bigger
///than 0, checks the number of connection attempts
    if (reconnectionAttempt != null && reconnectionAttempt! > 0) {
/// if the number of connection attempts is bigger or equal to reconnection 
/// attempts, is connected is false, disconnects and set the number of
/// connection attempts to 0, otherwise, add more one number of connection
/// attempts
      if (_numbersOfConnectionAttempts >= reconnectionAttempt!) {
        // ignore: avoid_print
        print('maximum connection attempt numbers reached');
        _isConnected = false;
        // ignore: unawaited_futures
        disconnect();
        _numbersOfConnectionAttempts = 0;
        return;
      }
      _numbersOfConnectionAttempts++;
    }

    final request = Request(
      url: url,
      headers: headers,
      type: RequestType.subscription,
      query: const Query(key: 'key', document: 'document'),
    );

    final interceptedValue = await _interceptorExecutor(
      ClientResolver.request(request, this),
    );

    try {
///if the intercepted value is a [Request], add to the request
///header the intercepted value headers, is the value is a
///[HasuraError], throws the intercepted value
      if (interceptedValue is Request) {
        request.headers.addAll(interceptedValue.headers);
      } else if (interceptedValue is HasuraError) {
        throw interceptedValue;
      }
///Send a map with the payload value to init the web socket server
      final subscriptionStream =
          connector.map<Map>(jsonDecode).listen(normalizeStreamValue);
      (_init['payload']! as Map)['headers'] = request.headers;
      sendToWebSocketServer(jsonEncode(_init));
      // ignore: avoid_print
      subscriptionStream.onError(print);
///Await the connector finish
      await connector.done;
///Cancels the subscription stream
      await subscriptionStream.cancel();
///Sets the variable as false
      _isConnected = false;
///the disconnection flag is equal to false, return the method
///is the try/catch receives an error, check if the disconnection flag is equal to false
///returns the methods, otherwise, connects
      if (_disconnectionFlag) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 3000));
      await _connect();
    } catch (e) {
      if (_disconnectionFlag == false) {
        return;
      }
      await _connect();
    }
  }

  ///Method [querySubscription]
  ///receives a [query] and convert it to json format
  @visibleForTesting
  String querySubscription(Query query) {
    return jsonEncode({
      'id': query.key,
      'payload': {
        'query': query.document,
        'variables': query.variables,
      },
      'type': 'start'
    });
  }

  ///Method [normalizeStreamValue]
  ///Receives a [data] and check the next steps depending on
  ///the [data] values
  @visibleForTesting
  Future<void> normalizeStreamValue(Map data) async {
    if (data['type'] == 'data' || data['type'] == 'error') {
      controller.add(data);
    } else if (data['type'] == 'connection_ack') {
      await _interceptorExecutor.onConnected(this);
      _numbersOfConnectionAttempts = 0;
      _isConnected = true;
      for (final snap in snapmap.values) {
        sendToWebSocketServer(querySubscription(snap.query));
      }
    } else if (data['type'] == 'connection_error') {
      await Future.delayed(const Duration(seconds: 2));
      await _interceptorExecutor.onTryAgain(this);
      sendToWebSocketServer(jsonEncode(_init));
    }
  }

  ///Disconect from Hasura
  Future<void> disconnect() async {
    if (_disconnectionFlag) {
      return;
    }
    _disconnectionFlag = true;
    final keys = List<String>.from(snapmap.keys);
    for (final key in keys) {
      snapmap[key]?.close();
    }
    snapmap.clear();
    final disconect = {'type': 'connection_terminate'};
    if (_isConnected) {
      sendToWebSocketServer(jsonEncode(disconect));
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (_connector?.closeCode != null) {
      await _connector?.close?.call();
    }
    await _interceptorExecutor.onDisconnect();
    _connector = null;
  }

  ///Method [dispose]
  ///Closes the [controller],cancels the [_subscription] and [disconnect] from
  ///Hasura
  @mustCallSuper
  Future dispose() async {
    await controller.close();
    await _subscription.cancel();
    await disconnect();
  }
}
