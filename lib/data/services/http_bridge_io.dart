import 'dart:convert';
import 'dart:io';

import 'http_bridge_stub.dart';

Future<HttpBridgeResponse> sendHttpRequest({
  required String method,
  required String url,
  required Map<String, String> headers,
  String? body,
}) async {
  final client = HttpClient()
    ..connectionTimeout = const Duration(milliseconds: 1800);
  try {
    final uri = Uri.parse(url);
    final req = await client.openUrl(method, uri);
    headers.forEach((key, value) {
      req.headers.set(key, value);
    });
    if (body != null && body.isNotEmpty) {
      req.write(body);
    }
    final res = await req.close().timeout(const Duration(seconds: 4));
    final text = await res.transform(utf8.decoder).join();
    return HttpBridgeResponse(statusCode: res.statusCode, body: text);
  } finally {
    client.close(force: true);
  }
}

Future<bool> openExternalUrl(String url) async => false;
