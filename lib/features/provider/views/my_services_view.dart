import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/app_remote_image.dart';
import 'package:festum/core/widgets/custom_app_bar.dart';
import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/repositories/provider_services_repository.dart';
import 'package:festum/features/provider/usecases/get_provider_services_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_service_status_use_case.dart';
import 'package:festum/features/provider/viewmodels/my_services_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stacked/stacked.dart';

class MyServicesView extends StatelessWidget {
  const MyServicesView({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MyServicesViewModel>.reactive(
      viewModelBuilder: () => MyServicesViewModel(
        locator<GetProviderServicesUseCase>(),
        locator<UpdateProviderServiceStatusUseCase>(),
        locator<ProviderServicesRepository>(),
        locator<ProviderReactivityService>(),
      ),
      onViewModelReady: (MyServicesViewModel model) => model.initialise(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: showAppBar ? const CustomAppBar(title: 'Mis servicios') : null,
        body: _buildBody(context, model),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MyServicesViewModel model) {
    if (model.isBusy && model.services.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.errorMessage != null && model.services.isEmpty) {
      return _MyServicesErrorState(
        message: model.errorMessage!,
        onRetry: model.initialise,
      );
    }

    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Administra, publica e inactiva los servicios que ofreces.',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _AddServiceButton(
            onTap: () => _openCreateService(context, model),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: RefreshIndicator(
            onRefresh: model.initialise,
            child: model.services.isEmpty
                ? const _EmptyMyServicesState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: model.services.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ProviderService service = model.services[index];
                      return _ServiceCard(
                        service: service,
                        isMutating: model.isMutating(service.id),
                        onToggle: () => _toggleService(context, model, index),
                        onDelete: () => _deleteService(context, model, index),
                        onManage: () {
                          context.push(
                            AppRoutes.providerManageServiceRoute(
                              service.id,
                              service.name,
                              service.category.name,
                            ),
                          );
                        },
                        onEdit: () => _openEditService(context, model, service),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _openCreateService(
    BuildContext context,
    MyServicesViewModel model,
  ) async {
    await context.push<bool>(AppRoutes.providerCreateService);
  }

  Future<void> _openEditService(
    BuildContext context,
    MyServicesViewModel model,
    ProviderService service,
  ) async {
    await context.push<bool>(
      AppRoutes.providerEditServiceRoute(
        service.id,
        service.name,
        service.category.name,
      ),
    );
  }

  Future<void> _toggleService(
    BuildContext context,
    MyServicesViewModel model,
    int index,
  ) async {
    final ProviderService service = model.services[index];
    final bool willPublish = !service.isPublished;
    final bool confirmed = await _confirmStatusChange(
      context,
      service: service,
      willPublish: willPublish,
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final String? errorMessage = await model.toggleServiceStatus(index);
    if (!context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    if (errorMessage != null) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          willPublish
              ? 'Servicio publicado correctamente.'
              : 'Servicio inactivado correctamente.',
        ),
      ),
    );
  }

  Future<void> _deleteService(
    BuildContext context,
    MyServicesViewModel model,
    int index,
  ) async {
    final ProviderService service = model.services[index];
    final bool confirmed = await _confirmDeleteService(
      context,
      service: service,
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final String? errorMessage = await model.deleteService(index);
    if (!context.mounted) {
      return;
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Servicio eliminado.')));
  }

  Future<bool> _confirmDeleteService(
    BuildContext context, {
    required ProviderService service,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar servicio'),
          content: Text(
            '¿Quieres eliminar "${service.name}"? Esta acción no se puede deshacer.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<bool> _confirmStatusChange(
    BuildContext context, {
    required ProviderService service,
    required bool willPublish,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(willPublish ? 'Publicar servicio' : 'Inactivar servicio'),
          content: Text(
            willPublish
                ? 'Al publicar este servicio, los clientes podrán verlo en la app después de actualizar la información.'
                : 'Al inactivar este servicio, dejará de estar disponible para los clientes hasta que lo vuelvas a publicar.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(willPublish ? 'Publicar' : 'Inactivar'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}

class _MyServicesErrorState extends StatelessWidget {
  const _MyServicesErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.room_service_outlined,
              size: 34,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onRetry(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMyServicesState extends StatelessWidget {
  const _EmptyMyServicesState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            children: <Widget>[
              Icon(
                Icons.storefront_outlined,
                size: 36,
                color: AppColors.secondaryText,
              ),
              SizedBox(height: 14),
              Text(
                'Todavía no tienes servicios creados.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Crea uno como borrador, revísalo y publícalo cuando ya quieras mostrarlo en Cliente.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.secondaryText, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddServiceButton extends StatelessWidget {
  const _AddServiceButton({required this.onTap});

  final VoidCallback onTap;

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
          children: <Widget>[
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
  const _ServiceCard({
    required this.service,
    required this.isMutating,
    required this.onToggle,
    required this.onDelete,
    required this.onManage,
    required this.onEdit,
  });

  final ProviderService service;
  final bool isMutating;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onManage;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final _StatusPresentation status = _StatusPresentation.from(service);

    return Opacity(
      opacity: isMutating ? 0.72 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 68,
                    height: 68,
                    child: AppRemoteImage(
                      imageUrl: service.resolvedImageUrl,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        color: AppColors.backgroundElevated,
                        alignment: Alignment.center,
                        child: Icon(
                          _getIcon(service.category),
                          color: AppColors.appBar,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.subtitle,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          _StatusChip(status: status),
                          if (service.badge.trim().isNotEmpty)
                            _MiniPill(label: service.badge),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: isMutating ? null : onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.alert,
                  ),
                  tooltip: 'Eliminar servicio',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isMutating ? null : onManage,
                    icon: const Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Gestionar servicio',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appBar,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isMutating ? null : onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.primaryText,
                    ),
                    label: const Text(
                      'Editar servicio',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 12,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(child: _ServiceCardFooterInfo(service: service)),
                if (isMutating) ...<Widget>[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ] else ...<Widget>[
                  Switch.adaptive(
                    value: service.isPublished,
                    onChanged: (_) => onToggle(),
                    activeTrackColor: AppColors.appBar,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.furniture:
      case ServiceCategory.equipment:
        return Icons.chair_outlined;
      case ServiceCategory.banquet:
        return Icons.restaurant_outlined;
      case ServiceCategory.venue:
        return Icons.business_outlined;
      case ServiceCategory.dj:
        return Icons.music_note_outlined;
      case ServiceCategory.decoration:
        return Icons.celebration_outlined;
      case ServiceCategory.photography:
        return Icons.camera_alt_outlined;
      case ServiceCategory.entertainment:
        return Icons.theater_comedy_outlined;
    }
  }
}

class _ServiceCardFooterInfo extends StatelessWidget {
  const _ServiceCardFooterInfo({required this.service});

  final ProviderService service;

  @override
  Widget build(BuildContext context) {
    final (String primaryText, String? secondaryText) = _resolveTexts(service);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          primaryText,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (secondaryText != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            secondaryText,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  (String, String?) _resolveTexts(ProviderService service) {
    final bool hasPrice = service.unitPriceCents > 0;

    if (service.isPublished) {
      return hasPrice
          ? (service.priceLabel, null)
          : ('Precio por definir', null);
    }

    if (service.isInactive) {
      return (
        'Servicio inactivo',
        hasPrice ? service.priceLabel : 'Precio por definir',
      );
    }

    return (
      'Servicio no publicado',
      hasPrice ? service.priceLabel : 'Precio por definir',
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _StatusPresentation status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusPresentation {
  const _StatusPresentation({required this.label, required this.color});

  final String label;
  final Color color;

  factory _StatusPresentation.from(ProviderService service) {
    if (service.isPublished) {
      return const _StatusPresentation(label: 'Publicado', color: Colors.green);
    }
    if (service.isInactive) {
      return const _StatusPresentation(label: 'Inactivo', color: Colors.red);
    }
    return const _StatusPresentation(label: 'Borrador', color: Colors.orange);
  }
}
