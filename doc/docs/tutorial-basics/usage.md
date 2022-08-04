---
sidebar_position: 3
---

# Usage

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
