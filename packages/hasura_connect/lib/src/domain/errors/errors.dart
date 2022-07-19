import 'package:hasura_connect/src/domain/models/extensions.dart';
import 'package:hasura_connect/src/domain/models/request.dart';

import '../../../hasura_connect.dart';
import '../models/query.dart';

final _request = Request(url: '', query: Query(document: ''));

abstract class HasuraError implements Exception {
  final String message;
  final Request request;
  const HasuraError(this.message, {required this.request});
}

class HasuraRequestError extends HasuraError {
  final Extensions? extensions;
  final Exception? exception;

  const HasuraRequestError(String message, this.extensions, {this.exception, required Request request}) : super(message, request: request);

  factory HasuraRequestError.fromException(
    String message,
    Exception? _exception, {
    required Request request,
  }) =>
      HasuraRequestError(message, null, exception: _exception, request: request);

  factory HasuraRequestError.fromJson(Map json, {required Request request}) => HasuraRequestError(
        json['message'] ?? '',
        json['extensions'] == null ? null : Extensions.fromJson(json['extensions']),
        request: request,
      );

  @override
  String toString() => 'HasuraRequestError: $message';
}

class DatasourceError extends HasuraError {
  DatasourceError(String message, {required Request request}) : super(message, request: request);
  @override
  String toString() => 'DatasourceError: $message';
}

class InvalidRequestError extends HasuraError {
  InvalidRequestError(String message) : super(message, request: _request);

  @override
  String toString() => 'InvalidRequestError: $message';
}

class ConnectionError extends HasuraError {
  const ConnectionError(String message, {required Request request}) : super(message, request: request);

  @override
  String toString() => 'ConnectionError: $message';
}

class InterceptorError extends HasuraError {
  InterceptorError(String message) : super(message, request: _request);

  @override
  String toString() => 'InterceptorError: $message';
}
