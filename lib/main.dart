import 'package:festum/app/app.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const FestumApp());
}
