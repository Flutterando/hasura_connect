///Class [Extensions]
///converts the json value received with the [Extensions.fromJson] object
class Extensions {
  ///[path] variable
  final dynamic path;

  ///[code] variable
  final dynamic code;

  ///[Extensions] class constructor
  Extensions(this.path, this.code);

  /// [Extensions.fromJson] object, resposible for converting the json received
  factory Extensions.fromJson(Map json) {
    return Extensions(json['path'], json['code']);
  }
}
