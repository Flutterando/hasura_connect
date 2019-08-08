# Hasura Connect Package

Connect your Flutter/Dart apps to Hasura simply.

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

Crie um documento com a Query:
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
var r = await hasuraConnect.query(docQuery);
print(r);

```

## Subscriptions

Subscriptions will notify you each time you have a change to the searched items. Use the "hasuraConnect.subscription" method to receive a stream.

```dart
Snapshot snap = hasuraConnect.subscription(docSubscription);
  snap.stream.listen((data) {
    print(data);
  }).onError((err) {
    print(err);
  });

```
## Authorization (JWT Token)

[View Hasura's official Authorization documentation](https://docs.hasura.io/1.0/graphql/manual/auth/index.html).

```dart

  String url = 'http://localhost:8080/v1/graphql';
HasuraConnect hasuraConnect = HasuraConnect(url, token: () async {
  //sharedPreferences or other storage logic
  return "Bearer YOUR-JWT-TOKEN";
});

```


## Dispose

HasuraConnect provides a dispose () method for use in Provider or BlocProvider.
Subscription will start only when someone is listening, and when all listeners are closed HasuraConnect automatically disconnects.

Therefore, we only connect to Hasura when we are actually using it;

## Roadmap

This is currently our roadmap, please feel free to request additions/changes.

| Feature                  | Progress |
| :----------------------- | :------: |
| Queries                  |    ✅    |
| Mutations                |    🔜    |
| Subscriptions            |    ✅    |
| Auto-Reconnect           |    ✅    |
| Dynamic JWT Token        |    ✅    |
| bloc_pattern Integration |    ✅    |
| Provider Integration     |    ✅    |
| Variables                |    🔜    |
| Cache Intercept          |    🔜    |

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].
[tracker]: http://example.com/issues/replaceme

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
