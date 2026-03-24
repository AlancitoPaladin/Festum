import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/network/api_url_resolver.dart';
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
      viewModelBuilder: () => ProviderBusinessInfoViewModel(
        locator(),
        locator(),
        locator(),
      ),
      onViewModelReady: (ProviderBusinessInfoViewModel model) {
        model.initialize();
      },
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: model.isOnboardingRequired
              ? 'Completa tu negocio'
              : 'Perfil del negocio',
          showBackButton: !model.isOnboardingRequired,
        ),
        body: _buildBody(context, model),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProviderBusinessInfoViewModel model,
  ) {
    if (model.isBusy && !model.hasLoadedProfile) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.errorMessage != null && !model.hasLoadedProfile) {
      return _BusinessInfoErrorState(
        message: model.errorMessage!,
        onRetry: model.retryLoad,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informacion que veran los clientes sobre tu negocio.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 32),
          _SectionLabel(
            label: model.hasExistingProfile
                ? 'Logotipo del negocio'
                : 'Agrega el logotipo de tu negocio',
          ),
          const SizedBox(height: 16),
          _LogoUploadCard(
            imageUrl: model.businessInfo.logoUrl,
            isUploading: model.isUploadingAsset,
            onTap: () => _runAsyncMessage(
              context,
              model.pickLogo,
            ),
          ),
          const SizedBox(height: 32),
          const _SectionLabel(label: 'Informacion basica'),
          const SizedBox(height: 12),
          _CustomTextField(
            controller: model.businessNameController,
            hintText: 'Ingresa nombre del negocio',
            onChanged: model.updateName,
            inputKind: ProviderFieldInputKind.title,
          ),
          const SizedBox(height: 16),
          _CustomTextField(
            controller: model.locationController,
            hintText: 'Ciudad principal donde trabajas',
            onChanged: model.updateLocation,
            inputKind: ProviderFieldInputKind.title,
          ),
          const SizedBox(height: 16),
          _CustomTextField(
            controller: model.coverageAreaController,
            hintText: 'Ej: Teziutlan y municipios cercanos',
            onChanged: model.updateCoverageArea,
            maxLines: 2,
            inputKind: ProviderFieldInputKind.mixedText,
          ),
          const SizedBox(height: 16),
          _CustomTextField(
            controller: model.contactNumberController,
            hintText: 'Numero de contacto',
            onChanged: model.updateContactNumber,
            keyboardType: TextInputType.phone,
            inputKind: ProviderFieldInputKind.phone,
          ),
          const SizedBox(height: 32),
          const _SectionLabel(label: 'Redes y contacto'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SocialField(
                  controller: model.whatsappController,
                  icon: Icons.phone_outlined,
                  hint: 'WhatsApp',
                  iconColor: Colors.green,
                  onChanged: model.updateWhatsapp,
                  inputKind: ProviderFieldInputKind.phone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SocialField(
                  controller: model.instagramController,
                  icon: Icons.camera_alt_outlined,
                  hint: '@instagram',
                  iconColor: Colors.pink,
                  onChanged: model.updateInstagram,
                  inputKind: ProviderFieldInputKind.socialHandle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SocialField(
                  controller: model.facebookController,
                  icon: Icons.facebook,
                  hint: 'Facebook',
                  iconColor: Colors.blue,
                  onChanged: model.updateFacebook,
                  inputKind: ProviderFieldInputKind.socialHandle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SocialField(
                  controller: model.websiteController,
                  icon: Icons.language,
                  hint: 'Sitio web',
                  iconColor: Colors.teal,
                  onChanged: model.updateWebsite,
                  inputKind: ProviderFieldInputKind.url,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const _SectionLabel(label: 'Fotos del negocio'),
          const SizedBox(height: 4),
          const Text(
            'Sube fotos de tu negocio o trabajos realizados.',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: model.businessInfo.photoUrls.length + 1,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _ImageUploadSlot(
                    isAddButton: true,
                    isUploading: model.isUploadingAsset,
                    onTap: () => _runAsyncMessage(
                      context,
                      model.addPhoto,
                    ),
                  );
                }

                return _ImageUploadSlot(
                  imageUrl: model.businessInfo.photoUrls[index - 1],
                );
              },
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: model.isBusy || model.isUploadingAsset
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
                  : Text(
                      model.hasExistingProfile
                          ? 'Guardar cambios'
                          : 'Guardar perfil',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _saveProfile(
    BuildContext context,
    ProviderBusinessInfoViewModel model,
  ) async {
    final String? errorMessage = await model.saveProfile();
    if (!context.mounted) {
      return;
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil del negocio guardado.')),
    );
    context.go(AppRoutes.providerHome);
  }

  Future<void> _runAsyncMessage(
    BuildContext context,
    Future<String?> Function() action, {
    String? successMessage,
  }) async {
    final String? errorMessage = await action();
    if (!context.mounted) {
      return;
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    if (successMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    }
  }
}

class _BusinessInfoErrorState extends StatelessWidget {
  const _BusinessInfoErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.business_center_outlined,
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

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      ),
    );
  }
}

class _LogoUploadCard extends StatelessWidget {
  const _LogoUploadCard({
    required this.imageUrl,
    required this.isUploading,
    required this.onTap,
  });

  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String resolvedImageUrl = resolveApiAssetUrl(imageUrl ?? '');

    return InkWell(
      onTap: isUploading ? null : onTap,
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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(12),
                image: resolvedImageUrl.isEmpty
                    ? null
                    : DecorationImage(
                        image: NetworkImage(resolvedImageUrl),
                        fit: BoxFit.cover,
                      ),
              ),
              child: resolvedImageUrl.isEmpty
                  ? const Icon(
                      Icons.add_a_photo_outlined,
                      color: AppColors.secondaryText,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resolvedImageUrl.isEmpty
                        ? 'Anadir logo del negocio'
                        : 'Cambiar logo del negocio',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUploading
                        ? 'Subiendo imagen...'
                        : 'Imagen principal de tu perfil',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  const _CustomTextField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.keyboardType,
    this.inputKind = ProviderFieldInputKind.text,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final Function(String) onChanged;
  final TextInputType? keyboardType;
  final ProviderFieldInputKind inputKind;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        keyboardType:
            keyboardType ??
            ProviderFieldInput.keyboardType(inputKind, maxLines: maxLines),
        inputFormatters: <TextInputFormatter>[
          ...ProviderFieldInput.formatters(inputKind),
        ],
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black26),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _SocialField extends StatelessWidget {
  const _SocialField({
    required this.controller,
    required this.icon,
    required this.hint,
    required this.iconColor,
    required this.onChanged,
    this.inputKind = ProviderFieldInputKind.text,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final Color iconColor;
  final Function(String) onChanged;
  final ProviderFieldInputKind inputKind;

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
              controller: controller,
              onChanged: onChanged,
              keyboardType: ProviderFieldInput.keyboardType(inputKind),
              inputFormatters: <TextInputFormatter>[
                ...ProviderFieldInput.formatters(inputKind),
              ],
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Colors.black26,
                  fontSize: 12,
                ),
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
  const _ImageUploadSlot({
    this.imageUrl,
    this.isAddButton = false,
    this.isUploading = false,
    this.onTap,
  });

  final String? imageUrl;
  final bool isAddButton;
  final bool isUploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String resolvedImageUrl = resolveApiAssetUrl(imageUrl ?? '');

    return InkWell(
      onTap: isUploading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          image: !isAddButton && resolvedImageUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(resolvedImageUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Center(
          child: isAddButton
              ? isUploading
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.add,
                        size: 32,
                        color: Color.fromRGBO(125, 139, 114, 1),
                      )
              : resolvedImageUrl.isEmpty
              ? Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevated.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
        ),
      ),
    );
  }
}
