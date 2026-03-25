import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/usecases/create_provider_service_use_case.dart';
import 'package:festum/features/provider/utils/provider_field_input.dart';
import 'package:festum/features/provider/viewmodels/create_service_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:stacked/stacked.dart';

class CreateServiceView extends StatelessWidget {
  const CreateServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateServiceViewModel>.reactive(
      viewModelBuilder: () => CreateServiceViewModel(
        locator<CreateProviderServiceUseCase>(),
        locator<ProviderReactivityService>(),
      ),
      builder: (BuildContext context, CreateServiceViewModel model, _) {
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
                  'Crear servicio',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completa solo la informacion esencial. Podras agregar productos y fotos despues.',
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
                const _InfoCard(
                  title: 'Precio calculado automaticamente',
                  subtitle:
                      'El precio visible para el cliente se tomara del producto publicado mas economico de este servicio.',
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
                const Text(
                  'Guarda primero el servicio para poder subir fotos y elegir la principal.',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                const _PhotoPlaceholderCard(
                  title: 'Sube fotos despues de guardar',
                  subtitle:
                      'En cuanto se cree el servicio te llevaremos a la pantalla de edicion para agregar imagenes.',
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: model.isBusy ? null : () => _save(context, model),
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
                            'Guardar servicio',
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
    CreateServiceViewModel model,
  ) async {
    final ProviderService? createdService = await model.saveService();
    if (!context.mounted || createdService == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Servicio guardado. Ahora puedes agregar fotos.'),
      ),
    );
    await context.push(
      AppRoutes.providerEditServiceRoute(
        createdService.id,
        createdService.name,
        createdService.category.name,
      ),
    );
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? errorText,
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

  Widget _buildDropdownField(CreateServiceViewModel model) {
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

class _PhotoPlaceholderCard extends StatelessWidget {
  const _PhotoPlaceholderCard({
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
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(width: 14),
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
