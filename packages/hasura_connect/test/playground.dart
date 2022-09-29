// ignore_for_file: avoid_print

import 'package:hasura_connect/src/core/interceptors/log_interceptor.dart';
import 'package:hasura_connect/src/di/module.dart';
import 'package:hasura_connect/src/presenter/hasura_connect_base.dart';

const document = '''
  subscription getBooks {
  books {
    id
    name
  }
}

   ''';
Future main() async {
  print('start');
  startModule();
  const url = 'https://bwolfdev.herokuapp.com/v1/graphql';

  final connect = HasuraConnect(
    url,
    interceptors: [LogInterceptor()],
  );
  final snapshot = await connect.subscription(document);
  final snapshot2 = await connect.subscription(document);
  final snapshot3 = await connect.subscription(document);
  final snapshot4 = await connect.subscription(document);
  final subscription = snapshot.listen(print);
  final subscription2 = snapshot2.listen(print);
  final subscription3 = snapshot3.listen(print);
  final subscription4 = snapshot4.listen(print);

  subscription.onError(print);
  subscription2.onError(print);
  await Future.delayed(const Duration(seconds: 5));
  snapshot.close();
  snapshot2.close();
  snapshot3.close();
  snapshot4.close();
  await subscription.cancel();
  await subscription2.cancel();
  await subscription3.cancel();
  await subscription4.cancel();
}
