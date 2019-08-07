class HasuraError implements Exception {
  final String message;
  final Extensions extensions;

  HasuraError(this.message, this.extensions);

  factory HasuraError.fromJson(Map json) {
    return HasuraError(
        json["message"], Extensions.fromJson(json["extensions"]));
  }

  @override 
  String toString() {
    return "HasuraError: $message";
  }

}

class Extensions {
  final dynamic path;
  final dynamic code;

  Extensions(this.path, this.code);

  factory Extensions.fromJson(Map json) {
    return Extensions(json["path"], json["code"]);
  }

  @override 
  String toString() {
    return "path: $path, code: $code";
  }

}
