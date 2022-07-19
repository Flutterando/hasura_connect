import 'dart:convert';

class Query {
  final String document;
  final Map<String, dynamic>? variables;
  final Map<String, String>? headers;
  final String? key;

  const Query({required this.document, this.variables, this.key, this.headers});

  bool get isValid {
    return document.startsWith('query') || document.startsWith('subscription') || document.startsWith('mutation');
  }

  Map toJson() {
    return {'query': document, 'variables': variables, 'headers': headers};
  }

  @override
  String toString() => jsonEncode(toJson());

  Query copyWith({
    String? document,
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
    String? key,
  }) {
    return Query(
      document: document ?? this.document,
      variables: variables ?? this.variables,
      headers: headers ?? this.headers,
      key: key ?? this.key,
    );
  }
}
