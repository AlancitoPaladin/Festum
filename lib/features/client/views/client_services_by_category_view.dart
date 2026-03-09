import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/widgets/client_shell_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientServicesByCategoryView extends StatelessWidget {
  const ClientServicesByCategoryView({required this.category, super.key});

  final ClientServiceCategory category;

  @override
  Widget build(BuildContext context) {
    final List<ClientServiceItem> services =
        ClientServiceCatalog.servicesByCategory(category);

    return ClientShellScaffold(
      currentTab: ClientTab.services,
      title: category.title,
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        itemCount: services.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          final ClientServiceItem item = services[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: AppColors.secondaryButton.withValues(
                  alpha: 0.35,
                ),
                child: Icon(category.icon, color: AppColors.activeIcon),
              ),
              title: Text(item.name),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                context.go(
                  AppRoutes.clientServiceDetails(
                    category: category.slug,
                    serviceId: item.id,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
