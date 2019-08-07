# Hasura Connect Package

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Install

:)


## Usage

A simple usage example:

```dart
import 'package:hasura_connect/hasura_connect.dart';

HasuraConnect conn = HasuraConnect('http://localhost:8080/v1/graphql');

//document
String docQuery = """
  query {
    authors {
        id2
        email
        name
      }
  }
""";

//query
var r = await conn.query(docQuery);
print(r);


```

## Subscriptions

A simple usage example:

```dart
HasuraConnect conn = HasuraConnect('http://localhost:8080/v1/graphql');

String docSubscription = """
  subscription {
    authors {
        id
        email
        name
      }
  }
""";

Snapshot snap = conn.subscription(docSubscription);
  snap.stream.listen((data) {
    print(data);
  }).onError((err) {
    print(err);
  });

```

## Dispose

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
