import 'package:example/app/modules/todo/domain/params/i_params.dart';

class CreateTaskParams implements IParams {
  final String description;
  CreateTaskParams({
    required this.description,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map.addAll({"description": description});
    return map;
  }
}
