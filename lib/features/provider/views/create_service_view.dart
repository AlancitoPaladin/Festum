import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/provider/viewmodels/add_service_viewmodel.dart';
import 'package:festum/features/provider/viewmodels/create_service_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class CreateServiceView extends StatelessWidget {
  const CreateServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateServiceViewModel>.reactive(
      viewModelBuilder: () => CreateServiceViewModel(),
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
                'Crear servicio',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Agrega un nuevo servicio que ofreces a tus clientes.',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
              ),
              const SizedBox(height: 32),
              const Text(
                'Detalles del servicio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Nombre del servicio',
                hint: 'Ej: DJ para eventos',
              ),
              const SizedBox(height: 16),
              _buildDropdownField(model),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Descripción del servicio',
                hint: 'Describe tu servicio, ¿qué ofreces?',
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              const Text(
                'Imágenes del servicio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sube fotos de tu servicio para atraer a más clientes.',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _ImageSlot(isFirst: true),
                    const SizedBox(width: 12),
                    _ImageSlot(),
                    const SizedBox(width: 12),
                    _ImageSlot(),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: model.saveService,
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
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 13)),
          TextField(
            maxLines: maxLines,
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

  Widget _buildDropdownField(CreateServiceViewModel model) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Categoría', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
          DropdownButtonHideUnderline(
            child: DropdownButton<ServiceCategory>(
              value: model.selectedCategory,
              hint: const Text('Selecciona categoría', style: TextStyle(color: Colors.black26, fontSize: 14)),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.secondaryText),
              items: ServiceCategory.values.map((cat) {
                return DropdownMenuItem(
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
  final bool isFirst;
  const _ImageSlot({this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Center(
        child: isFirst
            ? const Icon(Icons.add, size: 32, color: Color.fromRGBO(125, 139, 114, 1))
            : Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
      ),
    );
  }
}
