import 'dart:async';
import 'dart:convert';

import 'package:hasura_connect/src/core/interceptors/interceptor.dart';
import 'package:hasura_connect/src/core/interceptors/interceptor_executor.dart';
import 'package:hasura_connect/src/core/utils/keys_generator.dart';
import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/usecases/get_connector.dart';
import 'package:hasura_connect/src/domain/usecases/get_snapshot_subscription.dart';
import 'package:hasura_connect/src/domain/usecases/mutation_to_server.dart';
import 'package:hasura_connect/src/domain/usecases/query_to_server.dart';

import '../domain/entities/snapshot.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import '../di/module.dart';
import '../di/injection.dart' as sl;

class HasuraConnect {
  @visibleForTesting
  final controller = StreamController.broadcast();
  final String url;
  @visibleForTesting
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

  bool get isConnected => _isConnected;
  int _numbersOfConnectionAttempts = 0;

  Connector? _connector;

  late StreamSubscription _subscription;
  final int? reconnectionAttempt;
  final Map<String, String>? headers;

  HasuraConnect(this.url, {this.reconnectionAttempt, List<Interceptor>? interceptors, this.headers, http.Client Function()? httpClientFactory}) {
    startModule(httpClientFactory);
    _interceptorExecutor = InterceptorExecutor(interceptors);

    _subscription =
        controller.stream.where((data) => data is Map).map((data) => data as Map).where((data) => data.containsKey('id')).where((data) => snapmap.containsKey(data['id'])).listen(rootStreamListener);
  }

  @visibleForTesting
  void rootStreamListener(data) {
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
              query: Query(document: ''),
            ),
          ),
        );
      } else {
        snapshot.addError(
          HasuraRequestError.fromJson(
            data['payload'],
            request: Request(
              url: '',
              query: Query(document: ''),
            ),
          ),
        );
      }
    }
  }

  ///Execute a Query from a Document
  Future query(String document, {String? key, Map<String, dynamic>? variables, Map<String, String>? headers}) async {
    key = key ?? _keyGenerator.generateBase(document);
    return executeQuery(Query(
      key: key,
      headers: headers,
      document: document.trimLeft(),
      variables: variables,
    ));
  }

  ///Execute a Query from a Query
  Future executeQuery(Query query) async {
    final usecase = sl.get<QueryToServer>();
    var _headers = Map<String, String>.from(headers ?? {});
    if (query.headers != null) {
      _headers.addAll(query.headers!);
    }

    var request = Request(
      headers: _headers,
      type: RequestType.query,
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

  Future<Response> _interceptError(HasuraError error) async {
    final interceptedValue = await _interceptorExecutor(
      ClientResolver.error(error, this),
    );

    if (interceptedValue is Response) {
      return interceptedValue;
    } else {
      throw interceptedValue;
    }
  }

  Future<Response> _interceptResponse(Response response) async {
    final interceptedValue = await _interceptorExecutor(
      ClientResolver.response(response, this),
    );

    if (interceptedValue is Response) {
      return interceptedValue;
    } else {
      throw interceptedValue;
    }
  }

  ///Execute a Mutation from a Document
  Future mutation(String document, {Map<String, dynamic>? variables, bool tryAgain = true, String? key, Map<String, String>? headers}) async {
    key = key ?? _keyGenerator.randomString(15);

    return executeMutation(Query(
      key: key,
      headers: headers,
      document: document.trimLeft(),
      variables: variables,
    ));
  }

  ///Execute a Mutation from a Query
  Future executeMutation(Query query) async {
    final usecase = sl.get<MutationToServer>();

    var _headers = Map<String, String>.from(headers ?? {});
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
  Future<Snapshot> subscription(String document, {String? key, Map<String, dynamic>? variables, Map<String, String>? headers}) async {
    document = document.trim();
    key = key ?? _keyGenerator.generateBase(document);

    return executeSubscription(Query(
      key: key,
      headers: headers,
      document: document,
      variables: variables,
    ));
  }

  ///Execute a Subscription from a Query
  Future<Snapshot> executeSubscription(Query query) async {
    Snapshot snapshot;
    if (snapmap.containsKey(query.key)) {
      snapshot = snapmap[query.key]!;
      return snapshot;
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
      await Future.delayed(Duration(milliseconds: 500));
    } else if (_isConnected) {
      final input = querySubscription(snapshot.query);
      sendToWebSocketServer(input);
    }
    return snapshot;
  }

  void _removeSnapshot(Snapshot snapshot) {
    var stop = {'id': snapshot.query.key, 'type': 'stop'};
    snapmap.remove(snapshot.query.key);
    if (isConnected) sendToWebSocketServer(jsonEncode(stop));
    if (snapmap.keys.isEmpty) disconnect();
  }

  Future _changeVariables(Snapshot snapshot) async {
    var stop = {'id': snapshot.query.key, 'type': 'stop'};
    if (isConnected) sendToWebSocketServer(jsonEncode(stop));
    if (isConnected) sendToWebSocketServer(querySubscription(snapshot.query));
  }

  @visibleForTesting
  void sendToWebSocketServer(String input) {
    if (_connector != null) {
      _connector!.add!(utf8.encode(input));
    }
  }

  Future<void> _renewConnector() async {
    if (_connector == null) {
      final usecase = sl.get<GetConnector>();
      final result = await usecase(url);
      _connector = result.fold((l) => throw l, (c) => c);
    }
  }

  Future<void> _connect() async {
    await _renewConnector();

    if (_connector == null) {
      return;
    }
    final connector = _connector!;
    _disconnectionFlag = false;

    if (reconnectionAttempt != null && reconnectionAttempt! > 0) {
      if (_numbersOfConnectionAttempts >= reconnectionAttempt!) {
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
      query: Query(key: 'key', document: 'document'),
    );

    final interceptedValue = await _interceptorExecutor(
      ClientResolver.request(request, this),
    );

    try {
      if (interceptedValue is Request) {
        request.headers.addAll(interceptedValue.headers);
      } else if (interceptedValue is HasuraError) {
        throw interceptedValue;
      }
      final subscriptionStream = connector.map<Map>((event) => jsonDecode(event)).listen(normalizeStreamValue);
      (_init['payload'] as Map)['headers'] = request.headers;
      sendToWebSocketServer(jsonEncode(_init));
      subscriptionStream.onError(print);
      await connector.done;
      await subscriptionStream.cancel();
      _isConnected = false;

      if (_disconnectionFlag) {
        return;
      }
      await Future.delayed(Duration(milliseconds: 3000));
      // ignore: unawaited_futures
      _connect();
    } catch (e) {
      if (_disconnectionFlag) {
        return;
      }
      // ignore: unawaited_futures
      _connect();
    }
  }

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

  @visibleForTesting
  Future<void> normalizeStreamValue(Map data) async {
    if (data['type'] == 'data' || data['type'] == 'error') {
      controller.add(data);
    } else if (data['type'] == 'connection_ack') {
      await _interceptorExecutor.onConnected(this);
      _numbersOfConnectionAttempts = 0;
      _isConnected = true;
      for (var snap in snapmap.values) {
        sendToWebSocketServer(querySubscription(snap.query));
      }
    } else if (data['type'] == 'connection_error') {
      await Future.delayed(Duration(seconds: 2));
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
    for (var key in keys) {
      snapmap[key]?.close();
    }
    snapmap.clear();
    var disconect = {'type': 'connection_terminate'};
    if (_isConnected) {
      sendToWebSocketServer(jsonEncode(disconect));
    }
    await Future.delayed(Duration(milliseconds: 300));
    if (_connector?.closeCode != null) {
      await _connector?.close?.call();
    }
    await _interceptorExecutor.onDisconnect();
    _connector = null;
  }

  @mustCallSuper
  Future dispose() async {
    await controller.close();
    await _subscription.cancel();
    await disconnect();
  }
}
