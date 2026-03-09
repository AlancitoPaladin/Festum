import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/widgets/client_shell_scaffold.dart';
import 'package:flutter/material.dart';

class ClientCartView extends StatelessWidget {
  const ClientCartView({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> cartItems = <String>[
      'Salón Aurora',
      'Pista y Periqueras LED',
      'Mesa Dulce y Postres',
    ];

    return ClientShellScaffold(
      currentTab: ClientTab.cart,
      title: 'Carrito de órdenes',
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        itemCount: cartItems.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          if (index == cartItems.length) {
            return Card(
              color: AppColors.cardAccent,
              child: ListTile(
                title: const Text('Total estimado'),
                subtitle: const Text('Incluye servicios seleccionados'),
                trailing: Text(
                  '\$78,300 MXN',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.activeIcon,
                  ),
                ),
              ),
            );
          }

          return Card(
            child: ListTile(
              leading: const Icon(Icons.shopping_bag_rounded),
              title: Text(cartItems[index]),
              subtitle: const Text('Cantidad: 1'),
              trailing: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.alert,
              ),
            ),
          );
        },
      ),
    );
  }
}
