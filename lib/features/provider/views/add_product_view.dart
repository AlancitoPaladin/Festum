import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/provider/models/provider_product.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/usecases/create_provider_product_use_case.dart';
import 'package:festum/features/provider/utils/provider_field_input.dart';
import 'package:festum/features/provider/viewmodels/add_product_viewmodel.dart';
import 'package:festum/features/provider/widgets/dynamic_selection_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:stacked/stacked.dart';

class AddProductView extends StatelessWidget {
  const AddProductView({
    super.key,
    required this.serviceId,
    required this.category,
  });

  final String serviceId;
  final ServiceCategory category;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddProductViewModel>.reactive(
      viewModelBuilder: () => AddProductViewModel(
        serviceId: serviceId,
        category: category,
        createProviderProductUseCase: locator<CreateProviderProductUseCase>(),
        providerReactivityService: locator<ProviderReactivityService>(),
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
            'Añadir ${_getCategoryLabel(category)}',
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
              if (model.generalErrorMessage != null) ...[
                _ErrorBanner(message: model.generalErrorMessage!),
                const SizedBox(height: 16),
              ],
              _buildSectionTitle('Información general'),
              _buildDynamicForm(model),
              const SizedBox(height: 24),
              _buildSectionTitle('Imágenes'),
              Text(
                'Guarda primero el producto y después podrás subir su portada y galería.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.secondaryText),
              ),
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
              _buildTextField(
                '',
                'Describe lo que ofreces específicamente...',
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
                      'Guardar',
                      onPressed: () => _saveProduct(context, model),
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

  Future<void> _saveProduct(
    BuildContext context,
    AddProductViewModel model,
  ) async {
    final ProviderProduct? product = await model.saveProduct();
    if (!context.mounted || product == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Producto creado en borrador. Ahora puedes agregar fotos.',
        ),
      ),
    );
    context.pushReplacement(AppRoutes.providerEditProductRoute(product.id));
  }

  String _getCategoryLabel(ServiceCategory category) {
    if (category == ServiceCategory.furniture ||
        category == ServiceCategory.equipment) {
      return 'producto';
    }
    return 'servicio';
  }

  Widget _buildDynamicForm(AddProductViewModel model) {
    final data = model.formData;

    switch (category) {
      case ServiceCategory.dj:
      case ServiceCategory.photography:
      case ServiceCategory.entertainment:
        return _buildCard([
          _buildTextField(
            'Nombre del servicio',
            'Ej: DJ para eventos premium',
            onChanged: model.updateName,
            inputKind: ProviderFieldInputKind.title,
            errorText: model.fieldError('name'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Precio',
                  '\$ 2500',
                  prefix: '\$',
                  onChanged: model.updatePrice,
                  inputKind: ProviderFieldInputKind.decimal,
                  errorText: model.fieldError('price'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown('Tipo de precio', data.pricingUnit, [
                  'Por evento',
                  'Por hora',
                  'Por persona',
                ], model.updatePricingUnit),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (category == ServiceCategory.photography) ...[
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Cant. de fotos aprox.',
                    '300',
                    onChanged: model.updateApproxPhotos,
                    inputKind: ProviderFieldInputKind.integer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    'Tiempo de entrega',
                    '15 días',
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
            suffixIcon: Icons.access_time,
            onChanged: model.updateMinDuration,
            inputKind: ProviderFieldInputKind.mixedText,
          ),
          const SizedBox(height: 12),
          _buildSwitch(
            'Permitir horas extra',
            data.extraHourAllowed,
            model.toggleExtraHour,
          ),
          if (data.extraHourAllowed) ...[
            const SizedBox(height: 8),
            _buildTextField(
              'Costo por hora extra',
              '\$ 500',
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
            title: 'Políticas del servicio',
            items: data.policies,
            onToggle: model.togglePolicy,
          ),
        ]);

      case ServiceCategory.banquet:
        return _buildCard([
          _buildTextField(
            'Nombre del banquete',
            'Ej. Menú de gala de 3 tiempos.',
            onChanged: model.updateName,
            inputKind: ProviderFieldInputKind.title,
            errorText: model.fieldError('name'),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Precio por persona',
            '\$ 180',
            prefix: '\$',
            onChanged: model.updatePrice,
            inputKind: ProviderFieldInputKind.decimal,
            errorText: model.fieldError('price'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Capacidad mínima',
                  '50',
                  onChanged: model.updateMinGuests,
                  inputKind: ProviderFieldInputKind.integer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Capacidad máxima',
                  '300',
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
            'Entrada, plato fuerte, postre...',
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

      case ServiceCategory.furniture:
      case ServiceCategory.equipment:
        return _buildCard([
          _buildTextField(
            'Nombre del producto',
            'Ej: Silla Tiffany Blanca',
            onChanged: model.updateName,
            inputKind: ProviderFieldInputKind.title,
            errorText: model.fieldError('name'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Precio unidad',
                  '\$ 35',
                  prefix: '\$',
                  onChanged: model.updatePrice,
                  inputKind: ProviderFieldInputKind.decimal,
                  errorText: model.fieldError('price'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Stock disponible',
                  '150',
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
                  '40x40x90 cm',
                  onChanged: model.updateDimensions,
                  inputKind: ProviderFieldInputKind.mixedText,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Peso unitario',
                  '4 kg',
                  onChanged: model.updateWeight,
                  inputKind: ProviderFieldInputKind.mixedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Color / Material',
            'Madera / Blanco',
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
            title: 'Políticas de renta',
            items: data.policies,
            onToggle: model.togglePolicy,
          ),
        ]);

      case ServiceCategory.venue:
        return _buildCard([
          _buildTextField(
            'Nombre del salón o espacio',
            'Ej: Terraza del Sol',
            onChanged: model.updateName,
            inputKind: ProviderFieldInputKind.title,
            errorText: model.fieldError('name'),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Capacidad máxima',
            '200 personas',
            onChanged: model.updateVenueCapacity,
            inputKind: ProviderFieldInputKind.integer,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Precio base',
                  '\$ 5000',
                  prefix: '\$',
                  onChanged: model.updatePrice,
                  inputKind: ProviderFieldInputKind.decimal,
                  errorText: model.fieldError('price'),
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
            title: 'Reglas del lugar',
            items: data.policies,
            onToggle: model.togglePolicy,
          ),
        ]);

      case ServiceCategory.decoration:
        return _buildCard([
          _buildTextField(
            'Nombre del paquete de decoración',
            'Ej. Decoración premium.',
            onChanged: model.updateName,
            inputKind: ProviderFieldInputKind.title,
            errorText: model.fieldError('name'),
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
                  'Precio',
                  '\$ 3000',
                  prefix: '\$',
                  onChanged: model.updatePrice,
                  inputKind: ProviderFieldInputKind.decimal,
                  errorText: model.fieldError('price'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Tiempo montaje',
                  '2 horas',
                  onChanged: model.updateSetupTime,
                  inputKind: ProviderFieldInputKind.mixedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: 'Elementos incluidos',
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
    String? prefix,
    IconData? suffixIcon,
    int maxLines = 1,
    Function(String)? onChanged,
    bool enabled = true,
    String? errorText,
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
          child: TextField(
            maxLines: maxLines,
            onChanged: onChanged,
            enabled: enabled,
            keyboardType: ProviderFieldInput.keyboardType(
              inputKind,
              maxLines: maxLines,
            ),
            inputFormatters: <TextInputFormatter>[
              ...ProviderFieldInput.formatters(inputKind),
            ],
            style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              errorText: errorText,
              hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
              prefixText: prefix,
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, size: 18, color: AppColors.secondaryText)
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
              dropdownColor: AppColors.card,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 14,
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 13)),
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
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.primaryText),
          ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.secondaryText,
              size: 24,
            ),
            if (isMain) ...[
              const SizedBox(height: 8),
              const Text(
                'Foto principal',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: AppColors.secondaryText),
              ),
            ],
          ],
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
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
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
