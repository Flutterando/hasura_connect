import 'package:hasura_connect/src/core/interceptors/log_interceptor.dart';
import 'package:hasura_connect/src/di/module.dart';
import 'package:hasura_connect/src/presenter/hasura_connect_base.dart';

final document = '''
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
  final url = 'https://bwolfdev.herokuapp.com/v1/graphql';

  final connect = HasuraConnect(url, interceptors: [LogInterceptor()]);
  final snapshot = await connect.subscription(document);
  final snapshot2 = await connect.subscription(document);
  final subscription = snapshot.listen(print);
  final subscription2 = snapshot2.listen(print);

  subscription.onError(print);
  subscription2.onError(print);
  await Future.delayed(Duration(seconds: 5));
  snapshot.close();
  snapshot2.close();
}
