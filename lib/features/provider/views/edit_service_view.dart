import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/app_remote_image.dart';
import 'package:festum/features/provider/models/provider_service_image.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/usecases/delete_provider_service_image_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_services_use_case.dart';
import 'package:festum/features/provider/usecases/set_provider_service_main_image_use_case.dart';
import 'package:festum/features/provider/usecases/upload_provider_service_image_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_service_use_case.dart';
import 'package:festum/features/provider/utils/provider_field_input.dart';
import 'package:festum/features/provider/viewmodels/edit_service_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

class EditServiceView extends StatelessWidget {
  const EditServiceView({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.category,
  });

  final String serviceId;
  final String serviceName;
  final ServiceCategory category;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditServiceViewModel>.reactive(
      viewModelBuilder: () => EditServiceViewModel(
        serviceId: serviceId,
        serviceName: serviceName,
        category: category,
        getProviderServicesUseCase: locator<GetProviderServicesUseCase>(),
        updateProviderServiceUseCase: locator<UpdateProviderServiceUseCase>(),
        uploadProviderServiceImageUseCase:
            locator<UploadProviderServiceImageUseCase>(),
        setProviderServiceMainImageUseCase:
            locator<SetProviderServiceMainImageUseCase>(),
        deleteProviderServiceImageUseCase:
            locator<DeleteProviderServiceImageUseCase>(),
        providerReactivityService: locator<ProviderReactivityService>(),
        imagePicker: locator(),
      ),
      onViewModelReady: (EditServiceViewModel model) => model.initialise(),
      builder: (BuildContext context, EditServiceViewModel model, _) {
        if (model.isBusy && !model.hasLoadedInitialData) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Editar servicio',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Actualiza la informacion esencial de tu servicio.',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                if (model.generalErrorMessage != null)
                  _ErrorBanner(message: model.generalErrorMessage!),
                if (model.generalErrorMessage != null)
                  const SizedBox(height: 16),
                const Text(
                  'Detalles del servicio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: model.nameController,
                  label: 'Nombre del servicio',
                  hint: 'Ej. Salon para eventos',
                  onChanged: model.updateName,
                  inputKind: ProviderFieldInputKind.title,
                  errorText: model.fieldError('name'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: model.subtitleController,
                  label: 'Subtitulo',
                  hint: 'Ej. Hasta 250 invitados',
                  onChanged: model.updateSubtitle,
                  inputKind: ProviderFieldInputKind.mixedText,
                  errorText: model.fieldError('subtitle'),
                ),
                const SizedBox(height: 16),
                _buildDropdownField(model),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: model.descriptionController,
                  label: 'Descripcion del servicio',
                  hint: 'Describe tu servicio, que ofreces?',
                  maxLines: 4,
                  onChanged: model.updateDescription,
                  inputKind: ProviderFieldInputKind.mixedText,
                  errorText: model.fieldError('description'),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Precio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                _InfoCard(
                  title: model.formData.unitPriceCents > 0
                      ? 'Precio actual de referencia'
                      : 'Precio pendiente de productos',
                  subtitle: model.formData.unitPriceCents > 0
                      ? 'Este servicio conserva un precio de referencia mientras se termina de automatizar el calculo desde tus productos.'
                      : 'Cuando tengas productos publicados, el cliente vera automaticamente el precio mas bajo disponible.',
                ),
                const SizedBox(height: 32),
                const Text(
                  'Fotos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _buildPhotoSummary(model),
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                _ServiceImagesSection(
                  model: model,
                  onAddImage: () => _runImageAction(
                    context,
                    model.uploadImage,
                    successMessage: 'Imagen subida.',
                  ),
                  onMarkAsMain: (String imageKey) => _runImageAction(
                    context,
                    () => model.markImageAsMain(imageKey),
                    successMessage: 'Imagen principal actualizada.',
                  ),
                  onDeleteImage: (String imageKey) => _runImageAction(
                    context,
                    () => model.deleteImage(imageKey),
                    successMessage: 'Imagen eliminada.',
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: model.isBusy || model.isUploadingImage
                        ? null
                        : () => _save(context, model),
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
                            'Guardar cambios',
                            style: TextStyle(
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
          ),
        );
      },
    );
  }

  Future<void> _save(
    BuildContext context,
    EditServiceViewModel model,
  ) async {
    final bool wasUpdated = await model.saveServiceChanges();
    if (!context.mounted || !wasUpdated) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Servicio actualizado.')),
    );
    Navigator.of(context).pop(true);
  }

  Future<void> _runImageAction(
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

  String _buildPhotoSummary(EditServiceViewModel model) {
    final bool hasMainImage = model.images.any(
      (ProviderServiceImage image) => image.isMain,
    );
    final int galleryCount = model.images.length;

    if (!hasMainImage && galleryCount == 0) {
      return 'Pronto podras agregar fotos desde aqui.';
    }

    if (hasMainImage && galleryCount == 1) {
      return 'Tu servicio ya tiene una foto principal configurada.';
    }

    if (hasMainImage) {
      final int additionalPhotos = galleryCount - 1;
      return additionalPhotos <= 0
          ? 'Tu servicio ya tiene una foto principal configurada.'
          : 'Tu servicio tiene una foto principal y $additionalPhotos fotos adicionales.';
    }

    return 'Tu servicio tiene $galleryCount fotos configuradas.';
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? errorText,
    int maxLines = 1,
    Function(String)? onChanged,
    ProviderFieldInputKind inputKind = ProviderFieldInputKind.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
            ),
          ),
          TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: onChanged,
            keyboardType: ProviderFieldInput.keyboardType(
              inputKind,
              maxLines: maxLines,
            ),
            inputFormatters: <TextInputFormatter>[
              ...ProviderFieldInput.formatters(inputKind),
            ],
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.only(top: 8),
              errorText: errorText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(EditServiceViewModel model) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Categoria',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<ServiceCategory>(
              value: model.selectedCategory,
              hint: const Text(
                'Selecciona una categoria',
                style: TextStyle(color: Colors.black26, fontSize: 14),
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.secondaryText,
              ),
              items: ServiceCategory.providerServiceOptions.map((
                ServiceCategory cat,
              ) {
                return DropdownMenuItem<ServiceCategory>(
                  value: cat,
                  child: Text(cat.label, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: model.setCategory,
            ),
          ),
          if (model.fieldError('category') != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                model.fieldError('category')!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calculate_outlined,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceImagesSection extends StatelessWidget {
  const _ServiceImagesSection({
    required this.model,
    required this.onAddImage,
    required this.onMarkAsMain,
    required this.onDeleteImage,
  });

  final EditServiceViewModel model;
  final VoidCallback onAddImage;
  final Future<void> Function(String imageKey) onMarkAsMain;
  final Future<void> Function(String imageKey) onDeleteImage;

  @override
  Widget build(BuildContext context) {
    if (model.images.isEmpty) {
      return _PhotoEmptyCard(
        isUploading: model.isUploadingImage,
        onAddImage: onAddImage,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 178,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: model.images.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return _AddPhotoCard(
                  isUploading: model.isUploadingImage,
                  onTap: onAddImage,
                );
              }

              final ProviderServiceImage image = model.images[index - 1];
              final bool isMutating = model.mutatingImageKey == image.key;
              return _ServiceImageCard(
                image: image,
                isMutating: isMutating,
                onMakeMain: image.isMain
                    ? null
                    : () => onMarkAsMain(image.key),
                onDelete: () => onDeleteImage(image.key),
              );
            },
          ),
        ),
        if (model.isUploadingImage) ...<Widget>[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }
}

class _PhotoEmptyCard extends StatelessWidget {
  const _PhotoEmptyCard({
    required this.isUploading,
    required this.onAddImage,
  });

  final bool isUploading;
  final VoidCallback onAddImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Todavia no agregas fotos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sube al menos una imagen para que tu servicio se vea mejor en Client.',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isUploading ? null : onAddImage,
              icon: isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(isUploading ? 'Subiendo...' : 'Agregar foto'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoCard extends StatelessWidget {
  const _AddPhotoCard({
    required this.isUploading,
    required this.onTap,
  });

  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUploading ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 142,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.secondaryText,
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              isUploading ? 'Subiendo foto' : 'Agregar foto',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Puedes elegir una nueva imagen para este servicio.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceImageCard extends StatelessWidget {
  const _ServiceImageCard({
    required this.image,
    required this.isMutating,
    required this.onDelete,
    this.onMakeMain,
  });

  final ProviderServiceImage image;
  final bool isMutating;
  final VoidCallback onDelete;
  final VoidCallback? onMakeMain;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: AppRemoteImage(
                    imageUrl: image.resolvedImageUrl,
                    fit: BoxFit.cover,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    placeholder: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundElevated,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.black26,
                        size: 34,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: image.isMain
                          ? Colors.green.withValues(alpha: 0.9)
                          : Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      image.isMain ? 'Principal' : 'Galeria',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filledTonal(
                    onPressed: isMutating ? null : onDelete,
                    icon: isMutating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline, size: 18),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isMutating || onMakeMain == null ? null : onMakeMain,
                child: Text(image.isMain ? 'Imagen principal' : 'Usar como principal'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, height: 1.35),
      ),
    );
  }
}
