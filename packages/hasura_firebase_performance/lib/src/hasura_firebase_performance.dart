import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:hasura_connect/hasura_connect.dart';

///Class [HasuraFirebasePerformanceInterceptor]
///implements the [onRequest] method.
class HasuraFirebasePerformanceInterceptor extends InterceptorBase {
  /// [HasuraFirebasePerformanceInterceptor] constructor 
  HasuraFirebasePerformanceInterceptor();

  final _mapMetric = <int, HttpMetric>{};

///Receives a request and a [HasuraConnect] builds and starts a 
///[HttpMetric]. it returns an [onRequest].
  @override
  Future onRequest(Request request, HasuraConnect connect) async {
    try {
      final metric = FirebasePerformance.instance.newHttpMetric(
        request.url.replaceAll('_', '-'),
        HttpMethod.Post,
      )..requestPayloadSize = request.query.document.length;
      final size = request.query.document.indexOf('{');
      metric.putAttribute(
        'query',
        request.query.document.substring(0, size > 39 ? 39 : size),
      );
      _mapMetric[request.query.hashCode] = metric;
      await metric.start();
    } catch (e, stackTrace) {
      debugPrintStack(
        label: e.toString(),
        stackTrace: stackTrace,
      );
    }
    return super.onRequest(request, connect);
  }

  @override
  Future onResponse(Response data, HasuraConnect connect) async {
    try {
      final metric = _mapMetric[data.request.query.hashCode];
      metric?.httpResponseCode = data.statusCode;
      metric?.responsePayloadSize = data.data.toString().length;
      await metric?.stop();
      _mapMetric.remove(data.request.query.hashCode);
    } catch (e, stackTrace) {
      debugPrintStack(
        label: e.toString(),
        stackTrace: stackTrace,
      );
    }
    return super.onResponse(data, connect);
  }

  @override
  Future onError(HasuraError error, HasuraConnect connect) async {
    try {
      final metric = _mapMetric[error.request.query.hashCode];
      metric?.httpResponseCode = 500;
      await metric?.stop();
      _mapMetric.remove(error.request.query.hashCode);
    } catch (e, stackTrace) {
      debugPrintStack(
        label: e.toString(),
        stackTrace: stackTrace,
      );
    }
    return super.onError(error, connect);
  }
}
