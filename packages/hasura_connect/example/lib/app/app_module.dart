import 'package:flutter_modular/flutter_modular.dart';
import 'package:hasura_connect/hasura_connect.dart';

import 'modules/home/home_module.dart';

class AppModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton(
        (i) => HasuraConnect('https://bwolfdev.herokuapp.com/v1/graphql')),
  ];

  @override
  final List<ModularRoute> routes = [
    ModuleRoute('/', module: HomeModule()),
  ];
}
