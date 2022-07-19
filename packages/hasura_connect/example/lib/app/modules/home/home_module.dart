import 'package:flutter_modular/flutter_modular.dart';

import 'home_page.dart';
import 'home_store.dart';

class HomeModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => HomeStore(i())),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, args) => HomePage()),
  ];
}
