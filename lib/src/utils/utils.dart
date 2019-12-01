import 'dart:convert';
import 'dart:math';

String randomString(int length) {
  var rand = Random();
  var codeUnits = List.generate(length, (index) {
    return rand.nextInt(33) + 89;
  });

  return String.fromCharCodes(codeUnits);
}

String generateBase(String query) {
  query = query.replaceAll(RegExp("[^a-zA-Z0-9 -]"), "").replaceAll(" ", "");
  var bytes = utf8.encode(query);
  var base64Str = base64.encode(bytes);
  return base64Str;
}

String generateBaseJson(Map json) {
  if (json != null) {
    return generateBase(jsonEncode(json));
  } else {
    return "";
  }
}
