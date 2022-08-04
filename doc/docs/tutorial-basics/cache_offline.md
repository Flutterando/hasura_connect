---
sidebar_position: 8
---

# Cache Offline

Now you will need to create a Interceptor or use a Cache Interceptor Package made to help you like: [InMemory](https://pub.dev/packages/hasura_cache_interceptor) , [Hive](https://pub.dev/packages/hive_cache_interceptor) or [SharedPreference](https://pub.dev/packages/shared_preferences_cache_interceptor)

```dart
//In Memory
import 'package:hasura_cache_interceptor/hasura_hive_cache_interceptor.dart';

final storage = MemoryStorageService();
final cacheInterceptor = CacheInterceptor(storage);
final hasura = HasuraConnect(
  "<your hasura url>",
  interceptors: [cacheInterceptor],
  httpClient: httpClient,
)
```

```dart
//Hive
import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_hive_cache_interceptor/hasura_hive_cache_interceptor.dart';

final cacheInterceptor = HiveCacheInterceptor("<your box name> (optional)");
final hasura = HasuraConnect(
  "<your hasura url>",
  interceptors: [cacheInterceptor],
  httpClient: httpClient,
)
```

```dart
//Shared Preference
import 'package:hasura_connect/hasura_connect.dart';
import 'package:shared_preferences_cache_interceptor/shared_preferences_cache_interceptor.dart';

final cacheInterceptor = SharedPreferencesCacheInterceptor();
final hasura = HasuraConnect(
  "<your hasura url>",
  interceptors: [cacheInterceptor],
  httpClient: httpClient,
)

```
