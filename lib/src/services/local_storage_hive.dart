import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'local_storage.dart';

class LocalStorageHive extends LocalStorage {
  Completer<Box> _completer = Completer<Box>();
  String name;

  Future<String> _getPath() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        var dir = await path_provider.getApplicationDocumentsDirectory();
        return dir.path;
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        return ".hasuradb";
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future init(String name) async {
    if (_completer.isCompleted) return;
    this.name = name;
    Hive.init(await _getPath());
    if (Hive.isBoxOpen(name)) {
      _completer.complete(await Hive.openBox(name));
    } else {
      _completer.complete(await Hive.openBox(name));
    }
  }

  @override
  Future<Map<String, dynamic>> getAll() async {
    var box = await _completer.future;
    return box.toMap().map<String, dynamic>(
        (key, value) => MapEntry<String, dynamic>(key, value));
  }

  @override
  Future<Map> getValue(String key) async {
    var box = await _completer.future;
    if (box.containsKey(key)) {
      return jsonDecode(box.get(key));
    } else {
      return null;
    }
  }

  @override
  Future put(String key, Map query) async {
    var box = await _completer.future;
    await box.put(key, jsonEncode(query));
  }

  @override
  Future<bool> remove(String key) async {
    var box = await _completer.future;
    try {
      await box.delete(key);
      return true;
    } catch (_) {
      return false;
    }
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
