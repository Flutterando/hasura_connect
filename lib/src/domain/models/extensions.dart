class Extensions {
  final dynamic path;
  final dynamic code;

  Extensions(this.path, this.code);

  factory Extensions.fromJson(Map json) {
    return Extensions(json['path'], json['code']);
  }
}
