import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/auth_state_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProviderHomeView extends StatelessWidget {
  const ProviderHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedor'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await locator<AuthStateService>().signOut();
              if (!context.mounted) {
                return;
              }
              context.go(AppRoutes.login);
            },
            child: const Text('Salir'),
          ),
        ],
      ),
      body: const Center(
        child: Text('Pantalla principal de proveedor.'),
      ),
    );
  }
}
