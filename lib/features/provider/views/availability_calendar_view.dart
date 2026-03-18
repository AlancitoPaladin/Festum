import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/custom_app_bar.dart';
import 'package:festum/features/provider/viewmodels/availability_calendar_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stacked/stacked.dart';

class AvailabilityCalendarView extends StatelessWidget {
  final String productId;
  final String productName;

  const AvailabilityCalendarView({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AvailabilityCalendarViewModel>.reactive(
      viewModelBuilder: () => AvailabilityCalendarViewModel(
        productId: productId,
        productName: productName,
      ),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: productName,
          showBackButton: true,
        ),
        body: Column(
          children: [
            _buildCalendarHeader(model),
            Expanded(
              child: _buildCalendarGrid(context, model),
            ),
            _buildLegend(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader(AvailabilityCalendarViewModel model) {
    final months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    final currentMonth = months[model.focusedDay.month - 1];
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$currentMonth ${model.focusedDay.year}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: model.previousMonth),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: model.nextMonth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, AvailabilityCalendarViewModel model) {
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final daysInMonth = DateUtils.getDaysInMonth(model.focusedDay.year, model.focusedDay.month);
    final firstDayOffset = DateTime(model.focusedDay.year, model.focusedDay.month, 1).weekday - 1;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((d) => Text(d, style: const TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.bold))).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: daysInMonth + firstDayOffset,
              itemBuilder: (context, index) {
                if (index < firstDayOffset) return const SizedBox.shrink();
                
                final day = index - firstDayOffset + 1;
                final date = DateTime(model.focusedDay.year, model.focusedDay.month, day);
                final status = model.getStatus(date);
                
                return GestureDetector(
                  onTap: () => _showDayDetails(context, model, date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$day', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        _buildStatusIndicator(status),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(DayStatus status) {
    Color color;
    switch (status) {
      case DayStatus.available: color = Colors.green; break;
      case DayStatus.reserved: color = Colors.red; break;
      case DayStatus.blocked: color = Colors.black87; break;
    }
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const _LegendItem(color: Colors.green, label: 'Disponible'),
          const _LegendItem(color: Colors.red, label: 'Reservado'),
          const _LegendItem(color: Colors.black87, label: 'Bloqueado'),
        ],
      ),
    );
  }

  void _showDayDetails(BuildContext context, AvailabilityCalendarViewModel model, DateTime date) {
    final status = model.getStatus(date);
    final booking = model.getBooking(date);
    final dateStr = "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status == DayStatus.reserved ? 'Reserva' : 'Disponible',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (status == DayStatus.reserved && booking != null) ...[
              Row(
                children: [
                  CircleAvatar(backgroundImage: NetworkImage(booking.customerImageUrl)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Evento: ${booking.eventType}', style: const TextStyle(color: AppColors.secondaryText)),
                      Text('Personas: ${booking.guests}', style: const TextStyle(color: AppColors.secondaryText)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _ActionButton(
                label: 'Ver detalles', 
                color: AppColors.appBar, 
                textColor: Colors.white, 
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.providerBookingDetailRoute(dateStr));
                }
              ),
              const SizedBox(height: 12),
              _ActionButton(label: 'Cancelar reserva', color: Colors.transparent, textColor: Colors.red, onPressed: () {}),
            ] else ...[
              Text('Fecha: ${date.day}/${date.month}/${date.year}', style: const TextStyle(color: AppColors.secondaryText)),
              const SizedBox(height: 24),
              _ActionButton(
                label: 'Crear reserva manual', 
                color: AppColors.appBar, 
                textColor: Colors.white, 
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.providerManualBookingRoute(dateStr));
                }
              ),
              const SizedBox(height: 12),
              _ActionButton(
                label: status == DayStatus.blocked ? 'Desbloquear fecha' : 'Bloquear fecha', 
                color: AppColors.backgroundElevated, 
                textColor: AppColors.primaryText, 
                onPressed: () {
                  status == DayStatus.blocked ? model.unblockDate(date) : model.blockDate(date);
                  Navigator.pop(context);
                }
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const _ActionButton({required this.label, required this.color, required this.textColor, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: color == Colors.transparent ? const BorderSide(color: Colors.red) : BorderSide.none),
        ),
        child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
