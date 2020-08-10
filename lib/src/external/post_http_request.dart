import 'dart:convert';
import 'dart:io';

import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/entities/response.dart';
import 'package:hasura_connect/src/infra/datasources/request_datasource.dart';
import 'package:http/http.dart' as http;

class PostHttpRequest implements RequestDatasource {
  final http.Client client;

  PostHttpRequest(this.client);

  @override
  Future<Response> post({Request request}) async {
    try {
      var response = await client.post(request.url,
          body: request.query.toString(), headers: request.headers);
      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);
        if (json.containsKey('errors')) {
          throw HasuraRequestError.fromJson((json['errors'][0]));
        }
        return Response(data: json, statusCode: response.statusCode);
      } else {
        throw const ConnectionError('Connection Rejected');
      }
    } on SocketException {
      throw const ConnectionError('Verify your internet connection');
    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }
  }
}
