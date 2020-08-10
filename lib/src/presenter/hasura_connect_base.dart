import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
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

import '../di/module.dart';
import '../di/injection.dart' as sl;

class HasuraConnect {
  final _controller = StreamController.broadcast();
  final String url;
  final Map<String, Snapshot> _snapmap = {};
  final KeyGenerator _keyGenerator = KeyGenerator();
  InterceptorExecutor _interceptorExecutor;
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

  Connector _connector;

  StreamSubscription _subscription;
  final int reconnectionAttemp;
  final Map<String, String> headers;

  HasuraConnect(
    this.url, {
    this.reconnectionAttemp,
    List<Interceptor> interceptors,
    this.headers,
  }) {
    startModule();
    _interceptorExecutor = InterceptorExecutor(interceptors);

    _subscription = _controller.stream.listen((data) {
      if (!_snapmap.containsKey(data['id'])) {
        return;
      }

      final snapshot = _snapmap[data['id']];

      if (data['type'] == 'data') {
        snapshot.add(data['payload']);
      } else if (data['type'] == 'error') {
        if ((data['payload'] as Map).containsKey('errors')) {
          snapshot.addError(
              HasuraRequestError.fromJson(data['payload']['errors'][0]));
        } else {
          snapshot.addError(HasuraRequestError.fromJson(data['payload']));
        }
      }
    });
  }

  Future query(String document,
      {String key, Map<String, dynamic> variables}) async {
    final usecase = sl.get<QueryToServer>();
    key = key ?? _keyGenerator.generateBase(document);
    var request = Request(
      headers: headers,
      type: RequestType.query,
      url: url,
      query: Query(
        key: key,
        document: document.trimLeft(),
        variables: variables,
      ),
    );
    final interceptedValue = await _interceptorExecutor(
      ClientResolver.request(request),
    );

    if (interceptedValue is Response) {
      return interceptedValue;
    } else if (interceptedValue is HasuraError) {
      throw interceptedValue;
    } else {
      request = interceptedValue;
    }

    final result = await usecase(request: request);
    return await result.fold(_interceptError, _interceptResponse);
  }

  Future<Response> _interceptError(HasuraError error) async {
    final interceptedValue = await _interceptorExecutor(
      ClientResolver.error(error),
    );

    if (interceptedValue is Response) {
      return interceptedValue;
    } else {
      throw interceptedValue;
    }
  }

  Future<Response> _interceptResponse(Response response) async {
    final interceptedValue = await _interceptorExecutor(
      ClientResolver.response(response),
    );

    if (interceptedValue is Response) {
      return interceptedValue;
    } else {
      throw interceptedValue;
    }
  }

  Future mutation(String document,
      {Map<String, dynamic> variables,
      bool tryAgain = true,
      String key}) async {
    final usecase = sl.get<MutationToServer>();

    key = key ?? _keyGenerator.randomString(15);
    var request = Request(
      headers: headers,
      type: RequestType.mutation,
      url: url,
      query: Query(
        key: key,
        document: document.trimLeft(),
        variables: variables,
      ),
    );

    final interceptedValue = await _interceptorExecutor(
      ClientResolver.request(request),
    );

    if (interceptedValue is Response) {
      return interceptedValue;
    } else if (interceptedValue is HasuraError) {
      throw interceptedValue;
    } else {
      request = interceptedValue;
    }

    final result = await usecase(request: request);
    return await result.fold(_interceptError, _interceptResponse);
  }

  Future<Snapshot> subscription(String document,
      {String key, Map<String, dynamic> variables}) async {
    document = document.trim();
    key = key ?? _keyGenerator.generateBase(document);
    Snapshot snapshot;
    if (_snapmap.containsKey(key)) {
      snapshot = _snapmap[key];
    }

    snapshot = await optionOf(snapshot).fold(() async {
      final usecase = sl.get<GetSnapshotSubscription>();
      final request = Request(
        url: url,
        type: RequestType.subscription,
        query: Query(
          key: key,
          document: document,
          variables: variables,
        ),
      );
      final result = await usecase(
        closeConnection: _removeSnapshot,
        request: request,
      );
      final snapshot = result.fold((l) => throw l, id);
      _snapmap[key] = snapshot;
      await _interceptorExecutor.onSubscription(request, snapshot);

      return snapshot;
    }, (a) async => a);

    if (_snapmap.keys.isNotEmpty) {
      // ignore: unawaited_futures
      _connect();
    } else if (_isConnected) {
      _sendToWebSocketServer(querySubscription(snapshot.query));
    }
    return snapshot;
  }

  void _removeSnapshot(Snapshot snapshot) {
    var stop = {'id': snapshot.query.key, 'type': 'stop'};
    _snapmap.remove(snapshot.query.key);
    _sendToWebSocketServer(jsonEncode(stop));
    if (_snapmap.keys.isEmpty) disconnect();
  }

  void _sendToWebSocketServer(String input) {
    _connector.add(utf8.encode(input));
  }

  Future<void> _renewConnector() async {
    final option = optionOf(_connector);
    await option.fold(() async {
      final usecase = sl.get<GetConnector>();
      final result = await usecase(url);
      _connector = result.fold((l) => throw l, id);
    }, id);
  }

  Future<void> _connect() async {
    try {
      await _renewConnector();
    } catch (e) {
      print(e);
    }

    if (_connector == null) {
      return;
    }
    _disconnectionFlag = false;

    if (reconnectionAttemp != null && reconnectionAttemp > 0) {
      if (_numbersOfConnectionAttempts >= reconnectionAttemp) {
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
      ClientResolver.request(request),
    );

    try {
      if (interceptedValue is Request) {
        request.headers?.addAll(interceptedValue.headers);
      } else if (interceptedValue is HasuraError) {
        throw interceptedValue;
      }
      final subscriptionStream = _connector.listen(_normalizeStreamValue);
      (_init['payload'] as Map)['headers'] = request.headers;
      _sendToWebSocketServer(jsonEncode(_init));
      subscriptionStream.onError(print);
      await _connector.done;
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

  Future<void> _normalizeStreamValue(event) async {
    final data = jsonDecode(event);
    if (data['type'] == 'data' || data['type'] == 'error') {
      _controller.add(data);
    } else if (data['type'] == 'connection_ack') {
      await _interceptorExecutor.onConnected(this);
      _numbersOfConnectionAttempts = 0;
      _isConnected = true;
      for (var snap in _snapmap.values) {
        _sendToWebSocketServer(querySubscription(snap.query));
      }
    } else if (data['type'] == 'connection_error') {
      await Future.delayed(Duration(seconds: 2));
      await _interceptorExecutor.onTryAgain(this);
      _sendToWebSocketServer(jsonEncode(_init));
    }
  }

  Future<void> disconnect() async {
    if (_disconnectionFlag) {
      return;
    }
    _disconnectionFlag = true;
    final keys = List<String>.from(_snapmap.keys);
    for (var key in keys) {
      try {
        await _snapmap[key].close();
      } catch (e) {
        print(e);
      }
    }
    _snapmap.clear();
    var disconect = {'type': 'connection_terminate'};
    if (_isConnected) {
      _sendToWebSocketServer(jsonEncode(disconect));
    }
    await Future.delayed(Duration(milliseconds: 300));
    if (_connector?.closeCode != null) {
      await _connector.close();
    }
    await _interceptorExecutor.onDisconnect();
    _connector = null;
  }

  @mustCallSuper
  Future dispose() async {
    // ignore: unawaited_futures
    await disconnect();
    await _controller.close();
    await _subscription.cancel();
  }
}
