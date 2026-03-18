import 'package:festum/app/router/app_router.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();

  final router = locator<AppRouter>().router;

  runApp(
    MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'PlusJakartaSans', // O la que use tu proyecto
      ),
    ),
  );
}
