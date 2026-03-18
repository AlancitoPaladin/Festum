import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/custom_app_bar.dart';
import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/viewmodels/my_services_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stacked/stacked.dart';

class MyServicesView extends StatelessWidget {
  final bool showAppBar;
  const MyServicesView({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MyServicesViewModel>.reactive(
      viewModelBuilder: () => MyServicesViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: showAppBar ? const CustomAppBar(title: 'Mis servicios') : null,
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Administra los servicios que ofreces',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _AddServiceButton(onTap: () {
                context.push(AppRoutes.providerCreateService);
              }),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: model.services.length,
                itemBuilder: (context, index) {
                  final service = model.services[index];
                  return _ServiceCard(
                    service: service,
                    onToggle: () => model.toggleServiceStatus(index),
                    onDelete: () => model.deleteService(index),
                    onManage: () {
                      context.push(
                        AppRoutes.providerManageServiceRoute(
                          service.name,
                          service.category.name,
                        ),
                      );
                    },
                    onEdit: () {
                      context.push(
                        AppRoutes.providerEditServiceRoute(
                          service.id,
                          service.name,
                          service.category.name,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddServiceButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddServiceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.secondaryText),
            SizedBox(width: 8),
            Text(
              'Añadir nuevo servicio',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ProviderService service;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onManage;
  final VoidCallback onEdit;

  const _ServiceCard({
    required this.service,
    required this.onToggle,
    required this.onDelete,
    required this.onManage,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIcon(service.category), color: AppColors.appBar, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Categoría: ${service.category.label}',
                      style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: AppColors.secondaryText),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onManage,
                  icon: const Icon(Icons.description_outlined, size: 18, color: Colors.white),
                  label: const Text('Gestionar servicio', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appBar,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryText),
                  label: const Text('Editar servicio', style: TextStyle(color: AppColors.primaryText, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: service.isActive ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                service.isActive ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color: service.isActive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Switch.adaptive(
                value: service.isActive,
                onChanged: (_) => onToggle(),
                activeTrackColor: AppColors.appBar,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.dj:
        return Icons.music_note_outlined;
      case ServiceCategory.furniture:
        return Icons.chair_outlined;
      case ServiceCategory.banquet:
        return Icons.restaurant_outlined;
      case ServiceCategory.venue:
        return Icons.business_outlined;
      default:
        return Icons.star_outline;
    }
  }
}
