import 'package:hasura_connect/src/utils/utils.dart' as utils;
import 'package:uuid/uuid.dart';

class SnapshotInfo {
  ///[query] used in [Snapshot]
  final String query;

  ///[key] used in [Snapshot]
  final String key;

  ///[isQuery] used in [Snapshot]
  final bool isQuery;

  ///[variables] used in [Snapshot]
  Map<String, dynamic> variables;

  ///[keyCache] used in [Snapshot]
  String get keyCache => _generateKeyCache();

  SnapshotInfo({this.query, this.key, this.variables, this.isQuery = false});

  ///return object [SnapshotInfo] as Json
  toJson() {
    return {
      "key": key,
      "query": query,
      "variables": variables,
      "isQuery": isQuery,
    };
  }

  String _generateKeyCache(){
    var uuid = Uuid();
    return uuid.v5(Uuid.NAMESPACE_URL, "$key.${utils.generateBaseJson(variables)}");
  }

  ///create [SnapshotInfo] from json
  factory SnapshotInfo.fromJson(Map json) => SnapshotInfo(
        query: json['query'],
        key: json['key'],
        variables: json['variables'],
        isQuery: json['isQuery'],
      );
}
