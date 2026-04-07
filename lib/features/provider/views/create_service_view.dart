import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/usecases/create_provider_service_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_service_status_use_case.dart';
import 'package:festum/features/provider/utils/provider_field_input.dart';
import 'package:festum/features/provider/viewmodels/create_service_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:stacked/stacked.dart';

class CreateServiceView extends StatelessWidget {
  const CreateServiceView({super.key});

  static final GlobalKey _nameFieldKey = GlobalKey();
  static final GlobalKey _subtitleFieldKey = GlobalKey();
  static final GlobalKey _categoryFieldKey = GlobalKey();
  static final GlobalKey _priceFieldKey = GlobalKey();
  static final GlobalKey _descriptionFieldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateServiceViewModel>.reactive(
      viewModelBuilder: () => CreateServiceViewModel(
        locator<CreateProviderServiceUseCase>(),
        locator<UpdateProviderServiceStatusUseCase>(),
        locator<ProviderReactivityService>(),
      ),
      builder: (BuildContext context, CreateServiceViewModel model, _) {
        return PopScope(
          canPop: !model.hasPendingChanges,
          onPopInvokedWithResult: (bool didPop, Object? result) async {
            if (didPop) {
              return;
            }
            final bool allowExit = await _handleExit(context, model);
            if (!context.mounted || !allowExit) {
              return;
            }
            Navigator.of(context).pop();
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primaryText,
                ),
                onPressed: () async {
                  final bool allowExit = await _handleExit(context, model);
                  if (!context.mounted || !allowExit) {
                    return;
                  }
                  Navigator.of(context).pop();
                },
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
                    'Completa solo la información esencial. Podrás agregar productos y fotos después.',
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
                  KeyedSubtree(
                    key: _nameFieldKey,
                    child: _buildTextField(
                      controller: model.nameController,
                      label: 'Nombre del servicio',
                      hint: 'Ej. Salón para eventos',
                      onChanged: model.updateName,
                      inputKind: ProviderFieldInputKind.title,
                      errorText: model.fieldError('name'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  KeyedSubtree(
                    key: _subtitleFieldKey,
                    child: _buildTextField(
                      controller: model.subtitleController,
                      label: 'Subtítulo',
                      hint: 'Ej. Hasta 250 invitados',
                      onChanged: model.updateSubtitle,
                      inputKind: ProviderFieldInputKind.mixedText,
                      errorText: model.fieldError('subtitle'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  KeyedSubtree(
                    key: _categoryFieldKey,
                    child: _buildDropdownField(model),
                  ),
                  const SizedBox(height: 16),
                  KeyedSubtree(
                    key: _descriptionFieldKey,
                    child: _buildTextField(
                      controller: model.descriptionController,
                      label: 'Descripción del servicio',
                      hint: 'Describe tu servicio, ¿qué ofreces?',
                      maxLines: 4,
                      onChanged: model.updateDescription,
                      inputKind: ProviderFieldInputKind.mixedText,
                      errorText: model.fieldError('description'),
                    ),
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
                  KeyedSubtree(
                    key: _priceFieldKey,
                    child: _buildTextField(
                      controller: model.unitPriceController,
                      label: 'Precio de referencia (MXN)',
                      hint: 'Ej. 12000',
                      onChanged: model.updateUnitPrice,
                      inputKind: ProviderFieldInputKind.currency,
                      errorText: model.fieldError('unit_price_cents'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PricePreviewCard(cents: model.formData.unitPriceCents),
                  const SizedBox(height: 10),
                  const _InfoCard(
                    title: 'Cómo se muestra en Cliente.',
                    subtitle:
                        'Este precio funciona como referencia inicial. Cuando existan productos publicados, el backend puede calcular el precio final mostrado al cliente.',
                  ),
                  const SizedBox(height: 16),
                  _ClientPreviewCard(
                    name: model.previewName,
                    subtitle: model.previewSubtitle,
                    priceLabel: model.previewPriceLabel,
                    badge: model.previewBadge,
                    category: model.selectedCategory,
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
                        'En cuanto se cree el servicio, te llevaremos a la pantalla de edición para agregar imágenes.',
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: model.isBusy || !model.canSubmit
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
      },
    );
  }

  Future<void> _save(BuildContext context, CreateServiceViewModel model) async {
    final ProviderService? createdService = await model.saveService();
    if (!context.mounted) {
      return;
    }
    if (createdService == null) {
      await _scrollToFirstError(context, model.firstErrorField);
      return;
    }

    final bool publishNow = await _askPublishNow(context);
    if (!context.mounted) {
      return;
    }

    if (publishNow) {
      final String? publishError = await model.publishService(
        createdService.id,
      );
      if (!context.mounted) {
        return;
      }
      if (publishError != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(publishError)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Servicio publicado. Si no aparece en Cliente, publica al menos un producto de este servicio.',
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Servicio guardado en borrador. Publícalo desde Mis servicios para verlo en Cliente.',
          ),
        ),
      );
    }

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

  Future<void> _scrollToFirstError(
    BuildContext context,
    String? firstErrorField,
  ) async {
    if (firstErrorField == null) {
      return;
    }
    final GlobalKey? key = switch (firstErrorField) {
      'name' => _nameFieldKey,
      'subtitle' => _subtitleFieldKey,
      'category' => _categoryFieldKey,
      'unit_price_cents' => _priceFieldKey,
      'description' => _descriptionFieldKey,
      _ => null,
    };
    final BuildContext? targetContext = key?.currentContext;
    if (targetContext == null) {
      return;
    }
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: 0.2,
    );
  }

  Future<bool> _askPublishNow(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Publicar servicio'),
          content: const Text(
            '¿Quieres publicarlo ahora para que pueda mostrarse en Cliente?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Dejar en borrador'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Publicar ahora'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<bool> _handleExit(
    BuildContext context,
    CreateServiceViewModel model,
  ) async {
    if (!model.hasPendingChanges) {
      return true;
    }
    final bool? shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Salir sin guardar'),
          content: const Text(
            'Hay cambios sin guardar. ¿Quieres salir y descartarlos?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Descartar'),
            ),
          ],
        );
      },
    );
    return shouldDiscard ?? false;
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
            'Categoría',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<ServiceCategory>(
              value: model.selectedCategory,
              hint: const Text(
                'Selecciona una categoría',
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

class _PricePreviewCard extends StatelessWidget {
  const _PricePreviewCard({required this.cents});

  final int cents;

  @override
  Widget build(BuildContext context) {
    final String centsLabel = _formatInteger(cents);
    final String amountLabel = _formatMxAmount(cents);
    final bool hasInvalidAmount = cents <= 0;
    final Color borderColor = hasInvalidAmount
        ? Colors.orange.withValues(alpha: 0.45)
        : Colors.transparent;
    final Color backgroundColor = hasInvalidAmount
        ? Colors.orange.withValues(alpha: 0.10)
        : AppColors.backgroundElevated.withValues(alpha: 0.6);
    final Color textColor = hasInvalidAmount
        ? Colors.orange.shade800
        : AppColors.secondaryText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (hasInvalidAmount) ...<Widget>[
            Text(
              'Advertencia: el precio debe ser mayor a 0.',
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            'Se enviará: unit_price_cents = $centsLabel',
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Equivalente: $amountLabel MXN',
            style: TextStyle(color: textColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ClientPreviewCard extends StatelessWidget {
  const _ClientPreviewCard({
    required this.name,
    required this.subtitle,
    required this.priceLabel,
    required this.badge,
    required this.category,
  });

  final String name;
  final String subtitle;
  final String priceLabel;
  final String badge;
  final ServiceCategory? category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardAccent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Vista previa en Cliente.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Icon(_iconFor(category), color: AppColors.activeIcon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (badge.trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryButton.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 8),
          Text(
            priceLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.activeIcon,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(ServiceCategory? category) {
  switch (category) {
    case ServiceCategory.venue:
      return Icons.apartment_rounded;
    case ServiceCategory.furniture:
    case ServiceCategory.equipment:
      return Icons.chair_alt_rounded;
    case ServiceCategory.banquet:
      return Icons.restaurant_menu_rounded;
    case ServiceCategory.dj:
      return Icons.music_note_rounded;
    case ServiceCategory.decoration:
      return Icons.celebration_rounded;
    case ServiceCategory.photography:
      return Icons.camera_alt_rounded;
    case ServiceCategory.entertainment:
      return Icons.theater_comedy_rounded;
    case null:
      return Icons.miscellaneous_services_rounded;
  }
}

String _formatInteger(int value) {
  final String raw = value.abs().toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < raw.length; i++) {
    final int reverseIndex = raw.length - i;
    buffer.write(raw[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }
  final String formatted = buffer.toString();
  return value < 0 ? '-$formatted' : formatted;
}

String _formatMxAmount(int cents) {
  final int whole = cents ~/ 100;
  final int fraction = cents.abs() % 100;
  final String wholeLabel = _formatInteger(whole);
  final String fractionLabel = fraction.toString().padLeft(2, '0');
  return '\$$wholeLabel.$fractionLabel';
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle});

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
  const _PhotoPlaceholderCard({required this.title, required this.subtitle});

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
