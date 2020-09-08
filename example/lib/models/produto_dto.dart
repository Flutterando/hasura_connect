import 'dart:convert';

class ProdutoDto {
  final int id;
  final String description;

  ProdutoDto({
    this.id,
    this.description,
  });

  ProdutoDto copyWith({
    int id,
    String description,
  }) {
    return ProdutoDto(
      id: id ?? this.id,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
    };
  }

  factory ProdutoDto.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ProdutoDto(
      id: map['id'],
      description: map['description'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ProdutoDto.fromJson(String source) =>
      ProdutoDto.fromMap(json.decode(source));

  static List<ProdutoDto> fromJsonList(List list) {
    if (list == null) return null;
    return list.map<ProdutoDto>((item) => ProdutoDto.fromMap(item)).toList();
  }

  @override
  String toString() => 'ProdutoDto(id: $id, description: $description)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ProdutoDto && o.id == id && o.description == description;
  }

  @override
  int get hashCode => id.hashCode ^ description.hashCode;
}
