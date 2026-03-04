import 'package:festum/app/router/app_router.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FestumApp extends StatelessWidget {
  const FestumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Festum',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: locator<AppRouter>().router,
    );
  }
}
