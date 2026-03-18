import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/custom_app_bar.dart';
import 'package:festum/features/provider/viewmodels/provider_profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stacked/stacked.dart';

class ProviderProfileView extends StatelessWidget {
  const ProviderProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProviderProfileViewModel>.reactive(
      viewModelBuilder: () => ProviderProfileViewModel(locator()),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Mi Perfil'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildProfileHeader(model),
              const SizedBox(height: 32),
              _buildMenuSection(context, model),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProviderProfileViewModel model) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=jair'),
        ),
        const SizedBox(height: 16),
        Text(
          model.userName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryText),
        ),
        Text(
          model.userEmail,
          style: const TextStyle(fontSize: 14, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.appBar.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            model.businessName,
            style: const TextStyle(color: AppColors.appBar, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, ProviderProfileViewModel model) {
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
            icon: Icons.bar_chart_outlined,
            title: 'Generar reportes',
            onTap: model.generateReports,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Próximamente', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
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
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: Colors.black26),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Future<void> _logout(
    BuildContext context,
    ProviderProfileViewModel model,
  ) async {
    await model.logout();
    if (!context.mounted) {
      return;
    }

    context.go(AppRoutes.login);
  }
}
