// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'http_bridge_stub.dart';

Future<HttpBridgeResponse> sendHttpRequest({
  required String method,
  required String url,
  required Map<String, String> headers,
  String? body,
}) {
  final completer = Completer<HttpBridgeResponse>();
  final req = html.HttpRequest();
  req.open(method, url);
  req.timeout = 3500;
  headers.forEach((key, value) {
    req.setRequestHeader(key, value);
  });
  req.onLoadEnd.listen((_) {
    if (completer.isCompleted) return;
    final status = req.status ?? 0;
    if (status == 0) {
      completer.completeError(Exception('Network connection failed'));
    } else {
      completer.complete(
        HttpBridgeResponse(
          statusCode: status,
          body: req.responseText ?? '',
        ),
      );
    }
  });
  req.onTimeout.listen((_) {
    if (!completer.isCompleted) {
      completer.completeError(TimeoutException('Request timed out'));
    }
  });
  req.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.completeError(Exception('Network error'));
    }
  });
  req.send(body);
  return completer.future;
}

Future<bool> openExternalUrl(String url) async {
  html.window.open(url, '_blank');
  return true;
}
