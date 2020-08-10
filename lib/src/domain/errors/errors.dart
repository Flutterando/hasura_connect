import 'package:hasura_connect/src/domain/models/extensions.dart';

abstract class HasuraError implements Exception {
  final String message;
  const HasuraError(this.message);
}

class HasuraRequestError extends HasuraError {
  final Extensions extensions;
  final Exception exception;

  const HasuraRequestError(String message, this.extensions, [this.exception])
      : super(message);

  factory HasuraRequestError.fromException(
          String message, Exception _exception) =>
      HasuraRequestError(message, null, _exception);

  factory HasuraRequestError.fromJson(Map json) => HasuraRequestError(
      json['message'], Extensions.fromJson(json['extensions']));

  @override
  String toString() => 'HasuraError: $message';
}

class DatasourceError extends HasuraError {
  const DatasourceError(String message) : super(message);
  @override
  String toString() => 'DatasourceError: $message';
}

class InvalidRequestError extends HasuraError {
  const InvalidRequestError(String message) : super(message);

  @override
  String toString() => 'InvalidRequestError: $message';
}

class ConnectionError extends HasuraError {
  const ConnectionError(String message) : super(message);

  @override
  String toString() => 'ConnectionError: $message';
}

class InterceptorError extends HasuraError {
  const InterceptorError(String message) : super(message);

  @override
  String toString() => 'InterceptorError: $message';
}
