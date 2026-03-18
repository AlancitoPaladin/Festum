import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/custom_app_bar.dart';
import 'package:festum/features/provider/models/booking.dart';
import 'package:festum/features/provider/viewmodels/booking_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class BookingDetailView extends StatelessWidget {
  final Booking booking;

  const BookingDetailView({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BookingDetailViewModel>.reactive(
      viewModelBuilder: () => BookingDetailViewModel(booking),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Detalle de reserva', showBackButton: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerHeader(),
              const SizedBox(height: 32),
              _buildInfoSection('Información del evento', [
                _buildInfoRow(Icons.event_outlined, 'Fecha', "${booking.date.day}/${booking.date.month}/${booking.date.year}"),
                _buildInfoRow(Icons.access_time, 'Hora', booking.time),
                _buildInfoRow(Icons.celebration_outlined, 'Evento', booking.eventType),
                _buildInfoRow(Icons.people_outline, 'Invitados', "${booking.guests} personas"),
              ]),
              const SizedBox(height: 24),
              _buildInfoSection('Estado del pago', [
                _buildInfoRow(Icons.payments_outlined, 'Total', "\$${booking.totalAmount}", isBold: true),
                _buildInfoRow(Icons.check_circle_outline, 'Pagado', "\$${booking.paidAmount}", color: Colors.green),
                _buildInfoRow(Icons.pending_actions, 'Pendiente', "\$${booking.pendingAmount}", color: Colors.orange),
              ]),
              if (booking.notes.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildInfoSection('Notas adicionales', [
                  Text(booking.notes, style: const TextStyle(color: AppColors.secondaryText, height: 1.5)),
                ]),
              ],
              const SizedBox(height: 48),
              _buildActions(model),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(booking.customerImageUrl),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.customerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.appBar.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                booking.status,
                style: const TextStyle(color: AppColors.appBar, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.secondaryText),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.secondaryText)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BookingDetailViewModel model) {
    return Column(
      children: [
        _buildFullButton('Contactar cliente', Icons.chat_bubble_outline, AppColors.appBar, Colors.white, model.contactCustomer),
        const SizedBox(height: 12),
        _buildFullButton('Modificar reserva', Icons.edit_outlined, AppColors.backgroundElevated, AppColors.primaryText, model.modifyBooking),
        const SizedBox(height: 12),
        TextButton(
          onPressed: model.cancelBooking,
          child: const Text('Cancelar reserva', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildFullButton(String text, IconData icon, Color bg, Color textCol, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textCol, size: 20),
        label: Text(text, style: TextStyle(color: textCol, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(backgroundColor: bg, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}
