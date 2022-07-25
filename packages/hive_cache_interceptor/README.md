# Hive Cache Interceptor

Hasura Connect Cache Interceptor using a [hive package](https://pub.dev/packages/hive)

## How to use
pubspec.yaml
```yaml
dependencies:
  hasura_connect: <last version>
  hive_cache_interceptor: <last version>
```

yourfile.dart
```dart
import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_hive_cache_interceptor/hasura_hive_cache_interceptor.dart';

final cacheInterceptor = HiveCacheInterceptor("<your box name> (optional)");
final hasura = HasuraConnect(
  "<your hasura url>",
  interceptors: [cacheInterceptor],
  httpClient: httpClient,
)
```