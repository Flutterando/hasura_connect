# Shared Preferences Cache Interceptor

Hasura Connect Cache Interceptor using [shared_preferences package](https://pub.dev/packages/shared_preferences)

## How to use
pubspec.yaml
```yaml
dependencies:
  hasura_connect: <last version>
  shared_preferences_cache_interceptor: <last version>
```

yourfile.dart
```dart
import 'package:hasura_connect/hasura_connect.dart';
import 'package:shared_preferences_cache_interceptor/shared_preferences_cache_interceptor.dart';

final cacheInterceptor = SharedPreferencesCacheInterceptor();
final hasura = HasuraConnect(
  "<your hasura url>",
  interceptors: [cacheInterceptor],
  httpClient: httpClient,
)
```