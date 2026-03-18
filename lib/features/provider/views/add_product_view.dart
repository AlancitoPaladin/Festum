import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/provider/viewmodels/add_service_viewmodel.dart';
import 'package:festum/features/provider/viewmodels/add_product_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class AddProductView extends StatelessWidget {
  final ServiceCategory category;

  const AddProductView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddProductViewModel>.reactive(
      viewModelBuilder: () => AddProductViewModel(category),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Añadir ${_getCategoryLabel(category)}',
            style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información del producto/paquete'),
              _buildDynamicForm(context, model),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Imágenes'),
              const Text('Sube fotos específicas de este producto o paquete.', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildImageUploadCard(isMain: true),
                  const SizedBox(width: 12),
                  _buildImageUploadCard(),
                  const SizedBox(width: 12),
                  _buildImageUploadCard(),
                ],
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Descripción detallada'),
              _buildTextField('', 'Describe lo que ofreces específicamente en este ítem...', maxLines: 3, onChanged: (v) => model.description = v),
              
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: _buildButton('Cancelar', isSecondary: true, onPressed: () => Navigator.pop(context)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildButton('Guardar producto', onPressed: model.saveProduct, isLoading: model.isBusy),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryLabel(ServiceCategory category) {
    if (category == ServiceCategory.furniture || category == ServiceCategory.equipment) return 'producto';
    return 'paquete';
  }

  Widget _buildDynamicForm(BuildContext context, AddProductViewModel model) {
    switch (category) {
      case ServiceCategory.dj:
      case ServiceCategory.entertainment:
        return _buildCard([
          _buildTextField('Nombre del paquete', 'Ej: Paquete Básico 5 horas'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Precio', '\$ 2500', prefix: '\$')),
              const SizedBox(width: 16),
              Expanded(child: _buildDropdown('Tipo de precio', model.pricingUnit, ['Por evento', 'Por hora'], (v) => model.setPricingUnit(v))),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Duración mínima', '4 horas', suffixIcon: Icons.access_time),
          const SizedBox(height: 12),
          _buildSwitch('¿Permitir horas extra?', model.extraHourAllowed, (v) => model.toggleExtraHour(v)),
          const SizedBox(height: 16),
          _buildInclusionsGrid(model),
        ]);

      case ServiceCategory.banquet:
        return _buildCard([
          _buildTextField('Nombre del paquete', 'Ej: Banquete Ejecutivo'),
          const SizedBox(height: 16),
          _buildTextField('Precio por persona', '\$ 180', prefix: '\$'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Capacidad mínima', '50')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Capacidad máxima', '300')),
            ],
          ),
          const SizedBox(height: 16),
          _buildDropdown('Tipo de servicio', model.banquetType, ['Buffet', 'Emplatado'], (v) => model.setBanquetType(v)),
          const SizedBox(height: 16),
          _buildTextField('Menú incluido', 'Entrada, Plato fuerte, Postre...', maxLines: 2),
        ]);

      case ServiceCategory.furniture:
      case ServiceCategory.equipment:
        return _buildCard([
          _buildTextField('Nombre del producto', 'Ej: Silla Tiffany Blanca'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Precio unidad', '\$ 35', prefix: '\$')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Stock disponible', '150')),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Color / Material', 'Madera / Blanco'),
        ]);

      case ServiceCategory.venue:
        return _buildCard([
          _buildTextField('Nombre del salón/espacio', 'Ej: Terraza del Sol'),
          const SizedBox(height: 16),
          _buildTextField('Capacidad máxima', '200 personas'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Precio base', '\$ 5000', prefix: '\$')),
              const SizedBox(width: 16),
              Expanded(child: _buildSwitch('Cobro por hora', model.isPricePerHour, (v) => model.togglePricePerHour(v))),
            ],
          ),
          const SizedBox(height: 16),
          _buildInclusionsGrid(model),
        ]);

      case ServiceCategory.decoration:
        return _buildCard([
          _buildTextField('Nombre del paquete', 'Ej: Decoración Premium'),
          const SizedBox(height: 16),
          _buildDropdown('Tipo de evento', model.decorationType, ['Boda', 'Cumpleaños', 'XV años', 'Infantil'], (v) => model.setDecorationType(v)),
          const SizedBox(height: 16),
          _buildTextField('Precio', '\$ 3000', prefix: '\$'),
          const SizedBox(height: 16),
          _buildInclusionsGrid(model),
        ]);

      default:
        return _buildCard([_buildTextField('Nombre', ''), const SizedBox(height: 16), _buildTextField('Precio', '', prefix: '\$')]);
    }
  }

  // --- Widgets Auxiliares ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildTextField(String label, String hint, {String? prefix, IconData? suffixIcon, int maxLines = 1, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) Text(label, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: TextField(
            maxLines: maxLines,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
              prefixText: prefix,
              suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18, color: AppColors.secondaryText) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.primaryText)),
        Switch.adaptive(
          value: value,
          activeColor: AppColors.appBar,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInclusionsGrid(AddProductViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('¿Qué incluye?', style: TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: model.inclusions.keys.map((key) => _buildInclusionChip(key, model.inclusions[key]!, () => model.toggleInclusion(key))).toList(),
        ),
      ],
    );
  }

  Widget _buildInclusionChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.appBar.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.appBar : Colors.black12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? Icons.check_circle : Icons.add_circle_outline, size: 16, color: isSelected ? AppColors.appBar : AppColors.secondaryText),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: isSelected ? AppColors.appBar : AppColors.secondaryText, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadCard({bool isMain = false}) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppColors.secondaryText, size: 24),
            if (isMain) ...[
              const SizedBox(height: 8),
              const Text('Foto principal', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, {bool isSecondary = false, required VoidCallback onPressed, bool isLoading = false}) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? AppColors.backgroundElevated : AppColors.appBar,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(text, style: TextStyle(color: isSecondary ? AppColors.primaryText : Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }
}
