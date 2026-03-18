import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/utils/provider_field_input.dart';
import 'package:festum/features/provider/viewmodels/edit_product_viewmodel.dart';
import 'package:festum/features/provider/widgets/dynamic_selection_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

class EditProductView extends StatelessWidget {
  final ServiceCategory category;
  final String productId;

  const EditProductView({
    super.key,
    required this.category,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditProductViewModel>.reactive(
      viewModelBuilder: () => EditProductViewModel(
        category: category,
        productId: productId,
      ),
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
            'Editar ${_getCategoryLabel(category)}',
            style: const TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información general'),
              _buildDynamicForm(model),
              const SizedBox(height: 24),
              _buildSectionTitle('Imágenes'),
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
              _buildSectionTitle('Descripción'),
              _buildTextField(
                '',
                'Describe lo que ofreces...',
                initialValue: model.formData.description,
                maxLines: 3,
                onChanged: model.updateDescription,
                inputKind: ProviderFieldInputKind.mixedText,
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      'Cancelar',
                      isSecondary: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildButton(
                      'Guardar cambios',
                      onPressed: model.saveChanges,
                      isLoading: model.isBusy,
                    ),
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
    if (category == ServiceCategory.furniture ||
        category == ServiceCategory.equipment) {
      return 'producto';
    }
    return 'servicio';
  }

  Widget _buildDynamicForm(EditProductViewModel model) {
    final data = model.formData;

    switch (category) {
      case ServiceCategory.dj:
      case ServiceCategory.photography:
      case ServiceCategory.entertainment:
        return _buildCard([
          _buildTextField(
            'Nombre del servicio',
            'Ej: DJ Pro',
            initialValue: data.name,
            onChanged: model.updateName,
            inputKind: ProviderFieldInputKind.title,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Precio',
                  '\$ 0',
                  initialValue: data.price.toString(),
                  prefix: '\$',
                  onChanged: model.updatePrice,
                  inputKind: ProviderFieldInputKind.decimal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  'Tipo de precio',
                  data.pricingUnit,
                  ['Por evento', 'Por hora', 'Por persona'],
                  model.updatePricingUnit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (category == ServiceCategory.photography) ...[
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Cant. fotos aprox.',
                    '300',
                    initialValue: data.approxPhotos?.toString(),
                    onChanged: model.updateApproxPhotos,
                    inputKind: ProviderFieldInputKind.integer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    'Tiempo entrega',
                    '15 días',
                    initialValue: data.deliveryTime,
                    onChanged: model.updateDeliveryTime,
                    inputKind: ProviderFieldInputKind.mixedText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          _buildTextField(
            'Duración mínima',
            '4 horas',
            initialValue: data.minDuration,
            suffixIcon: Icons.access_time,
            onChanged: model.updateMinDuration,
            inputKind: ProviderFieldInputKind.mixedText,
          ),
          const SizedBox(height: 12),
          _buildSwitch(
            '¿Permitir horas extra?',
            data.extraHourAllowed,
            model.toggleExtraHour,
          ),
          if (data.extraHourAllowed) ...[
            const SizedBox(height: 8),
            _buildTextField(
              'Costo por hora extra',
              '\$ 500',
              initialValue: data.extraHourPrice.toString(),
              prefix: '\$',
              onChanged: model.updateExtraHourPrice,
              inputKind: ProviderFieldInputKind.decimal,
            ),
          ],
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: '¿Qué incluye?',
            items: data.inclusions,
            onToggle: model.toggleInclusion,
          ),
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: 'Políticas',
            items: data.policies,
            onToggle: model.togglePolicy,
          ),
        ]);

      case ServiceCategory.banquet:
        return _buildCard([
          _buildTextField(
            'Nombre del banquete',
            'Ej: Buffet Mexicano',
            initialValue: data.name,
            onChanged: model.updateName,
            inputKind: ProviderFieldInputKind.title,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Precio por persona',
            '\$ 0',
            initialValue: data.price.toString(),
            prefix: '\$',
            onChanged: model.updatePrice,
            inputKind: ProviderFieldInputKind.decimal,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Mínimo invitados',
                  '50',
                  initialValue: data.minGuests?.toString(),
                  onChanged: model.updateMinGuests,
                  inputKind: ProviderFieldInputKind.integer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Máximo invitados',
                  '300',
                  initialValue: data.maxGuests?.toString(),
                  onChanged: model.updateMaxGuests,
                  inputKind: ProviderFieldInputKind.integer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'Tipo de servicio',
            data.banquetType ?? 'Buffet',
            ['Buffet', 'Emplatado'],
            model.updateBanquetType,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Menú incluido',
            '...',
            initialValue: data.menuIncluded,
            maxLines: 2,
            onChanged: model.updateMenuIncluded,
            inputKind: ProviderFieldInputKind.mixedText,
          ),
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: '¿Qué incluye?',
            items: data.inclusions,
            onToggle: model.toggleInclusion,
          ),
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: 'Políticas',
            items: data.policies,
            onToggle: model.togglePolicy,
          ),
        ]);

      case ServiceCategory.venue:
        return _buildCard([
          _buildTextField(
            'Nombre del salón',
            'Salón Imperial',
            initialValue: data.name,
            onChanged: model.updateName,
            inputKind: ProviderFieldInputKind.title,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Capacidad máxima',
            '200',
            initialValue: data.venueCapacity,
            onChanged: model.updateVenueCapacity,
            inputKind: ProviderFieldInputKind.integer,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Precio base',
                  '\$ 0',
                  initialValue: data.price.toString(),
                  prefix: '\$',
                  onChanged: model.updatePrice,
                  inputKind: ProviderFieldInputKind.decimal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSwitch(
                  'Cobro por hora',
                  data.isPricePerHour,
                  (value) => model.togglePricePerHour(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: '¿Qué incluye?',
            items: data.inclusions,
            onToggle: model.toggleInclusion,
          ),
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: 'Políticas',
            items: data.policies,
            onToggle: model.togglePolicy,
          ),
        ]);

      case ServiceCategory.decoration:
        return _buildCard([
          _buildTextField(
            'Nombre del paquete',
            'Decoración Floral',
            initialValue: data.name,
            onChanged: model.updateName,
            inputKind: ProviderFieldInputKind.title,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'Tipo de evento',
            data.decorationType ?? 'Boda',
            ['Boda', 'Cumpleaños', 'XV años', 'Infantil'],
            model.updateDecorationType,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Precio base',
                  '\$ 0',
                  initialValue: data.price.toString(),
                  prefix: '\$',
                  onChanged: model.updatePrice,
                  inputKind: ProviderFieldInputKind.decimal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Tiempo montaje',
                  '2 horas',
                  initialValue: data.setupTime,
                  onChanged: model.updateSetupTime,
                  inputKind: ProviderFieldInputKind.mixedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: 'Inclusiones',
            items: data.inclusions,
            onToggle: model.toggleInclusion,
          ),
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: 'Políticas',
            items: data.policies,
            onToggle: model.togglePolicy,
          ),
        ]);

      case ServiceCategory.furniture:
      case ServiceCategory.equipment:
        return _buildCard([
          _buildTextField(
            'Nombre del producto',
            'Silla Tiffany',
            initialValue: data.name,
            onChanged: model.updateName,
            inputKind: ProviderFieldInputKind.title,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Precio unidad',
                  '\$ 0',
                  initialValue: data.price.toString(),
                  prefix: '\$',
                  onChanged: model.updatePrice,
                  inputKind: ProviderFieldInputKind.decimal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Stock',
                  '1',
                  initialValue: data.stock.toString(),
                  onChanged: model.updateStock,
                  inputKind: ProviderFieldInputKind.integer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Dimensiones',
                  '...',
                  initialValue: data.dimensions,
                  onChanged: model.updateDimensions,
                  inputKind: ProviderFieldInputKind.mixedText,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Peso unitario',
                  '...',
                  initialValue: data.weight,
                  onChanged: model.updateWeight,
                  inputKind: ProviderFieldInputKind.mixedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Color / Material',
            'Blanco',
            initialValue: data.colorMaterial,
            onChanged: model.updateColorMaterial,
            inputKind: ProviderFieldInputKind.text,
          ),
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: 'Inclusiones',
            items: data.inclusions,
            onToggle: model.toggleInclusion,
          ),
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: 'Políticas',
            items: data.policies,
            onToggle: model.togglePolicy,
          ),
        ]);

      default:
        return _buildCard([
          _buildTextField(
            'Nombre',
            '',
            initialValue: data.name,
            onChanged: model.updateName,
            inputKind: ProviderFieldInputKind.title,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Precio',
            '\$',
            initialValue: data.price.toString(),
            prefix: '\$',
            onChanged: model.updatePrice,
            inputKind: ProviderFieldInputKind.decimal,
          ),
        ]);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
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
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    String? initialValue,
    String? prefix,
    IconData? suffixIcon,
    int maxLines = 1,
    Function(String)? onChanged,
    ProviderFieldInputKind inputKind = ProviderFieldInputKind.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: TextFormField(
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
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primaryText,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              prefixText: prefix,
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, size: 18)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  )
                  .toList(),
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
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.primaryText),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: AppColors.appBar,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildImageUploadCard({bool isMain = false}) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: const Icon(
          Icons.add_a_photo_outlined,
          color: AppColors.secondaryText,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildButton(
    String text, {
    bool isSecondary = false,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary
              ? AppColors.backgroundElevated
              : AppColors.appBar,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: TextStyle(
                  color: isSecondary ? AppColors.primaryText : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}
