import 'dart:async';
import 'dart:convert';

import 'package:hasura_connect/src/core/hasura.dart';
import 'package:hasura_connect/src/exceptions/hasura_error.dart';
import 'package:hasura_connect/src/services/local_storage_hasura.dart';
import 'package:hasura_connect/src/snapshot/snapshot.dart';
import 'package:hasura_connect/src/snapshot/snapshot_data.dart';
import 'package:hasura_connect/src/snapshot/snapshot_info.dart';
import 'package:hasura_connect/src/utils/utils.dart' as utils;
import 'package:websocket/websocket.dart';
import 'package:http/http.dart' as http;

class HasuraConnectBase implements HasuraConnect {
  final _controller = StreamController.broadcast();
  final Map<String, SnapshotData> _snapmap = {};
  final Map<String, String> headers;

  LocalStorageHasura _localStorageMutation =
      LocalStorageHasura("hasura_mutations");
  LocalStorageHasura _localStorageCache = LocalStorageHasura("hasura_cache");
  WebSocket _channelPromisse;
  bool _isDisconnected = false;
  bool isConnected = false;
  Completer<bool> _onConnect = Completer<bool>();

  final String url;

  Future<String> Function(bool isError) _token;

  HasuraConnectBase(this.url,
      {Future<String> Function(bool isError) token, this.headers})
      : _token = token;

  final _init = {
    "payload": {
      "headers": {"content-type": "application/json"}
    },
    "type": 'connection_init'
  };

  @override
  void changeToken(Future<String> Function(bool isError) token) {
    _token = token;
  }

  @override
  void addHeader(String key, String value) {
    headers[key] = value;
  }

  @override
  void removeHeader(String key) {
    headers.remove(key);
  }

  @override
  void removeAllHeader() {
    headers.clear();
  }

  Stream _generateStream(String key) {
    return _controller.stream.where((data) => data["id"] == key).transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          if (data["type"] == "data") {
            sink.add(data['payload']);
          } else if (data["type"] == "error") {
            if ((data["payload"] as Map).containsKey("errors")) {
              sink.addError(HasuraError.fromJson(data["payload"]["errors"][0]));
            } else {
              sink.addError(HasuraError.fromJson(data["payload"]));
            }
          }
        },
      ),
    ).asBroadcastStream();
  }

  Stream _generateFutureQueryStream(Future query) {
    return Stream.fromFuture(query);
  }

  @override
  Snapshot subscription(String query,
      {String key, Map<String, dynamic> variables}) {
    if (query.trim().split(" ")[0] != "subscription") {
      query = "subscription $query";
    }

    if (key == null) {
      key = utils.generateBase(query);
    }
    final info = SnapshotInfo(key: key, query: query, variables: variables);
    // _localStorage.addSubscription(info);
    return _generateSnapshot(info);
  }

  @override
  Snapshot cachedQuery(String query,
      {String key, Map<String, dynamic> variables}) {
    if (query.trimLeft().split(" ")[0] != "query") {
      query = "query $query";
    }

    if (key == null) {
      key = utils.generateBase(query);
    }

    Map<String, dynamic> jsonMap = {
      'query': query,
      'variables': variables,
    };
    final info = SnapshotInfo(
        key: key, query: query, variables: variables, isQuery: true);
    return _generateSnapshot(info, futureQuery: _sendPost(jsonMap));
  }

  Snapshot _generateSnapshot(SnapshotInfo info, {Future futureQuery}) {
    if (_snapmap.keys.isEmpty && futureQuery == null) {
      _connect();
    }

    if (_snapmap.containsKey(info.key) && futureQuery == null) {
      return _snapmap[info.key];
    }

    if (isConnected && futureQuery == null) {
      _channelPromisse.addUtf8Text(
          _getDocument(info.query, info.key, info.variables).codeUnits);
    }

    var snap = SnapshotData(
        info,
        info.isQuery
            ? _generateFutureQueryStream(futureQuery)
            : _generateStream(info.key), () async {
      if (futureQuery == null) {
        _stopStream(info.key);
        _snapmap.remove(info.key);
        if (_snapmap.keys.isEmpty) {
          await _disconnect();
        }
      }
    }, (snapshotInternal) {
      _stopStream(info.key);
      if (isConnected) {
        _channelPromisse.addUtf8Text(_getDocument(snapshotInternal.info.query,
                snapshotInternal.info.key, snapshotInternal.info.variables)
            .codeUnits);
      }
    }, conn: this, localStorageCache: _localStorageCache);

    if (futureQuery == null) {
      _snapmap[info.key] = snap;
    }
    return snap;
  }

  _stopStream(String key) {
    var stop = {"id": key, "type": 'stop'};
    if (isConnected) _channelPromisse.addUtf8Text(jsonEncode(stop).codeUnits);
  }

  String _getDocument(
      String query, String key, Map<String, dynamic> variables) {
    return jsonEncode({
      "id": key,
      "payload": {
        "query": query,
        "variables": variables,
      },
      "type": 'start'
    });
  }

  _addToken([bool isError = false]) async {
    if (_token != null) {
      String t = await _token(isError);
      if (t != null) {
        (_init["payload"] as Map)["headers"]["Authorization"] = t;
      }
    }
  }

  _connect() async {
    print("hasura connecting...");
    try {
      _channelPromisse = await WebSocket.connect(url.replaceFirst("http", "ws"),
          protocols: ['graphql-ws']); //graphql-subscriptions
      await _addToken();
      if (headers != null) {
        for (var key in headers?.keys) {
          (_init["payload"] as Map)["headers"][key] = headers[key];
        }
      }
      _channelPromisse.addUtf8Text(jsonEncode(_init).codeUnits);
      var _sub = _channelPromisse.stream.listen((data) async {
        data = jsonDecode(data);
        if (data["type"] == "data" || data["type"] == "error") {
          _controller.add(data);
        } else if (data["type"] == "connection_ack") {
          print("HASURA CONNECT!");
          isConnected = true;

          for (var key in _snapmap.keys) {
            _channelPromisse.addUtf8Text(_getDocument(_snapmap[key].info.query,
                    _snapmap[key].info.key, _snapmap[key].info.variables)
                .codeUnits);
          }

          Map<String, dynamic> mutationCache =
              await _localStorageMutation.getAll();
          for (var key in mutationCache.keys) {
            await _sendPost(mutationCache[key], key);
          }
        } else if (data["type"] == "connection_error") {
          print("Try again...");
          await Future.delayed(Duration(seconds: 2));
          await _addToken(true);
          _channelPromisse.addUtf8Text(jsonEncode(_init).codeUnits);
        } else if (data["type"] == "ka") {
        } else {
          print(data);
        }
      });
      _sub.onError((e) {
        print(e);
      });
      await _channelPromisse.done;
      await _sub.cancel();
      isConnected = false;
      if (!_isDisconnected) {
        await Future.delayed(Duration(milliseconds: 3000));
        if (_onConnect.isCompleted) {
          _onConnect = Completer<bool>();
        }
        _connect();
      }
    } catch (e) {
      print(e);
      if (!_isDisconnected) {
        await Future.delayed(Duration(milliseconds: 3000));

        if (_onConnect.isCompleted) {
          _onConnect = Completer<bool>();
        }
        _connect();
      }
    }
  }

  _disconnect() async {
    var disconect = {"type": 'connection_terminate'};
    if (isConnected) {
      _channelPromisse.addUtf8Text(jsonEncode(disconect).codeUnits);
    }
    _isDisconnected = true;
    await Future.delayed(Duration(milliseconds: 300));
    if (_channelPromisse?.closeCode != null) {
      await _channelPromisse.close();
    }
    print("disconnected hasura");
  }

  @override
  Future query(String doc, {Map<String, dynamic> variables}) async {
    if (doc.trimLeft().split(" ")[0] != "query") {
      doc = "query $doc";
    }
    Map<String, dynamic> jsonMap = {
      'query': doc,
      'variables': variables,
    };

    return await _sendPost(jsonMap);
  }

  @override
  Future mutation(String doc,
      {Map<String, dynamic> variables, bool tryAgain = true}) async {
    if (doc.trim().split(" ")[0] != "mutation") {
      doc = "mutation $doc";
    }
    Map<String, dynamic> jsonMap = {
      'query': doc,
      'variables': variables,
    };
    String hash = utils.randomString(15);
    await _localStorageMutation.put(hash, jsonMap);
    return await _sendPost(jsonMap, hash);
  }

  Future _sendPost(Map jsonMap, [String hash]) async {
    String jsonString = jsonEncode(jsonMap);

    Map<String, String> headersLocal = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    if (_token != null) {
      String t = await _token(false);
      if (t != null) {
        headersLocal["Authorization"] = t;
      }
    }

    if (headers != null) {
      for (var key in headers?.keys) {
        headersLocal[key] = headers[key];
      }
    }

    var client = http.Client();
    try {
      var response =
          await client.post(url, body: jsonString, headers: headersLocal);
      Map json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (hash != null) {
          await _localStorageMutation.remove(hash);
        }
        if (json.containsKey("errors")) {
          throw HasuraError.fromJson(json["errors"][0]);
          return json["errors"][0];
        }
        return json;
      } else {
        throw HasuraError("connection error", null);
      }
    } catch (r) {
      throw HasuraError("connection error", null);
    } finally {
      client.close();
    }
  }

  ///finalize Hasura connection
  void dispose() async {
    _disconnect();
    _snapmap.clear();
    await _localStorageMutation.close();
    await _localStorageCache.close();
    await _controller.close();
  }
}
