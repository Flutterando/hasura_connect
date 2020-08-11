import 'dart:convert';

import 'package:meta/meta.dart';

class Query {
  final String document;
  final Map<String, dynamic> variables;
  final String key;

  const Query({@required this.document, this.variables, this.key});

  bool get isValid {
    return document.startsWith('query') ||
        document.startsWith('subscription') ||
        document.startsWith('mutation');
  }

  Map toJson() {
    return {'query': document, 'variables': variables};
  }

  @override
  String toString() => jsonEncode(toJson());

  Query copyWith({
    String document,
    Map<String, dynamic> variables,
    String key,
  }) {
    return Query(
      document: document ?? this.document,
      variables: variables ?? this.variables,
      key: key ?? this.key,
    );
  }
}
