import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:http_parser/http_parser.dart';
import 'package:websocket/websocket.dart';
import 'dart:math';

import 'hasura_error.dart';
import 'snapshot.dart';

var _defaultClient = IOClient(
  HttpClient(
    context: SecurityContext.defaultContext,
  ),
);

class HasuraConnect {
  final _controller = StreamController.broadcast();
  final Map<String, Snapshot> _snapmap = {};
  final Map<String, String> headers;

  WebSocket _channelPromisse;
  bool _isDisconnected = false;
  bool isConnected = false;
  Completer<bool> _onConnect = Completer<bool>();

  final String url;

  final Future<String> Function() token;
  final Client httpClient;

  HasuraConnect(this.url,
      {this.token, this.headers, Client httpClient})
      : this.httpClient = httpClient == null ? _defaultClient : httpClient;

  final _init = {
    "payload": {
      "headers": {"content-type": "application/json"}
    },
    "type": 'connection_init'
  };

  String get ramdomKey {
    var rand = new Random();
    var codeUnits = new List.generate(8, (index) {
      return rand.nextInt(33) + 89;
    });

    return new String.fromCharCodes(codeUnits);
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
        _controller.stream.where((data) => data["id"] == key).transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              if (data["type"] == "data") {
                sink.add(data['payload']);
              } else if (data["type"] == "error") {
                if ((data["payload"] as Map).containsKey("errors")) {
                  sink.addError(
                      HasuraError.fromJson(data["payload"]["errors"][0]));
                } else {
                  sink.addError(HasuraError.fromJson(data["payload"]));
                }
              }
            },
          ),
        ),
            () {
          _stopStream(key);
          _snapmap.remove(key);
          if (_snapmap.keys.isEmpty) {
            _disconnect();
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

  _connect() async {
    print("hasura connecting...");

    try {
      _channelPromisse = await WebSocket.connect(url.replaceFirst("http", "ws"),
          protocols: ['graphql-ws']); //graphql-subscriptions
      if (token != null) {
        String t = await token();
        if (t != null) {
          (_init["payload"] as Map)["headers"]["Authorization"] = t;
        }
      }

      if (headers != null) {
        for (var key in headers?.keys) {
          (_init["payload"] as Map)["headers"][key] = headers[key];
        }
      }

      _channelPromisse.addUtf8Text(jsonEncode(_init).codeUnits);
      var _sub = _channelPromisse.stream.listen((data) {
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
          //_onConnect.complete(true);
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

  void _disconnect() {
    print("disconnected hasura");
    _isDisconnected = true;
    if (_channelPromisse?.closeCode != null) {
      _channelPromisse.close();
    }
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

  Future<Map<String, dynamic>> _sendPost(Map<String, dynamic> jsonMap) async {
    Map<String, String> headersLocal = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    if (token != null) {
      String t = await token();
      if (t != null) {
        headersLocal["Authorization"] = t;
      }
    }

    if (headers != null) {
      for (var key in headers?.keys) {
        headersLocal[key] = headers[key];
      }
    }

    var request = await _prepareRequest(url, jsonMap, headersLocal);
    StreamedResponse response = await httpClient.send(request);
    Map<String, dynamic> json = await _parseResponse(response);

    if (json.containsKey("errors")) {
      throw HasuraError.fromJson(json["errors"]);
    }
    return json;
  }

  void dispose() {
    httpClient.close();
    _disconnect();
    _controller.close();
    _snapmap.clear();
  }
}

Future<Map<String, MultipartFile>> _getFileMap(dynamic body, {
  Map<String, MultipartFile> currentMap,
  List<String> currentPath = const <String>[],
}) async {
  currentMap ??= <String, MultipartFile>{};
  if (body is Map<String, dynamic>) {
    final Iterable<MapEntry<String, dynamic>> entries = body.entries;
    for (MapEntry<String, dynamic> element in entries) {
      currentMap.addAll(await _getFileMap(
        element.value,
        currentMap: currentMap,
        currentPath: List<String>.from(currentPath)
          ..add(element.key),
      ));
    }
    return currentMap;
  }
  if (body is List<dynamic>) {
    for (int i = 0; i < body.length; i++) {
      currentMap.addAll(await _getFileMap(
        body[i],
        currentMap: currentMap,
        currentPath: List<String>.from(currentPath)
          ..add(i.toString()),
      ));
    }
    return currentMap;
  }
  if (body is MultipartFile) {
    return currentMap
      ..addAll(<String, MultipartFile>{currentPath.join('.'): body});
  }

  // else should only be either String, num, null; NOTHING else
  return currentMap;
}

Future<BaseRequest> _prepareRequest(String url,
    Map<String, dynamic> body,
    Map<String, String> httpHeaders,) async {
  final Map<String, MultipartFile> fileMap = await _getFileMap(body);
  if (fileMap.isEmpty) {
    final Request r = Request('post', Uri.parse(url));
    r.headers.addAll(httpHeaders);
    r.body = json.encode(body);
    return r;
  }

  final MultipartRequest r = MultipartRequest('post', Uri.parse(url));
  r.headers.addAll(httpHeaders);
  r.fields['operations'] = json.encode(body, toEncodable: (dynamic object) {
    if (object is MultipartFile) {
      return null;
    }
    return object.toJson();
  });

  final Map<String, List<String>> fileMapping = <String, List<String>>{};
  final List<MultipartFile> fileList = <MultipartFile>[];

  final List<MapEntry<String, MultipartFile>> fileMapEntries =
  fileMap.entries.toList(growable: false);

  for (int i = 0; i < fileMapEntries.length; i++) {
    final MapEntry<String, MultipartFile> entry = fileMapEntries[i];
    final String indexString = i.toString();
    fileMapping.addAll(<String, List<String>>{
      indexString: <String>[entry.key],
    });
    final MultipartFile f = entry.value;
    fileList.add(MultipartFile(
      indexString,
      f.finalize(),
      f.length,
      contentType: f.contentType,
      filename: f.filename,
    ));
  }

  r.fields['map'] = json.encode(fileMapping);

  r.files.addAll(fileList);
  return r;
}

Future<Map<String, dynamic>> _parseResponse(StreamedResponse response) async {
  final int statusCode = response.statusCode;
  final Encoding encoding = _determineEncodingFromResponse(response);
  // @todo limit bodyBytes
  final Uint8List responseByte = await response.stream.toBytes();
  final String decodedBody = encoding.decode(responseByte);
  final Map<String, dynamic> jsonResponse = jsonDecode(decodedBody);

  if (jsonResponse['data'] == null && jsonResponse['errors']) {
    if (statusCode < 200 || statusCode >= 400) {
      throw HasuraError(
        'Network Error: $statusCode $decodedBody',
        null,
      );
    }
    throw HasuraError('Invalid response body: $decodedBody', null);
  }

  return jsonResponse;
}

/// Returns the charset encoding for the given response.
///
/// The default fallback encoding is set to UTF-8 according to the IETF RFC4627 standard
/// which specifies the application/json media type:
///   "JSON text SHALL be encoded in Unicode. The default encoding is UTF-8."
Encoding _determineEncodingFromResponse(BaseResponse response,
    [Encoding fallback = utf8]) {
  final String contentType = response.headers['content-type'];

  if (contentType == null) {
    return fallback;
  }

  final MediaType mediaType = MediaType.parse(contentType);
  final String charset = mediaType.parameters['charset'];

  if (charset == null) {
    return fallback;
  }

  final Encoding encoding = Encoding.getByName(charset);

  return encoding == null ? fallback : encoding;
}
