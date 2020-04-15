import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage.dart';

class LocalStorageSharedPreferences extends LocalStorage {
  Completer<SharedPreferences> _completer = Completer<SharedPreferences>();
  String name;

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

  @override
  Future init(String name) async {
    this.name = name;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _completer.complete(sharedPreferences);
  }

  @override
  Future<Map<String, dynamic>> getAll() async {
    var box = await _completer.future;
    Map<String, dynamic> map = {};
    box.getKeys().where((key) => key.startsWith('$name.')).forEach((key) {
      map[key.replaceFirst('$name.', '')] = jsonDecode(box.getString(key));
    });
    return map;
  }

  @override
  Future<Map> getValue(String key) async {
    var box = await _completer.future;
    key = '$name.$key';
    if (box.containsKey(key)) {
      return jsonDecode(box.getString(key));
    } else {
      return null;
    }
  }

  @override
  Future put(String key, Map query) async {
    var box = await _completer.future;
    await box.setString('$name.$key', jsonEncode(query));
  }

  @override
  Future<bool> remove(String key) async {
    var box = await _completer.future;
    return box.remove('$name.$key');
  }

  @override
  Future clear() async {
    try {
      var box = await _completer.future;
      await box.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future close() async {}
}
