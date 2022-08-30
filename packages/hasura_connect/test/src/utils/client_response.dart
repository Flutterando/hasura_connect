// ignore_for_file: leading_newlines_in_multiline_strings,
// unnecessary_raw_strings

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
}''';

String get jsonReponse => jsonDecode(stringJsonReponse);
