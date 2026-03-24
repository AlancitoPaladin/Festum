import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/custom_app_bar.dart';
import 'package:festum/features/provider/viewmodels/manual_booking_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ManualBookingView extends StatelessWidget {
  const ManualBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ManualBookingViewModel>.reactive(
      viewModelBuilder: () => ManualBookingViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(
          title: 'Reserva manual',
          showBackButton: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registra una reserva externa para bloquear la fecha en tu calendario.',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
              ),
              const SizedBox(height: 32),
              _buildSectionCard(
                title: 'Datos principales',
                subtitle:
                    'Llena lo esencial y usa el horario solo si necesitas apartar una franja específica.',
                children: [
                  _buildField(
                    'Nombre del cliente',
                    'Ej: Juan Pérez',
                    (v) => model.customerName = v,
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
                      final now = DateTime.now();
                      final date = await showDatePicker(
                        context: context,
                        initialDate: model.selectedDate ?? now,
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 365)),
                      );
                      if (date != null) model.setDate(date);
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
                              if (time != null) model.setStartTime(time);
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
                              if (time != null) model.setEndTime(time);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildField(
                    'Tipo de evento',
                    'Ej: Boda, XV años...',
                    (v) => model.eventType = v,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    'Cantidad de personas',
                    '0',
                    (v) => model.guests = int.tryParse(v) ?? 0,
                    keyboardType: TextInputType.number,
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
                    'Teléfono / WhatsApp',
                    'Ej: 55 1234 5678',
                    (v) => model.contactPhone = v,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    'Correo',
                    'cliente@correo.com',
                    (v) => model.contactEmail = v,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    'Ubicación',
                    'Ej: Jardín Las Palmas, Monterrey',
                    (v) => model.eventLocation = v,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    'Pago / anticipo',
                    'Ej: Anticipo de \$2,000 recibido, resto pendiente',
                    (v) => model.paymentDetails = v,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    'Notas / detalles extra',
                    'Describe acuerdos especiales, dudas o cosas por confirmar...',
                    (v) => model.notes = v,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: model.isBusy ? null : model.saveBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appBar,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: model.isBusy
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirmar reserva',
                          style: TextStyle(
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

  Widget _buildField(
    String label,
    String hint,
    Function(String) onChanged, {
    int maxLines = 1,
    TextInputType? keyboardType,
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
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
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
