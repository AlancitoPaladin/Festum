import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/utils/provider_field_input.dart';
import 'package:festum/features/provider/viewmodels/edit_service_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

class EditServiceView extends StatelessWidget {
  final String serviceId;
  final String serviceName;
  final ServiceCategory category;

  const EditServiceView({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditServiceViewModel>.reactive(
      viewModelBuilder: () => EditServiceViewModel(
        serviceId: serviceId,
        serviceName: serviceName,
        category: category,
      ),
      builder: (context, model, child) => Scaffold(
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar servicio',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Actualiza la información del servicio que ya registraste.',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
              ),
              const SizedBox(height: 32),
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
                label: 'Nombre del servicio',
                hint: 'Ej: DJ para eventos',
                initialValue: model.formData.name,
                onChanged: model.updateName,
                inputKind: ProviderFieldInputKind.title,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(model),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Descripción del servicio',
                hint: 'Describe tu servicio, ¿qué ofreces?',
                maxLines: 4,
                initialValue: model.formData.description,
                onChanged: model.updateDescription,
                inputKind: ProviderFieldInputKind.mixedText,
              ),
              const SizedBox(height: 32),
              const Text(
                'Imágenes del servicio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Muestra las fotos que ya tiene tu servicio y agrega nuevas si hace falta.',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final hasImage = index < model.formData.imageUrls.length;
                    return _ImageSlot(
                      isFilled: hasImage,
                      isFirst: index == 0,
                      onTap: hasImage ? null : model.addPhoto,
                    );
                  },
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: model.saveServiceChanges,
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    String? initialValue,
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
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
          TextFormField(
            initialValue: initialValue,
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
        children: [
          const Text(
            'Categoría',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<ServiceCategory>(
              value: model.selectedCategory,
              hint: const Text(
                'Selecciona categoría',
                style: TextStyle(color: Colors.black26, fontSize: 14),
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.secondaryText,
              ),
              items: ServiceCategory.values.map((cat) {
                return DropdownMenuItem<ServiceCategory>(
                  value: cat,
                  child: Text(cat.label, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: model.setCategory,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageSlot extends StatelessWidget {
  final bool isFilled;
  final bool isFirst;
  final VoidCallback? onTap;

  const _ImageSlot({
    required this.isFilled,
    required this.isFirst,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Center(
          child: isFilled
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      size: 30,
                      color: AppColors.appBar,
                    ),
                    if (isFirst) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Principal',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                )
              : const Icon(
                  Icons.add,
                  size: 32,
                  color: Color.fromRGBO(125, 139, 114, 1),
                ),
        ),
      ),
    );
  }
}
