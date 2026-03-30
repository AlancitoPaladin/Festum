import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/app_remote_image.dart';
import 'package:festum/core/widgets/custom_app_bar.dart';
import 'package:festum/features/provider/usecases/get_provider_business_profile_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_services_use_case.dart';
import 'package:festum/features/provider/viewmodels/provider_profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stacked/stacked.dart';

class ProviderProfileView extends StatelessWidget {
  const ProviderProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProviderProfileViewModel>.reactive(
      viewModelBuilder: () => ProviderProfileViewModel(
        locator<GetProviderBusinessProfileUseCase>(),
        locator<GetProviderServicesUseCase>(),
        locator(),
        locator(),
        locator(),
        locator(),
        locator(),
      ),
      onViewModelReady: (ProviderProfileViewModel model) => model.initialise(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Mi perfil'),
        body: RefreshIndicator(
          onRefresh: model.initialise,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              if (model.errorMessage != null && !model.hasContent) ...[
                _buildErrorState(model),
                const SizedBox(height: 24),
              ],
              _buildProfileHeader(model),
              const SizedBox(height: 24),
              _buildServicesSection(model),
              const SizedBox(height: 24),
              _buildMenuSection(context, model),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProviderProfileViewModel model) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12.withValues(alpha: 0.04)),
            ),
            child: ClipOval(
              child: model.logoUrl.isEmpty
                  ? const Icon(
                      Icons.storefront_outlined,
                      size: 44,
                      color: AppColors.secondaryText,
                    )
                  : AppRemoteImage(
                      imageUrl: model.logoUrl,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        color: AppColors.backgroundElevated,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.storefront_outlined,
                          size: 44,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            model.businessName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 10),
          _InfoChip(
            icon: Icons.location_on_outlined,
            text: model.locationLabel,
          ),
          const SizedBox(height: 8),
          _InfoChip(
            icon: Icons.calendar_today_outlined,
            text: model.memberSinceLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(ProviderProfileViewModel model) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Servicios registrados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          if (model.isBusy && model.serviceNames.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (model.serviceNames.isEmpty)
            const Text(
              'Aún no has registrado servicios.',
              style: TextStyle(color: AppColors.secondaryText),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: model.serviceNames
                  .map((String item) => _ServiceChip(label: item))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    ProviderProfileViewModel model,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.business_outlined,
            title: 'Información del negocio',
            onTap: () => context.push(AppRoutes.providerBusinessInfo),
          ),
          const Divider(height: 1, indent: 56, endIndent: 16),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Cerrar sesión',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _logout(context, model),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? AppColors.secondaryText),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.primaryText,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, size: 20, color: Colors.black26),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildErrorState(ProviderProfileViewModel model) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(model.errorMessage!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: model.initialise,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(
    BuildContext context,
    ProviderProfileViewModel model,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Deseas salir de tu sesión en este momento?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await model.logout();
    if (!context.mounted) {
      return;
    }

    context.go(AppRoutes.login);
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.secondaryText),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.appBar.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.appBar,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
