import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:hasura_connect/src/snapshot_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  Completer<SharedPreferences> _completer = Completer<SharedPreferences>();

  LocalStorage() {
    _init();
  }

  _init() async {
    _completer.complete(await SharedPreferences.getInstance());
  }

  Future<Map<String, dynamic>> getAllMutation() async {
    var shared = await _completer.future;
    Map<String, dynamic> map = {};
    shared.getKeys().forEach((key) {
      if (key.startsWith("localstorage-")) {
        map[key] = jsonDecode(shared.getString(key));
      }
    });
    return map;
  }

  Future<String> addMutation(Map query) async {
    var shared = await _completer.future;
    String key = _randomString(15);
    await shared.setString("localstorage-$key", jsonEncode(query));
    return "localstorage-$key";
  }

  String _randomString(int length) {
    var rand = Random();
    var codeUnits = List.generate(length, (index) {
      return rand.nextInt(33) + 89;
    });

    return String.fromCharCodes(codeUnits);
  }

  Future remove(String key) async {
    try {
      var shared = await _completer.future;
      await shared.remove(key);
    } catch (e) {
      //erro
    }
  }

  Future<List<SnapshotInfo>> getAllSubscriptions() async {
    var shared = await _completer.future;
    List<SnapshotInfo> list = [];
    shared.getKeys().forEach((key) {
      if (key.startsWith("subscriptons-")) {
        list.add(
          SnapshotInfo.fromJson(jsonDecode(shared.getString(key))),
        );
      }
    });
    return list;
  }

  Future<String> addSubscription(SnapshotInfo info) async {
    var shared = await _completer.future;
    await shared.setString(
        "subscriptons-${info.key}", jsonEncode(info.toJson()));
    return "subscriptons-${info.key}";
  }
}
