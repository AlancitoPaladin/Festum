import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/custom_app_bar.dart';
import 'package:festum/features/provider/models/booking.dart';
import 'package:festum/features/provider/usecases/create_manual_booking_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_booking_use_case.dart';
import 'package:festum/features/provider/utils/provider_field_input.dart';
import 'package:festum/features/provider/viewmodels/manual_booking_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

class ManualBookingView extends StatelessWidget {
  const ManualBookingView({
    super.key,
    required this.productId,
    this.initialDate,
    this.initialBooking,
  });

  final String productId;
  final DateTime? initialDate;
  final Booking? initialBooking;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ManualBookingViewModel>.reactive(
      viewModelBuilder: () => ManualBookingViewModel(
        productId: productId,
        createManualBookingUseCase: locator<CreateManualBookingUseCase>(),
        updateProviderBookingUseCase: locator<UpdateProviderBookingUseCase>(),
        providerReactivityService: locator<ProviderReactivityService>(),
        initialDate: initialDate,
        initialBooking: initialBooking,
      ),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(title: model.screenTitle, showBackButton: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                model.introText,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionCard(
                title: 'Datos principales',
                subtitle:
                    'Llena lo esencial y usa el horario solo si necesitas apartar una franja específica.',
                children: [
                  _buildField(
                    label: 'Nombre del cliente',
                    hint: 'Ej: Juan Pérez',
                    controller: model.customerNameController,
                    inputKind: ProviderFieldInputKind.title,
                  ),
                  const SizedBox(height: 16),
                  _buildPickerField(
                    context,
                    'Fecha',
                    model.selectedDate == null
                        ? 'Seleccionar'
                        : _formatDate(model.selectedDate!),
                    Icons.calendar_today_outlined,
                    () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: model.pickerInitialDate,
                        firstDate: model.minimumSelectableDate,
                        lastDate: model.minimumSelectableDate.add(
                          const Duration(days: 365),
                        ),
                      );
                      if (date != null) {
                        model.setDate(date);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    title: 'Agregar horario específico',
                    subtitle:
                        'Si lo dejas apagado, la reserva queda como recordatorio o bloqueo general del día.',
                    value: model.hasSpecificSchedule,
                    onChanged: model.toggleSpecificSchedule,
                  ),
                  if (model.hasSpecificSchedule) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPickerField(
                            context,
                            'Hora de inicio',
                            model.startTime == null
                                ? 'Seleccionar'
                                : model.startTime!.format(context),
                            Icons.access_time,
                            () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: model.startTime ?? TimeOfDay.now(),
                              );
                              if (time != null) {
                                model.setStartTime(time);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPickerField(
                            context,
                            'Hora de fin',
                            model.endTime == null
                                ? 'Seleccionar'
                                : model.endTime!.format(context),
                            Icons.schedule_outlined,
                            () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime:
                                    model.endTime ??
                                    model.startTime ??
                                    TimeOfDay.now(),
                              );
                              if (time != null) {
                                model.setEndTime(time);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Tipo de evento',
                    hint: 'Ej. Boda, XV años...',
                    controller: model.eventTypeController,
                    inputKind: ProviderFieldInputKind.title,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Cantidad de personas',
                    hint: '0',
                    controller: model.guestsController,
                    inputKind: ProviderFieldInputKind.integer,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: 'Detalles opcionales',
                subtitle:
                    'Sirven como recordatorio rápido para que no se te escape información importante.',
                children: [
                  _buildField(
                    label: 'Teléfono / WhatsApp',
                    hint: 'Ej: 55 1234 5678',
                    controller: model.contactPhoneController,
                    inputKind: ProviderFieldInputKind.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Correo',
                    hint: 'cliente@correo.com',
                    controller: model.contactEmailController,
                    inputKind: ProviderFieldInputKind.mixedText,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Ubicacion',
                    hint: 'Ej: Jardín Las Palmas, Monterrey',
                    controller: model.eventLocationController,
                    inputKind: ProviderFieldInputKind.mixedText,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Notas / detalles extra',
                    hint:
                        'Describe acuerdos especiales, dudas o cosas por confirmar...',
                    controller: model.notesController,
                    maxLines: 3,
                    inputKind: ProviderFieldInputKind.mixedText,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: 'Pago',
                subtitle:
                    'Registra el monto total y lo que ya recibiste para llevar control del saldo.',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          label: 'Monto total',
                          hint: '0.00',
                          controller: model.totalAmountController,
                          inputKind: ProviderFieldInputKind.decimal,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildField(
                          label: 'Monto pagado',
                          hint: '0.00',
                          controller: model.paidAmountController,
                          inputKind: ProviderFieldInputKind.decimal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevated,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Pendiente',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${model.formatCurrency(model.pendingAmount)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.appBar,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: model.isBusy
                      ? null
                      : () => _saveBooking(context, model),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appBar,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: model.isBusy
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          model.actionLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveBooking(
    BuildContext context,
    ManualBookingViewModel model,
  ) async {
    final Booking? booking = await model.saveBooking();
    if (!context.mounted) {
      return;
    }

    if (booking == null) {
      final String message =
          model.errorMessage ??
          (model.isEditMode
              ? 'No se pudo actualizar la reserva.'
              : 'No se pudo crear la reserva manual.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          model.isEditMode ? 'Reserva actualizada.' : 'Reserva manual creada.',
        ),
      ),
    );
    Navigator.pop(context, true);
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    ProviderFieldInputKind inputKind = ProviderFieldInputKind.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.appBar,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPickerField(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.secondaryText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: value == 'Seleccionar'
                          ? Colors.black26
                          : AppColors.primaryText,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
