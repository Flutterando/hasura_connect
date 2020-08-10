import 'package:hasura_connect/src/core/interceptors/log_interceptor.dart';
import 'package:hasura_connect/src/di/module.dart';
import 'package:hasura_connect/src/presenter/hasura_connect_base.dart';

final document = '''
  subscription MyQuery {
  services {
    id
    name
    url_image
  }
}
   ''';
Future main() async {
  print('start');
  startModule();
  final url = 'https://bonus-net.herokuapp.com/v1/graphql';

  final connect = HasuraConnect(url, interceptors: [LogInterceptor()]);
  final snapshot = await connect.subscription(document);
  final subscription = snapshot.listen(print);

  subscription.onError(print);

  await Future.delayed(Duration(seconds: 10));
  snapshot.close();
  await Future.delayed(Duration(seconds: 10));
}
