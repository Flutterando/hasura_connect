![image](coverage_badge.svg)

# Hasura Connect Package

Connect your Flutter/Dart apps to Hasura simply.

## What can he do

  The hasura_connect is designed to facilitate Hasura's integration with Flutter applications, leveraging the full power of Graphql.

- Use Query, Mutation and Subscriptions the easy way.
- Offline cache for Subscription and Mutation made from a Snapshot.
- Easy integration with leading dart providers (Provider, bloc_pattern).
- Pass your JWT Token easily if you are informed when it is invalid.

## Install

Add dependency in your pubspec.yaml file:
```
dependencies:
  hasura_connect:
```
or use Slidy:
```
slidy install hasura_connect
```

## Usage

A simple usage example:

```dart

//import
import 'package:hasura_connect/hasura_connect.dart';

String url = 'http://localhost:8080/v1/graphql';
HasuraConnect hasuraConnect = HasuraConnect(url);

```
You can encapsulate this instance into a BLoC class or directly into a Provider.

Create a document with Query:

```dart
//document
String docQuery = """
  query {
    authors {
        id
        email
        name
      }
  }
""";

```
Now just add the document to the "query" method of the HasuraConnect instance.

```dart
//get query
var r = await hasuraConnect.query(docQuery);

//OR USE MUTATION
var r = await hasuraConnect.mutation(docQuery);
```

## Subscriptions

Subscriptions will notify you each time you have a change to the searched items. Use the "hasuraConnect.subscription" method to receive a stream.

```dart
Snapshot snapshot = await hasuraConnect.subscription(docSubscription);
  snapshot.listen((data) {
    print(data);
  }).onError((err) {
    print(err);
  });

```

## Using variables

Variables maintain the integrity of Querys, see an example:

```dart

String docSubscription = """
  subscription algumaCoisa($limit:Int!){
    users(limit: $limit, order_by: {user_id: desc}) {
      id
      email
      name
    }
  }
""";

Snapshot snapshot = await hasuraConnect.subscription(docSubscription, variables: {"limit": 10});

//change values of variables for PAGINATIONS
snapshot.changeVariable({"limit": 20});

```

## INTERCEPTORS

This is a good strategy to control the flow of requests. With that we can create interceptors for logs or cache for example.
The community has already provided some interceptors for caching. Interceptors are highly customizable.

* [hive_cache_interceptor](https://pub.dev/packages/hive_cache_interceptor)
* [shared_preferences_cache_interceptor](https://pub.dev/packages/shared_preferences_cache_interceptor)
* [hasura_cache_interceptor](https://pub.dev/packages/hasura_cache_interceptor)



## Dispose

HasuraConnect provides a dispose() method for use in Provider or BlocProvider.
Subscription will start only when someone is listening, and when all listeners are closed HasuraConnect automatically disconnects.

Therefore, we only connect to Hasura when we are actually using it;

## Roadmap

This is currently our roadmap, please feel free to request additions/changes.

| Feature                                | Progress |
| :------------------------------------- | :------: |
| Queries                                |    ✅    |
| Mutations                              |    ✅    |
| Subscriptions                          |    ✅    |
| Change Variable in Subscriptions       |    ✅    |
| Auto-Reconnect                         |    ✅    |
| Dynamic JWT Token                      |    ✅    |
| bloc_pattern Integration               |    ✅    |
| Provider Integration                   |    ✅    |
| Variables                              |    ✅    |
| Cache Subscription                     |    ✅    |
| Cache Mutation                         |    ✅    |
| Cache Query                            |    ✅    |

## Features and bugs

Please send feature requests and bugs at the [issue tracker](https://github.com/Flutterando/hasura_connect/issues).

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).