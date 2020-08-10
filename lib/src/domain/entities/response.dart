class Response {
  final Map data;
  final int statusCode;

  const Response({this.data, this.statusCode});

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Response && o.data == data && o.statusCode == statusCode;
  }

  @override
  int get hashCode => data.hashCode ^ statusCode.hashCode;
}
