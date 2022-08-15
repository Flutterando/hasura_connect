import 'package:example/app/modules/todo/domain/params/i_params.dart';

class DeleteTaskParams implements IParams {
  final int id;
  DeleteTaskParams({
    required this.id,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map.addAll({"id": id});
    return map;
  }
}
