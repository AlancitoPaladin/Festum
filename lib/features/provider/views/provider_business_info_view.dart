import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/custom_app_bar.dart';
import 'package:festum/features/provider/utils/provider_field_input.dart';
import 'package:festum/features/provider/viewmodels/provider_business_info_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:stacked/stacked.dart';

class ProviderBusinessInfoView extends StatelessWidget {
  const ProviderBusinessInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProviderBusinessInfoViewModel>.reactive(
      viewModelBuilder: () => ProviderBusinessInfoViewModel(locator()),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: model.isOnboardingRequired
              ? 'Completa tu negocio'
              : 'Perfil del negocio',
          showBackButton: !model.isOnboardingRequired,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información que verán los clientes sobre tu negocio.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
              ),
              const SizedBox(height: 32),
              
              const _SectionLabel(label: 'Logotipo del negocio'),
              const SizedBox(height: 16),
              _LogoUploadCard(onTap: model.pickLogo),
              
              const SizedBox(height: 32),
              const _SectionLabel(label: 'Información básica'),
              const SizedBox(height: 12),
              _CustomTextField(
                hintText: 'Ingrese nombre del negocio',
                onChanged: model.updateName,
                inputKind: ProviderFieldInputKind.title,
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: 'Ubicación',
                subtitle: model.businessInfo.location.isEmpty ? 'Ciudad principal donde trabajas' : model.businessInfo.location,
                trailing: const Icon(Icons.arrow_drop_down, color: AppColors.secondaryText),
                onTap: () {
                  // Aquí se podría abrir un selector de ciudad y llamar a model.updateLocation
                },
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: 'Área de cobertura',
                subtitle: model.businessInfo.coverageArea.isEmpty ? 'Ej: Teziutlán y municipios cercanos' : model.businessInfo.coverageArea,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _CustomTextField(
                hintText: 'Número de contacto',
                onChanged: model.updateContactNumber,
                keyboardType: TextInputType.phone,
                inputKind: ProviderFieldInputKind.phone,
              ),
              
              const SizedBox(height: 32),
              const _SectionLabel(label: 'Redes y contacto'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _SocialField(icon: Icons.phone_outlined, hint: 'WhatsApp', iconColor: Colors.green, onChanged: model.updateWhatsapp, inputKind: ProviderFieldInputKind.phone)),
                  const SizedBox(width: 12),
                  Expanded(child: _SocialField(icon: Icons.camera_alt_outlined, hint: '@instagram', iconColor: Colors.pink, onChanged: model.updateInstagram, inputKind: ProviderFieldInputKind.socialHandle)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _SocialField(icon: Icons.facebook, hint: 'Facebook', iconColor: Colors.blue, onChanged: model.updateFacebook, inputKind: ProviderFieldInputKind.socialHandle)),
                  const SizedBox(width: 12),
                  Expanded(child: _SocialField(icon: Icons.language, hint: 'Sitio web', iconColor: Colors.teal, onChanged: model.updateWebsite, inputKind: ProviderFieldInputKind.url)),
                ],
              ),
              
              const SizedBox(height: 32),
              const _SectionLabel(label: 'Fotos del negocio'),
              const SizedBox(height: 4),
              const Text(
                'Sube fotos de tu negocio o trabajos realizados',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _ImageUploadSlot(isFirst: true, onTap: model.addPhoto),
                    const SizedBox(width: 12),
                    const _ImageUploadSlot(),
                    const SizedBox(width: 12),
                    const _ImageUploadSlot(),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: model.isBusy
                      ? null
                      : () => _saveProfile(context, model),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(125, 139, 114, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: model.isBusy
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar perfil',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile(
    BuildContext context,
    ProviderBusinessInfoViewModel model,
  ) async {
    await model.saveProfile();
    if (!context.mounted) {
      return;
    }

    context.go(AppRoutes.providerHome);
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
    );
  }
}

class _LogoUploadCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoUploadCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_a_photo_outlined, color: AppColors.secondaryText),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Añadir logo del negocio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 2),
                Text('Imagen principal de tu perfil', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final TextInputType? keyboardType;
  final ProviderFieldInputKind inputKind;

  const _CustomTextField({
    required this.hintText,
    required this.onChanged,
    this.keyboardType,
    this.inputKind = ProviderFieldInputKind.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: TextField(
        onChanged: onChanged,
        keyboardType:
            keyboardType ?? ProviderFieldInput.keyboardType(inputKind),
        inputFormatters: <TextInputFormatter>[
          ...ProviderFieldInput.formatters(inputKind),
        ],
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black26),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _InfoCard({required this.title, required this.subtitle, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                ],
              ),
            ),
            if (trailing != null) ...[trailing!],
          ],
        ),
      ),
    );
  }
}

class _SocialField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final Color iconColor;
  final Function(String) onChanged;
  final ProviderFieldInputKind inputKind;

  const _SocialField({
    required this.icon,
    required this.hint,
    required this.iconColor,
    required this.onChanged,
    this.inputKind = ProviderFieldInputKind.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              keyboardType: ProviderFieldInput.keyboardType(inputKind),
              inputFormatters: <TextInputFormatter>[
                ...ProviderFieldInput.formatters(inputKind),
              ],
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.black26, fontSize: 12),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageUploadSlot extends StatelessWidget {
  final bool isFirst;
  final VoidCallback? onTap;
  const _ImageUploadSlot({this.isFirst = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Center(
          child: isFirst 
            ? const Icon(Icons.add, size: 32, color: Color.fromRGBO(125, 139, 114, 1))
            : Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
        ),
      ),
    );
  }
}
