import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/widgets/client_shell_scaffold.dart';
import 'package:flutter/material.dart';

class ClientOrdersView extends StatelessWidget {
  const ClientOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> orders = <String>[
      'Orden #FST-2109 - Banquete Signature',
      'Orden #FST-2110 - Salón Norte Imperial',
      'Orden #FST-2114 - Set Lounge Moderno',
    ];

    return ClientShellScaffold(
      currentTab: ClientTab.orders,
      title: 'Mis órdenes',
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        itemCount: orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_rounded),
              title: Text(orders[index]),
              subtitle: Text(
                'Estado: En proceso • Total estimado: \$${(18000 + index * 4200)} MXN',
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.secondaryText,
              ),
            ),
          );
        },
      ),
    );
  }
}
