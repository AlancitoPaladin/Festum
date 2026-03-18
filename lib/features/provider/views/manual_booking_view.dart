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
        appBar: const CustomAppBar(title: 'Reserva manual', showBackButton: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Registra una reserva externa para bloquear la fecha en tu calendario.', style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
              const SizedBox(height: 32),
              _buildField('Nombre del cliente', 'Ej: Juan Pérez', (v) => model.customerName = v),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPickerField(
                      context, 
                      'Fecha', 
                      model.selectedDate == null ? 'Seleccionar' : "${model.selectedDate!.day}/${model.selectedDate!.month}/${model.selectedDate!.year}",
                      Icons.calendar_today_outlined,
                      () async {
                        final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                        if (date != null) model.setDate(date);
                      }
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPickerField(
                      context, 
                      'Hora', 
                      model.selectedTime == null ? 'Seleccionar' : model.selectedTime!.format(context),
                      Icons.access_time,
                      () async {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null) model.setTime(time);
                      }
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildField('Tipo de evento', 'Ej: Boda, XV años...', (v) => model.eventType = v),
              const SizedBox(height: 16),
              _buildField('Cantidad de personas', '0', (v) => model.guests = int.tryParse(v) ?? 0, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildField('Notas / Detalles extra', 'Describe acuerdos especiales...', (v) => model.notes = v, maxLines: 3),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: model.saveBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appBar,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: model.isBusy 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirmar reserva', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, Function(String) onChanged, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
          child: TextField(
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.black26, fontSize: 14), border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerField(BuildContext context, String label, String value, IconData icon, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.secondaryText),
                const SizedBox(width: 8),
                Text(value, style: TextStyle(color: value == 'Seleccionar' ? Colors.black26 : AppColors.primaryText, fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
