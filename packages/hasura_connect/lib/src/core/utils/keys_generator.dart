import 'dart:convert';
import 'dart:math';

/// Class [KeyGenerator] is responsible for generating a
/// a key.
class KeyGenerator {
  ///The method [randomString] receives an [int]
  ///a variable [Random] is created and a [List] is created
  ///to create the [List], the [List.generate] is called, passing the
  ///lenght required. it returns the random using nextInt
  String randomString(int length) {
    final rand = Random();
    final codeUnits = List.generate(length, (index) {
      return rand.nextInt(33) + 89;
    });

    return String.fromCharCodes(codeUnits);
  }

  ///The method [generateBase] receives a [String], creates a private variable
  ///_query. this variable will receive the query string converted using the
  ///regex value expecified and removing the spaces.
  ///The new query value will be converted to bytes using [utf8] encode and
  ///thrown into a new variable.
  ///these bytes will be converted do [base64] and thrown into a new variable.
  ///the method returns the base64Str variable.

  String generateBase(String query) {
    final _query =
        query.replaceAll(RegExp('[^a-zA-Z0-9 -]'), '').replaceAll(' ', '');
    final bytes = utf8.encode(_query);
    final base64Str = base64.encode(bytes);
    return base64Str;
  }
}
