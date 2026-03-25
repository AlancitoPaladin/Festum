import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/network/api_url_resolver.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/custom_app_bar.dart';
import 'package:festum/features/provider/models/product_reservations_response.dart';
import 'package:festum/features/provider/usecases/delete_provider_product_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_product_reservations_use_case.dart';
import 'package:festum/features/provider/viewmodels/reservations_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ReservationsView extends StatelessWidget {
  const ReservationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReservationsViewModel>.reactive(
      viewModelBuilder: () => ReservationsViewModel(
        locator<GetProviderProductReservationsUseCase>(),
        locator<DeleteProviderProductUseCase>(),
        locator<ProviderReactivityService>(),
      ),
      onViewModelReady: (ReservationsViewModel model) => model.initialise(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Gestion de reservas'),
        body: _buildBody(context, model),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReservationsViewModel model) {
    if (model.isBusy && model.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.errorMessage != null && model.products.isEmpty) {
      return _ReservationsErrorState(
        message: model.errorMessage!,
        onRetry: model.initialise,
      );
    }

    if (model.products.isEmpty) {
      return const _EmptyReservationsState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Text(
            'Monitorea tus rentas y gestiona la disponibilidad por fechas.',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: model.initialise,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              itemCount: model.products.length,
              itemBuilder: (context, index) {
                final ProductReservationSummary product =
                    model.products[index];
                return _ProductReservationCard(
                  product: product,
                  onDelete: () => _deleteProduct(context, model, product.id),
                  onEdit: () => model.editProduct(context, product.id),
                  onManage: () => model.manageAvailability(
                    context,
                    product.id,
                    product.productName,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteProduct(
    BuildContext context,
    ReservationsViewModel model,
    String productId,
  ) async {
    final String? errorMessage = await model.deleteProduct(productId);
    if (!context.mounted) {
      return;
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado.')),
    );
  }
}

class _ReservationsErrorState extends StatelessWidget {
  const _ReservationsErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_busy_outlined,
              size: 34,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onRetry(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyReservationsState extends StatelessWidget {
  const _EmptyReservationsState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          'Todavia no tienes productos con reservaciones para gestionar.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondaryText,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _ProductReservationCard extends StatelessWidget {
  const _ProductReservationCard({
    required this.product,
    required this.onDelete,
    required this.onEdit,
    required this.onManage,
  });

  final ProductReservationSummary product;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final String resolvedImageUrl = resolveApiAssetUrl(product.imageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        product.category.label,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.alert,
                    size: 22,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          Container(
            height: 160,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              borderRadius: BorderRadius.circular(12),
              image: resolvedImageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(resolvedImageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: resolvedImageUrl.isEmpty
                ? const Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: Colors.black12,
                  )
                : null,
          ),
          if (product.nextBooking != null)
            _NextBookingInfo(booking: product.nextBooking!),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.black12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Editar producto',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onManage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B58AD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Disponibilidad',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

class _NextBookingInfo extends StatelessWidget {
  const _NextBookingInfo({required this.booking});

  final ReservationBookingSummary booking;

  @override
  Widget build(BuildContext context) {
    final String dateStr =
        '${booking.date.day}/${booking.date.month}/${booking.date.year}';
    final String resolvedImageUrl = resolveApiAssetUrl(
      booking.customerImageUrl,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROXIMA RENTA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.backgroundElevated,
                backgroundImage: resolvedImageUrl.isEmpty
                    ? null
                    : NetworkImage(resolvedImageUrl),
                child: resolvedImageUrl.isEmpty
                    ? const Icon(
                        Icons.person_outline,
                        color: AppColors.secondaryText,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: booking.status == 'Confirmada'
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.status,
                  style: TextStyle(
                    color: booking.status == 'Confirmada'
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
