library shared_preferences_cache_interceptor;

import 'package:hasura_cache_interceptor/hasura_cache_interceptor.dart';
import 'package:shared_preferences_cache_interceptor/src/shared_preferences_storage_service.dart';

class SharedPreferencesCacheInterceptor extends CacheInterceptor {
  SharedPreferencesCacheInterceptor() : super(SharedPreferencesStorageService());
}
