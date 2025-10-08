import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:mini_catalog/app/app.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}
