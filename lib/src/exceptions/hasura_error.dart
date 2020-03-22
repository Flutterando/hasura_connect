class HasuraError implements Exception {
  final String message;
  final Extensions extensions;
  final Exception exception;

  HasuraError(this.message, this.extensions, [this.exception]);

  factory HasuraError.fromException(String message, Exception _exception) =>
      HasuraError(message, null, _exception);

  factory HasuraError.fromJson(Map json) =>
      HasuraError(json['message'], Extensions.fromJson(json['extensions']));

  @override
  String toString() => 'HasuraError: $message';
}

class Extensions {
  final dynamic path;
  final dynamic code;

  Extensions(this.path, this.code);

  factory Extensions.fromJson(Map json) {
    return Extensions(json['path'], json['code']);
  }

  @override
  String toString() {
    return 'path: $path, code: $code';
  }
}
