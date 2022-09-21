library shared_preferences_cache_interceptor;

import 'package:hasura_cache_interceptor/hasura_cache_interceptor.dart';
import 'package:shared_preferences_cache_interceptor/src/shared_preferences_storage_service.dart';

///Class [SharedPreferencesCacheInterceptor]
///builds the class and calls the constructor [SharedPreferencesStorageService]
class SharedPreferencesCacheInterceptor extends CacheInterceptor {
  ///[SharedPreferencesCacheInterceptor] constructor
  SharedPreferencesCacheInterceptor()
      : super(SharedPreferencesStorageService());
}
