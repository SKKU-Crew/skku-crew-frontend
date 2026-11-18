import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'data/state/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final controller = AppController();
  await controller.init(initialMemberId: 1);
  runApp(SkkuCrewApp(controller: controller));
}
