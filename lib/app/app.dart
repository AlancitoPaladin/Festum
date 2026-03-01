import 'package:festum/core/theme/app_theme.dart';
import 'package:festum/features/home/views/home_view.dart';
import 'package:flutter/material.dart';

class FestumApp extends StatelessWidget {
  const FestumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Festum',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeView(),
    );
  }
}
