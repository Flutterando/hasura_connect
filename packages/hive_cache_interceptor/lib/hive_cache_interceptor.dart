library hive_cache_interceptor;

import 'package:hasura_cache_interceptor/hasura_cache_interceptor.dart';
import 'package:hive_cache_interceptor/src/hive_storage_service.dart';

class HiveCacheInterceptor extends CacheInterceptor {
  HiveCacheInterceptor([String boxName = "storage-box"]) : super(HiveStorageService(boxName));
}
