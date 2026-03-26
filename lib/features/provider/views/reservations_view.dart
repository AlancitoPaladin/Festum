import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/network/api_url_resolver.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/custom_app_bar.dart';
import 'package:festum/features/provider/models/provider_order_request.dart';
import 'package:festum/features/provider/models/product_reservations_response.dart';
import 'package:festum/features/provider/usecases/decide_provider_order_request_use_case.dart';
import 'package:festum/features/provider/usecases/delete_provider_product_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_order_requests_use_case.dart';
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
        locator<GetProviderOrderRequestsUseCase>(),
        locator<GetProviderProductReservationsUseCase>(),
        locator<DecideProviderOrderRequestUseCase>(),
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
    if (model.isBusy && model.products.isEmpty && model.requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.errorMessage != null &&
        model.products.isEmpty &&
        model.requests.isEmpty) {
      return _ReservationsErrorState(
        message: model.errorMessage!,
        onRetry: model.initialise,
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Text(
              'Gestiona solicitudes de clientes y disponibilidad por producto.',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: TabBar(
              labelColor: AppColors.primaryText,
              unselectedLabelColor: AppColors.secondaryText,
              indicatorColor: AppColors.activeIcon,
              tabs: <Tab>[
                Tab(text: 'Solicitudes'),
                Tab(text: 'Reservas'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                RefreshIndicator(
                  onRefresh: model.initialise,
                  child: model.requests.isEmpty
                      ? const _EmptyOrderRequestsState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                          itemCount: model.requests.length,
                          itemBuilder: (context, index) {
                            final ProviderOrderRequest request =
                                model.requests[index];
                            return _OrderRequestCard(
                              request: request,
                              isBusy: model.isDeciding(request.id),
                              onAccept: () => _decideRequest(
                                context,
                                model,
                                requestId: request.id,
                                accept: true,
                              ),
                              onReject: () => _decideRequest(
                                context,
                                model,
                                requestId: request.id,
                                accept: false,
                              ),
                            );
                          },
                        ),
                ),
                RefreshIndicator(
                  onRefresh: model.initialise,
                  child: model.products.isEmpty
                      ? const _EmptyReservationsState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                          itemCount: model.products.length,
                          itemBuilder: (context, index) {
                            final ProductReservationSummary product =
                                model.products[index];
                            return _ProductReservationCard(
                              product: product,
                              onDelete: () =>
                                  _deleteProduct(context, model, product.id),
                              onEdit: () =>
                                  model.editProduct(context, product.id),
                              onManage: () => model.manageAvailability(
                                context,
                                product.id,
                                product.productName,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Producto eliminado.')));
  }

  Future<void> _decideRequest(
    BuildContext context,
    ReservationsViewModel model, {
    required String requestId,
    required bool accept,
  }) async {
    final String? errorMessage = await model.decideRequest(
      requestId: requestId,
      accept: accept,
    );
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
      SnackBar(
        content: Text(
          accept
              ? 'Solicitud aceptada y reserva confirmada.'
              : 'Solicitud rechazada.',
        ),
      ),
    );
  }
}

class _ReservationsErrorState extends StatelessWidget {
  const _ReservationsErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const <Widget>[
        SizedBox(height: 120),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Todavia no tienes productos con reservaciones para gestionar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyOrderRequestsState extends StatelessWidget {
  const _EmptyOrderRequestsState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const <Widget>[
        SizedBox(height: 120),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'No tienes solicitudes pendientes por aprobar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderRequestCard extends StatelessWidget {
  const _OrderRequestCard({
    required this.request,
    required this.isBusy,
    required this.onAccept,
    required this.onReject,
  });

  final ProviderOrderRequest request;
  final bool isBusy;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final DateTime? eventDate = request.eventDate;
    final String dateLabel = eventDate == null
        ? '-'
        : '${eventDate.day.toString().padLeft(2, '0')}/'
              '${eventDate.month.toString().padLeft(2, '0')}/'
              '${eventDate.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            request.resolvedServiceName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Cliente: ${request.resolvedClientName}',
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          if (request.productName.trim().isNotEmpty)
            Text(
              'Producto: ${request.productName}',
              style: const TextStyle(color: AppColors.secondaryText),
            ),
          Text(
            'Fecha solicitada: $dateLabel',
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          Text(
            'Total: ${request.resolvedTotalLabel}',
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          if (request.notes.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Notas: ${request.notes}',
              style: const TextStyle(color: AppColors.secondaryText),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isBusy ? null : onReject,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Rechazar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isBusy ? null : onAccept,
                  icon: isBusy
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: const Text('Aceptar'),
                ),
              ),
            ],
          ),
        ],
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
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
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
              children: <Widget>[
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
        children: <Widget>[
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
            children: <Widget>[
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
                        size: 18,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      booking.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$dateStr • ${booking.eventType}',
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
