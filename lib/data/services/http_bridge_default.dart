import 'dart:async';

import 'http_bridge_stub.dart';

Future<HttpBridgeResponse> sendHttpRequest({
  required String method,
  required String url,
  required Map<String, String> headers,
  String? body,
}) {
  return Future.error(UnsupportedError('HTTP bridge not supported on this platform'));
}

Future<bool> openExternalUrl(String url) async => false;
