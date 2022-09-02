library hive_cache_interceptor;

import 'package:hasura_cache_interceptor/hasura_cache_interceptor.dart';
import 'package:hive_cache_interceptor/src/hive_storage_service.dart';

///Class [HiveCacheInterceptor]
class HiveCacheInterceptor extends CacheInterceptor {
  ///[HiveCacheInterceptor] constructor, receiveis a [boxName] and
  ///pass it to [HiveStorageService]
  HiveCacheInterceptor([String boxName = 'storage-box'])
      : super(HiveStorageService(boxName));
}
