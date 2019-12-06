import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class LocalStorageHasura {
  Completer<Box> _completer = Completer<Box>();

  LocalStorageHasura(String boxName, {bool isTest = false}) {
    _init(boxName, isTest);
  }

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

  _init(String boxName, bool isTest) async {
    String path = await _getPath();
    if (path != null) {
      Hive.init(path);
    }

    Box box;
    if (isTest) {
      box = await Hive.openBoxFromBytes(boxName, Uint8List(0));
    } else {
        if(Hive.isBoxOpen(boxName)){
          box = await Hive.box(boxName);
        } else {
          box = await Hive.openBox(boxName);
        }
    }

    _completer.complete(box);
  }

  Future<Map<String, dynamic>> getAll() async {
    var box = await _completer.future;
    Map<String, dynamic> map = {};
    box.keys.forEach((key) {
      map[key] = box.get(key);
    });
    return map;
  }

  Future<Map> getValue(String key) async {
    var box = await _completer.future;
    return box.get(key);
  }

  Future put(String key, Map query) async {
    var box = await _completer.future;
    await box.put(key, query);
  }

  Future<bool> remove(String key) async {
    try {
      var box = await _completer.future;
      await box.delete(key);
      return true;
    } catch (e) {
      return false;
    }
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

  Future close() async {
    var box = await _completer.future;
    await box.close();
  }
}
