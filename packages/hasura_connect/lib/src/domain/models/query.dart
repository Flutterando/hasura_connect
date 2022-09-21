import 'dart:convert';

///Class [Query]
///Creates a query object and converts it into a json
class Query {
  ///[document] variable
  final String document;

  ///[variables] variable
  final Map<String, dynamic>? variables;

  ///[headers] variable
  final Map<String, String>? headers;

  ///[key] variable
  final String? key;

  ///[Query] class constructor
  const Query({required this.document, this.variables, this.key, this.headers});

  ///The [bool] method [isValid] returns the document that starts with query or
  ///subscription or mutation
  bool get isValid {
    return document.startsWith('query') ||
        document.startsWith('subscription') ||
        document.startsWith('mutation');
  }

  ///The [Map] method [toJson] returns the document as a json
  Map toJson() {
    return {'query': document, 'variables': variables, 'headers': headers};
  }

  @override
  String toString() => jsonEncode(toJson());

///The method [copyWith] will copy [Query] into a new object, changing the 
///variable values
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
