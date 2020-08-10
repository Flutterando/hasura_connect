import 'dart:convert';

const stringJsonReponse = ''' 
{
  "data": {
    "author": [
      {
        "id": 3,
        "name": "Sidney"
      }
    ]
  }
}
''';

String get jsonReponse => jsonDecode(stringJsonReponse);
