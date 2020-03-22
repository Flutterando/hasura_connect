import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageHasura {
  final _completer = Completer<SharedPreferences>();
  final String boxName;

  LocalStorageHasura(this.boxName, {bool isTest = false}) {
    _init(isTest);
  }

  // Future<String> _getPath() async {
  //   try {
  //     if (Platform.isAndroid || Platform.isIOS) {
  //       var dir = await path_provider.getApplicationDocumentsDirectory();
  //       return dir.path;
  //     } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  //       return ".hasuradb";
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  void _init(bool isTest) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    _completer.complete(sharedPreferences);
  }

  Future<Map<String, dynamic>> getAll() async {
    var box = await _completer.future;
    var map = {};
    box.getKeys().where((key) => key.startsWith('$boxName.')).forEach((key) {
      map[key.replaceFirst('$boxName.', '')] = jsonDecode(box.getString(key));
    });
    return map;
  }

  Future<Map> getValue(String key) async {
    var box = await _completer.future;
    key = '$boxName.$key';
    if (box.containsKey(key)) {
      return jsonDecode(box.getString(key));
    } else {
      return null;
    }
  }

  Future put(String key, Map query) async {
    var box = await _completer.future;
    await box.setString('$boxName.$key', jsonEncode(query));
  }

  Future<bool> remove(String key) async {
    var box = await _completer.future;
    return box.remove('$boxName.$key');
  }

  Future clear() async {
    try {
      var box = await _completer.future;
      await box.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  @deprecated
  Future close() async {}
}
