import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_connect/src/domain/models/extensions.dart';

final _request = Request(url: '', query: const Query(document: ''));

///Abstract class [HasuraError] implements [Exception]
///interface for Hasura related errors.
abstract class HasuraError implements Exception {
  ///Variable [message] type [String]
  final String message;

  ///Variable [request] type [Request]

  final Request request;

  ///[HasuraError] constructor
  const HasuraError(this.message, {required this.request});
}

///Class [HasuraRequestError]
///Responsible for hasura request errors
class HasuraRequestError extends HasuraError {
  ///Variable [extensions] type [Extensions]

  final Extensions? extensions;

  ///Variable [exception] type [Exception]

  final Exception? exception;

  ///[HasuraRequestError] constructor
  const HasuraRequestError(
    String message,
    this.extensions, {
    this.exception,
    required Request request,
  }) : super(message, request: request);

  ///Method [HasuraRequestError.fromException]
  ///receives the [message], exception and [request] of an Exception error.
  factory HasuraRequestError.fromException(
    String message,
    Exception? _exception, {
    required Request request,
  }) =>
      HasuraRequestError(
        message,
        null,
        exception: _exception,
        request: request,
      );

  ///Method [HasuraRequestError.fromJson]
  ///Receives a [json] and a required [request]
  ///Converts the error received in json format to a [HasuraRequestError]
  ///Overrides [toString] as a HasuraRequestError error with the message
  ///received
  factory HasuraRequestError.fromJson(Map json, {required Request request}) =>
      HasuraRequestError(
        json['message'] ?? '',
        json['extensions'] == null
            ? null
            : Extensions.fromJson(json['extensions']),
        request: request,
      );

  @override
  String toString() => 'HasuraRequestError: $message';
}

///Class [DatasourceError]
///Responsible for hasura Datasource errors
///Overrides [toString] as a DatasourceError error with the message
///received
class DatasourceError extends HasuraError {
  ///[DatasourceError] constructor
  DatasourceError(String message, {required Request request})
      : super(message, request: request);
  @override
  String toString() => 'DatasourceError: $message';
}

///Class [InvalidRequestError]
///Responsible for hasura InvalidRequestError errors
///Overrides [toString] as a DatasourceError error with the message
///received
class InvalidRequestError extends HasuraError {
  ///[InvalidRequestError] constructor

  InvalidRequestError(String message) : super(message, request: _request);

  @override
  String toString() => 'InvalidRequestError: $message';
}

///Class [ConnectionError]
///Responsible for hasura ConnectionError errors
///Overrides [toString] as a DatasourceError error with the message
///received
class ConnectionError extends HasuraError {
  ///[ConnectionError] constructor

  const ConnectionError(String message, {required Request request})
      : super(message, request: request);

  @override
  String toString() => 'ConnectionError: $message';
}

///Class [InterceptorError]
///Responsible for hasura InterceptorError errors
///Overrides [toString] as a DatasourceError error with the message
///received
class InterceptorError extends HasuraError {
  ///[InterceptorError] constructor

  InterceptorError(String message) : super(message, request: _request);

  @override
  String toString() => 'InterceptorError: $message';
}
