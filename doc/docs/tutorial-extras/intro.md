---
sidebar_position: 1
---

# Intro

## Official Implementations

- Using Shared Preferences [[shared_preferences_cache_interceptor]](https://pub.dev/packages/shared_preferences_cache_interceptor)
- Using Hive [[hasura_hive_cache_interceptor]](https://pub.dev/packages/hive_cache_interceptor)
- [[others]](https://pub.dev/packages?q=dependency%3hasura_cache_interceptor)

## In Memory Cache (without persistence)

pubspec.yaml

```yaml
dependencies:
  hasura_connect: <last version>
  hasura_cache_interceptor: <last version>
```

you_file.dart

```dart
import 'package:hasura_cache_interceptor/hasura_hive_cache_interceptor.dart';

final storage = MemoryStorageService();
final cacheInterceptor = CacheInterceptor(storage);
final hasura = HasuraConnect(
  "<your hasura url>",
  interceptors: [cacheInterceptor],
  httpClient: httpClient,
)
```
