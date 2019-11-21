import 'dart:async';
import 'dart:convert';

import 'package:websocket/websocket.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'hasura_error.dart';
import 'snapshot.dart';

class HasuraConnect {
  final _controller = StreamController.broadcast();
  final Map<String, Snapshot> _snapmap = {};
  final Map<String, String> headers;

  WebSocket _channelPromisse;
  bool _isDisconnected = false;
  bool isConnected = false;
  Completer<bool> _onConnect = Completer<bool>();

  final String url;

  Future<String> Function(bool isError) _token;

  HasuraConnect(this.url,
      {Future<String> Function(bool isError) token, this.headers}) {
    _token = token;
  }

  void changeToken(Future<String> Function(bool isError) token) {
    _token = token;
  }

  final _init = {
    "payload": {
      "headers": {"content-type": "application/json"}
    },
    "type": 'connection_init'
  };

  String get ramdomKey {
    var rand = Random();
    var codeUnits = List.generate(8, (index) {
      return rand.nextInt(33) + 89;
    });

    return String.fromCharCodes(codeUnits);
  }

  void addHeader(String key, String value) {
    headers[key] = value;
  }

  void removeHeader(String key) {
    headers.remove(key);
  }

  void removeAllHeader() {
    headers.clear();
  }

  String _generateBase(String query) {
    query = query.replaceAll(RegExp("[^a-zA-Z0-9 -]"), "").replaceAll(" ", "");
    var bytes = utf8.encode(query);
    var base64Str = base64.encode(bytes);
    return base64Str;
  }

  Stream generateStream(String key) {
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

  Snapshot subscription(String query,
      {String key, Map<String, dynamic> variables}) {
    if (query.trim().split(" ")[0] != "subscription") {
      query = "subscription $query";
    }

    if (key == null) {
      key = _generateBase(query);
    }

    if (_snapmap.keys.isEmpty) {
      _connect();
    }

    if (_snapmap.containsKey(key)) {
      return _snapmap[key];
    } else {
      if (isConnected) {
        _channelPromisse
            .addUtf8Text(_getDocument(query, key, variables).codeUnits);
      }
      var snap = Snapshot(
        key,
        query,
        variables,
        generateStream(key),
        () async {
          _stopStream(key);
          _snapmap.remove(key);
          if (_snapmap.keys.isEmpty) {
            await _disconnect();
          }
        },
        (snapshotInternal) {
          _stopStream(key);
          if (isConnected) {
            _channelPromisse.addUtf8Text(_getDocument(snapshotInternal.query,
                    snapshotInternal.key, snapshotInternal.variables)
                .codeUnits);
          }
        },
        conn: this,
      );

      _snapmap[key] = snap;
      return snap;
    }
  }

  _stopStream(String key) {
    var stop = {"id": key, "type": 'stop'};
    // var stop = {"id": key, "type": 'stop'};
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
            _channelPromisse.addUtf8Text(_getDocument(_snapmap[key].query,
                    _snapmap[key].key, _snapmap[key].variables)
                .codeUnits);
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
    if (isConnected)
      _channelPromisse.addUtf8Text(jsonEncode(disconect).codeUnits);
    _isDisconnected = true;
    await Future.delayed(Duration(milliseconds: 300));
    if (_channelPromisse?.closeCode != null) {
      await _channelPromisse.close();
    }
    print("disconnected hasura");
  }

  Future query(String doc, {Map<String, dynamic> variables}) async {
    if (doc.trimLeft().split(" ")[0] != "query") {
      doc = "query $doc";
    }
    Map<String, dynamic> jsonMap = {
      'query': doc,
      'variables': variables,
    };
    return _sendPost(jsonMap);
  }

  Future mutation(String doc, {Map<String, dynamic> variables}) async {
    if (doc.trim().split(" ")[0] != "mutation") {
      doc = "mutation $doc";
    }
    Map<String, dynamic> jsonMap = {
      'query': doc,
      'variables': variables,
    };
    return _sendPost(jsonMap);
  }

  Future _sendPost(Map<String, dynamic> jsonMap) async {
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
        if (json.containsKey("errors")) {
          throw HasuraError.fromJson(json["errors"][0]);
        }
        return json;
      } else {
        throw HasuraError("connection error", null);
      }
    } finally {
      client.close();
    }
  }

  // Future _sendPost(Map<String, dynamic> jsonMap) async {
  //   String jsonString = jsonEncode(jsonMap);
  //   List<int> bodyBytes = utf8.encode(jsonString);
  //   var request = await HttpClient().postUrl(Uri.parse(url));
  //   request.headers.removeAll(HttpHeaders.acceptEncodingHeader);
  //   request.headers.add("Content-type", "application/json");
  //   request.headers.add("Accept", "application/json");
  //   if (token != null) {
  //     String t = await token();
  //     if (t != null) {
  //       request.headers.add("Authorization", t);
  //     }
  //   }

  //   if (headers != null) {
  //     for (var key in headers?.keys) {
  //       request.headers.add(key, headers[key]);
  //     }
  //   }

  //   request.headers.set('Content-Length', bodyBytes.length.toString());
  //   request.add(bodyBytes);
  //   var response = await request.close();

  //   String value = "";

  //   await for (var contents in response.transform(Utf8Decoder())) {
  //     value += contents;
  //   }

  //   Map json = jsonDecode(value);

  //   if (json.containsKey("errors")) {
  //     throw HasuraError.fromJson(json["errors"][0]);
  //   }
  //   return json;
  // }

  void dispose() {
    _disconnect();
    _controller.close();
    _snapmap.clear();
  }
}
