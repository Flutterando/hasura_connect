class SnapshotInfo {
  ///[query] used in [Snapshot]
  final String query;

  ///[key] used in [Snapshot]
  final String key;

  ///[isQuery] used in [Snapshot]
  final bool isQuery;

  ///[variables] used in [Snapshot]
  Map<String, dynamic> variables;

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

  ///create [SnapshotInfo] from json
  factory SnapshotInfo.fromJson(Map json) => SnapshotInfo(
        query: json['query'],
        key: json['key'],
        variables: json['variables'],
        isQuery: json['isQuery'],
      );
}
