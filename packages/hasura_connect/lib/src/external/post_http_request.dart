import 'dart:convert';

import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/infra/datasources/request_datasource.dart';
import 'package:http/http.dart' as http;

///Class [PostHttpRequest] implements the interface [RequestDatasource]
///implements the [post] method:
///Opens a try/catch bloc, tries to receive the response of method [post]
///from client, if the response status code is 200, it creates a [Map] json
///and [jsonDecode] the response's body, if there is a key errors in the json,
///throws a [HasuraRequestError.fromJson] parsing the errors and the request
///returns a [Response] with data, status code and request
class PostHttpRequest implements RequestDatasource {
  ///creates a function [clientFactory] type [http.Client]
  final http.Client Function() clientFactory;

  ///[PostHttpRequest] constructor
  PostHttpRequest(this.clientFactory);

  @override
  Future<Response> post({required Request request}) async {
    final client = clientFactory();
    try {
      final response = await client.post(
        Uri.parse(request.url),
        body: request.query.toString(),
        headers: request.headers,
      );
      if (response.statusCode == 200) {
        final Map json = response.body;
        if (json.containsKey('errors')) {
          throw HasuraRequestError.fromJson(
            json['errors'][0],
            request: request,
          );
        }
        return Response(
          data: json,
          statusCode: response.statusCode,
          request: request,
        );
      } else {
        throw ConnectionError('Connection Rejected', request: request);
      }
    } finally {
      client.close();
    }
  }
}
