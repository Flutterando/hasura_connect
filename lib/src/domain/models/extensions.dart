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
