import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/app_remote_image.dart';
import 'package:festum/features/provider/models/product_form_data.dart';
import 'package:festum/features/provider/models/provider_product.dart';
import 'package:festum/features/provider/models/provider_product_image.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/usecases/delete_provider_product_image_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_product_detail_use_case.dart';
import 'package:festum/features/provider/usecases/set_provider_product_main_image_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_product_status_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_product_use_case.dart';
import 'package:festum/features/provider/usecases/upload_provider_product_image_use_case.dart';
import 'package:festum/features/provider/utils/provider_field_input.dart';
import 'package:festum/features/provider/viewmodels/edit_product_viewmodel.dart';
import 'package:festum/features/provider/widgets/dynamic_selection_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

class EditProductView extends StatelessWidget {
  const EditProductView({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditProductViewModel>.reactive(
      viewModelBuilder: () => EditProductViewModel(
        productId: productId,
        getProviderProductDetailUseCase: locator<GetProviderProductDetailUseCase>(),
        updateProviderProductUseCase: locator<UpdateProviderProductUseCase>(),
        updateProviderProductStatusUseCase:
            locator<UpdateProviderProductStatusUseCase>(),
        uploadProviderProductImageUseCase:
            locator<UploadProviderProductImageUseCase>(),
        setProviderProductMainImageUseCase:
            locator<SetProviderProductMainImageUseCase>(),
        deleteProviderProductImageUseCase:
            locator<DeleteProviderProductImageUseCase>(),
        providerReactivityService: locator<ProviderReactivityService>(),
        imagePicker: locator(),
      ),
      onViewModelReady: (EditProductViewModel model) => model.initialise(),
      builder: (context, model, child) {
        if (model.isBusy && !model.hasLoadedInitialData) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (model.generalErrorMessage != null && !model.hasLoadedInitialData) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  model.generalErrorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.secondaryText),
                ),
              ),
            ),
          );
        }

        final ServiceCategory category = model.category ?? ServiceCategory.dj;

        return Scaffold(
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
                if (model.generalErrorMessage != null) ...[
                  _ErrorBanner(message: model.generalErrorMessage!),
                  const SizedBox(height: 16),
                ],
                _StatusHeader(product: model.product),
                const SizedBox(height: 16),
                _buildSectionTitle('Informacion general'),
                _buildDynamicForm(model, category),
                const SizedBox(height: 24),
                _buildSectionTitle('Imagenes'),
                _ProductImagesSection(
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
                const SizedBox(height: 24),
                _buildSectionTitle('Descripcion'),
                _buildTextField(
                  '',
                  'Describe lo que ofreces...',
                  initialValue: model.formData.description,
                  maxLines: 3,
                  onChanged: model.updateDescription,
                  inputKind: ProviderFieldInputKind.mixedText,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Estado del producto'),
                _StatusActions(
                  model: model,
                  onPublish: () => _changeStatus(
                    context,
                    model.publish,
                    successMessage: 'Producto publicado.',
                  ),
                  onInactivate: () => _changeStatus(
                    context,
                    model.inactivate,
                    successMessage: 'Producto inactivado.',
                  ),
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
                        onPressed: () => _saveChanges(context, model),
                        isLoading: model.isBusy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveChanges(
    BuildContext context,
    EditProductViewModel model,
  ) async {
    final bool wasSaved = await model.saveChanges();
    if (!context.mounted || !wasSaved) {
      return;
    }

    Navigator.pop(context, true);
  }

  Future<void> _changeStatus(
    BuildContext context,
    Future<String?> Function() action, {
    required String successMessage,
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successMessage)));
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

  String _getCategoryLabel(ServiceCategory category) {
    if (category == ServiceCategory.furniture ||
        category == ServiceCategory.equipment) {
      return 'producto';
    }
    return 'servicio';
  }

  Widget _buildDynamicForm(
    EditProductViewModel model,
    ServiceCategory category,
  ) {
    final ProductFormData data = model.formData;

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
            errorText: model.fieldError('name'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Precio',
                  '\$ 0',
                  initialValue: _formatDouble(data.price),
                  prefix: '\$',
                  onChanged: model.updatePrice,
                  inputKind: ProviderFieldInputKind.decimal,
                  errorText: model.fieldError('price'),
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
                    '15 dias',
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
            'Duracion minima',
            '4 horas',
            initialValue: data.minDuration,
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
              initialValue: _formatDouble(data.extraHourPrice),
              prefix: '\$',
              onChanged: model.updateExtraHourPrice,
              inputKind: ProviderFieldInputKind.decimal,
            ),
          ],
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: 'Que incluye?',
            items: data.inclusions,
            onToggle: model.toggleInclusion,
          ),
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: 'Politicas',
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
            errorText: model.fieldError('name'),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Precio por persona',
            '\$ 0',
            initialValue: _formatDouble(data.price),
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
                  'Minimo invitados',
                  '50',
                  initialValue: data.minGuests?.toString(),
                  onChanged: model.updateMinGuests,
                  inputKind: ProviderFieldInputKind.integer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Maximo invitados',
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
            'Menu incluido',
            '...',
            initialValue: data.menuIncluded,
            maxLines: 2,
            onChanged: model.updateMenuIncluded,
            inputKind: ProviderFieldInputKind.mixedText,
          ),
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: 'Que incluye?',
            items: data.inclusions,
            onToggle: model.toggleInclusion,
          ),
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: 'Politicas',
            items: data.policies,
            onToggle: model.togglePolicy,
          ),
        ]);
      case ServiceCategory.venue:
        return _buildCard([
          _buildTextField(
            'Nombre del salon',
            'Salon Imperial',
            initialValue: data.name,
            onChanged: model.updateName,
            inputKind: ProviderFieldInputKind.title,
            errorText: model.fieldError('name'),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Capacidad maxima',
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
                  initialValue: _formatDouble(data.price),
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
            title: 'Que incluye?',
            items: data.inclusions,
            onToggle: model.toggleInclusion,
          ),
          const SizedBox(height: 24),
          DynamicSelectionList(
            title: 'Politicas',
            items: data.policies,
            onToggle: model.togglePolicy,
          ),
        ]);
      case ServiceCategory.decoration:
        return _buildCard([
          _buildTextField(
            'Nombre del paquete',
            'Decoracion Floral',
            initialValue: data.name,
            onChanged: model.updateName,
            inputKind: ProviderFieldInputKind.title,
            errorText: model.fieldError('name'),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'Tipo de evento',
            data.decorationType ?? 'Boda',
            ['Boda', 'Cumpleanos', 'XV anos', 'Infantil'],
            model.updateDecorationType,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Precio base',
                  '\$ 0',
                  initialValue: _formatDouble(data.price),
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
            title: 'Politicas',
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
            errorText: model.fieldError('name'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Precio unidad',
                  '\$ 0',
                  initialValue: _formatDouble(data.price),
                  prefix: '\$',
                  onChanged: model.updatePrice,
                  inputKind: ProviderFieldInputKind.decimal,
                  errorText: model.fieldError('price'),
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
            title: 'Politicas',
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
    String? initialValue,
    String? prefix,
    IconData? suffixIcon,
    int maxLines = 1,
    Function(String)? onChanged,
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
              errorText: errorText,
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

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primaryText,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.appBar,
            onChanged: onChanged,
          ),
        ],
      );

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

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.product});

  final ProviderProduct? product;

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const SizedBox.shrink();
    }

    final (String label, Color color) = _resolveStatus(product!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              product!.priceLabel,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _resolveStatus(ProviderProduct product) {
    if (product.isPublished) {
      return ('Publicado', Colors.green);
    }
    if (product.isInactive) {
      return ('Inactivo', Colors.red);
    }
    return ('Borrador', Colors.orange);
  }
}

class _ProductImagesSection extends StatelessWidget {
  const _ProductImagesSection({
    required this.model,
    required this.onAddImage,
    required this.onMarkAsMain,
    required this.onDeleteImage,
  });

  final EditProductViewModel model;
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

    return SizedBox(
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

          final ProviderProductImage image = model.images[index - 1];
          final bool isMutating = model.mutatingImageKey == image.key;
          return _ProductImageCard(
            image: image,
            isMutating: isMutating,
            onMakeMain: image.isMain ? null : () => onMarkAsMain(image.key),
            onDelete: () => onDeleteImage(image.key),
          );
        },
      ),
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
        children: [
          const Text(
            'Todavia no agregas fotos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sube una imagen principal para que el producto se vea en Client cuando este publicado.',
            style: TextStyle(
              color: AppColors.secondaryText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
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
          children: [
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
          ],
        ),
      ),
    );
  }
}

class _ProductImageCard extends StatelessWidget {
  const _ProductImageCard({
    required this.image,
    required this.isMutating,
    required this.onDelete,
    this.onMakeMain,
  });

  final ProviderProductImage image;
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
        children: [
          Expanded(
            child: Stack(
              children: [
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

class _StatusActions extends StatelessWidget {
  const _StatusActions({
    required this.model,
    required this.onPublish,
    required this.onInactivate,
  });

  final EditProductViewModel model;
  final VoidCallback onPublish;
  final VoidCallback onInactivate;

  @override
  Widget build(BuildContext context) {
    final ProviderProduct? product = model.product;
    if (product == null) {
      return const SizedBox.shrink();
    }

    if (product.isPublished) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: model.isBusy ? null : onInactivate,
          child: const Text('Inactivar producto'),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: model.isBusy ? null : onInactivate,
            child: const Text('Dejar inactivo'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: model.isBusy ? null : onPublish,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.appBar),
            child: const Text(
              'Publicar producto',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
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

String _formatDouble(double value) {
  final String fixed = value.toStringAsFixed(
    value.truncateToDouble() == value ? 0 : 2,
  );
  return fixed;
}
