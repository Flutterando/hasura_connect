import 'dart:convert';
import 'dart:math';

class KeyGenerator {
  String randomString(int length) {
    final rand = Random();
    final codeUnits = List.generate(length, (index) {
      return rand.nextInt(33) + 89;
    });

    return String.fromCharCodes(codeUnits);
  }

  String generateBase(String query) {
    final _query =
        query.replaceAll(RegExp('[^a-zA-Z0-9 -]'), '').replaceAll(' ', '');
    final bytes = utf8.encode(_query);
    final base64Str = base64.encode(bytes);
    return base64Str;
  }
}
