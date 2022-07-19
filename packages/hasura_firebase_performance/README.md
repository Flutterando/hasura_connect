# hasura_firebase_performance

Hasura connect Interceptor implementation that sends querys metric data to Firebase.

## Getting Started

![image](https://user-images.githubusercontent.com/41203980/126193454-20d67963-afea-47d4-89e3-4277997350db.png)

## Description

Hasura's Interceptor implementation that sends http request metric data to Firebase.

## Usage

```dart
 final _hasuraConnect = HasuraConnect();
 final hasuraPerformanceInterceptor = HasuraPerformanceInterceptor()
_hasuraConnect.interceptors.add(hasuraPerformanceInterceptor);
```

##### Issues and feedback 
Please file issues to send feedback or report a bug. Thank you!
