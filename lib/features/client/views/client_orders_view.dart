import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/network/api_error_mapper.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_order_item.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:festum/features/client/usecases/get_client_orders_use_case.dart';
import 'package:festum/features/client/usecases/update_client_order_status_use_case.dart';
import 'package:festum/features/client/widgets/client_feedback.dart';
import 'package:festum/features/client/widgets/client_shell_scaffold.dart';
import 'package:festum/features/client/widgets/client_status_view.dart';
import 'package:festum/features/client/widgets/order_status_chip.dart';
import 'package:festum/features/client/widgets/staggered_appear.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientOrdersView extends StatefulWidget {
  const ClientOrdersView({super.key});

  @override
  State<ClientOrdersView> createState() => _ClientOrdersViewState();
}

class _ClientOrdersViewState extends State<ClientOrdersView> {
  late final GetClientOrdersUseCase _getClientOrdersUseCase;
  late final UpdateClientOrderStatusUseCase _updateClientOrderStatusUseCase;
  late final ClientTabUiStateService _tabUiStateService;
  late final ScrollController _scrollController;

  bool _isLoading = true;
  String? _errorMessage;
  List<ClientOrderItem> _orders = <ClientOrderItem>[];
  Set<String> _highlightedOrderIds = <String>{};
  bool _showCancelledOrders = false;

  @override
  void initState() {
    super.initState();
    _getClientOrdersUseCase = locator<GetClientOrdersUseCase>();
    _updateClientOrderStatusUseCase = locator<UpdateClientOrderStatusUseCase>();
    _tabUiStateService = locator<ClientTabUiStateService>();
    _scrollController = ScrollController(
      initialScrollOffset: _tabUiStateService.scrollOffsetFor(ClientTab.orders),
    )..addListener(_onScroll);

    _loadOrders(showLoader: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _tabUiStateService.saveScrollOffset(
      ClientTab.orders,
      _scrollController.offset,
    );
  }

  Future<void> _loadOrders({required bool showLoader}) async {
    if (showLoader) {
      setState(() => _isLoading = true);
    }

    try {
      final Map<String, ClientOrderStatus> previousStatuses =
          <String, ClientOrderStatus>{
            for (final ClientOrderItem item in _orders) item.id: item.status,
          };
      final List<ClientOrderItem> result = await _getClientOrdersUseCase();
      final Set<String> changedOrderIds = result
          .where(
            (ClientOrderItem item) =>
                previousStatuses[item.id] != null &&
                previousStatuses[item.id] != item.status,
          )
          .map((ClientOrderItem item) => item.id)
          .toSet();
      if (!mounted) {
        return;
      }
      setState(() {
        _orders = result;
        _errorMessage = null;
        _isLoading = false;
        _highlightedOrderIds = <String>{
          ..._highlightedOrderIds,
          ...changedOrderIds,
        };
      });
      if (changedOrderIds.isNotEmpty) {
        Future<void>.delayed(const Duration(milliseconds: 720), () {
          if (!mounted) {
            return;
          }
          setState(
            () =>
                _highlightedOrderIds = <String>{..._highlightedOrderIds}
                  ..removeAll(changedOrderIds),
          );
        });
      }
      _tabUiStateService.setOrdersCount(result.length);
      _tabUiStateService.ingestOrders(result);
      if (!showLoader) {
        ClientFeedback.showMessage(context, message: 'Órdenes actualizadas');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = ApiErrorMapper.toUserMessage(
          error,
          fallback: 'No pudimos cargar tus órdenes.',
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClientShellScaffold(
      currentTab: ClientTab.orders,
      title: 'Mis órdenes',
      onRefresh: () => _loadOrders(showLoader: false),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final List<ClientOrderItem> visibleOrders = _visibleOrders;

    if (_isLoading) {
      return const ClientStatusView.loading(
        title: 'Cargando órdenes',
        message: 'Consultando el estado de tus reservas...',
      );
    }

    if (_errorMessage != null) {
      return ClientStatusView.error(
        message: _errorMessage!,
        onRetry: () => _loadOrders(showLoader: true),
      );
    }

    if (_orders.isEmpty) {
      return ClientStatusView.empty(
        title: 'No tienes órdenes todavía',
        message: 'Cuando realices una reserva aparecerá en esta sección.',
        onPrimaryAction: () => context.go(AppRoutes.clientServices),
        primaryActionLabel: 'Explorar servicios',
        onRetry: () => _loadOrders(showLoader: true),
        retryLabel: 'Actualizar',
      );
    }

    return Column(
      children: <Widget>[
        if (_hiddenHistoryOrdersCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _showCancelledOrders
                        ? 'Mostrando historial (incluye canceladas y completadas)'
                        : 'Ocultando $_hiddenHistoryOrdersCount orden(es) del historial',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showCancelledOrders = !_showCancelledOrders;
                    });
                  },
                  child: Text(
                    _showCancelledOrders
                        ? 'Ocultar finalizadas'
                        : 'Ver finalizadas',
                  ),
                ),
              ],
            ),
          ),
        Expanded(
              child: visibleOrders.isEmpty
                  ? ClientStatusView.empty(
                      title: 'No tienes órdenes activas',
                      message:
                          'Tus órdenes del historial (canceladas/completadas) están ocultas para mantener limpia esta sección.',
                      onPrimaryAction: _hiddenHistoryOrdersCount > 0
                          ? () {
                              setState(() => _showCancelledOrders = true);
                            }
                          : () => context.go(AppRoutes.clientServices),
                      primaryActionLabel: _hiddenHistoryOrdersCount > 0
                          ? 'Ver finalizadas'
                          : 'Explorar servicios',
                      onRetry: () => _loadOrders(showLoader: true),
                      retryLabel: 'Actualizar',
                )
              : ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  cacheExtent: 700,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: visibleOrders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final ClientOrderItem order = visibleOrders[index];
                    return StaggeredAppear(
                      index: index,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutBack,
                        scale: _highlightedOrderIds.contains(order.id)
                            ? 1.015
                            : 1,
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long_rounded),
                            title: Text(
                              'Orden #${order.id} - ${order.title}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  OrderStatusChip(status: order.status),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Total: ${_resolvedPayableLabel(order)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.secondaryText,
                            ),
                            onTap: () => _openOrderDetail(order),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<ClientOrderItem> get _visibleOrders {
    if (_showCancelledOrders) {
      return _orders;
    }
    return _orders
        .where(
          (ClientOrderItem item) =>
              item.status != ClientOrderStatus.cancelled &&
              item.status != ClientOrderStatus.completed,
        )
        .toList();
  }

  int get _hiddenHistoryOrdersCount {
    return _orders
        .where(
          (ClientOrderItem item) =>
              item.status == ClientOrderStatus.cancelled ||
              item.status == ClientOrderStatus.completed,
        )
        .length;
  }

  Future<void> _openOrderDetail(ClientOrderItem order) async {
    final _OrderPrimaryAction action = _primaryActionFor(order.status);
    final bool canCancel = order.status.canTransitionTo(
      ClientOrderStatus.cancelled,
    );
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Orden #${order.id}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  order.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Estado',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    OrderStatusChip(status: order.status),
                  ],
                ),
                const SizedBox(height: 4),
                _OrderMetaRow(
                  label: 'Total estimado',
                  value: _resolvedPayableLabel(order),
                ),
                if (order.subtotalCents != null) ...<Widget>[
                  _OrderMetaRow(
                    label: 'Subtotal',
                    value: _formatCurrency(order.subtotalCents!),
                  ),
                ],
                if (order.serviceFeeCents != null) ...<Widget>[
                  _OrderMetaRow(
                    label: 'Cargo de servicio',
                    value: _formatCurrency(order.serviceFeeCents!),
                  ),
                ],
                if (order.taxCents != null) ...<Widget>[
                  _OrderMetaRow(
                    label: 'Impuestos',
                    value: _formatCurrency(order.taxCents!),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Servicios incluidos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildOrderItemsSection(order),
                const SizedBox(height: 16),
                Text(
                  'Timeline',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _OrderTimeline(status: order.status),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: action.enabled
                        ? () => _handlePrimaryAction(order)
                        : null,
                    icon: Icon(action.icon),
                    label: Text(action.label),
                  ),
                ),
                if (canCancel) ...<Widget>[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _confirmCancelOrder(order),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancelar orden'),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handlePrimaryAction(ClientOrderItem order) async {
    Navigator.of(context).pop();
    final ClientOrderItem current = await _refreshOrderSnapshot(order);
    if (!mounted) {
      return;
    }
    switch (current.status) {
      case ClientOrderStatus.pendingProviderApproval:
        ClientFeedback.showMessage(
          context,
          message:
              'Tu solicitud está pendiente de aprobación del proveedor. Te notificaremos en cuanto responda.',
        );
        return;
      case ClientOrderStatus.pendingPayment:
        final bool? paid = await _showPaymentSheet(current);
        if (paid == true) {
          await _transitionOrderStatus(
            order: current,
            target: ClientOrderStatus.confirmed,
            successMessage: 'Pago confirmado. Tu orden ahora está confirmada.',
          );
        }
        return;
      case ClientOrderStatus.confirmed:
        final bool? paid = await _showPaymentSheet(current);
        if (paid == true) {
          await _transitionOrderStatus(
            order: current,
            target: ClientOrderStatus.inProgress,
            successMessage: 'Pago confirmado. Tu orden ahora está en proceso.',
          );
        }
        return;
      case ClientOrderStatus.inProgress:
        await _showProviderContactSheet(current);
        return;
      case ClientOrderStatus.completed:
        await _showRatingSheet(current);
        return;
      case ClientOrderStatus.cancelled:
        ClientFeedback.showMessage(
          context,
          message:
              'Esta orden ya está cancelada (o fue rechazada por el proveedor).',
        );
        return;
    }
  }

  Future<void> _transitionOrderStatus({
    required ClientOrderItem order,
    required ClientOrderStatus target,
    required String successMessage,
  }) async {
    if (!order.status.canTransitionTo(target)) {
      ClientFeedback.showMessage(
        context,
        message: 'La acción no está permitida para el estado actual.',
      );
      return;
    }

    try {
      await _updateClientOrderStatusUseCase(orderId: order.id, status: target);
      if (!mounted) {
        return;
      }
      await _loadOrders(showLoader: false);
      if (!mounted) {
        return;
      }
      ClientFeedback.showMessage(context, message: successMessage);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ClientFeedback.showMessage(
        context,
        message: ApiErrorMapper.toUserMessage(
          error,
          fallback: 'No se pudo actualizar la orden. Verifica tu conexión.',
          codeOverrides: const <String, String>{
            'ORDER_INVALID_TRANSITION':
                'La orden cambió de estado y ya no se puede aplicar esta acción.',
          },
          statusOverrides: const <int, String>{
            409:
                'La orden cambió de estado y ya no se puede aplicar esta acción.',
            500:
                'No se pudo actualizar la orden por un error del servidor. Intenta nuevamente.',
          },
        ),
      );
      await _loadOrders(showLoader: false);
    }
  }

  Future<void> _confirmCancelOrder(ClientOrderItem order) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar orden'),
          content: Text(
            '¿Seguro que deseas cancelar la orden #${order.id}? Esta acción no se puede deshacer.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
    final ClientOrderItem current = await _refreshOrderSnapshot(order);
    if (!mounted) {
      return;
    }
    if (!current.status.canTransitionTo(ClientOrderStatus.cancelled)) {
      ClientFeedback.showMessage(
        context,
        message:
            'La orden ya cambió de estado y no se puede cancelar desde aquí.',
      );
      return;
    }
    await _transitionOrderStatus(
      order: current,
      target: ClientOrderStatus.cancelled,
      successMessage: 'Tu orden fue cancelada correctamente.',
    );
  }

  Future<ClientOrderItem> _refreshOrderSnapshot(
    ClientOrderItem fallback,
  ) async {
    try {
      final List<ClientOrderItem> latest = await _getClientOrdersUseCase();
      if (!mounted) {
        return fallback;
      }
      ClientOrderItem? current;
      for (final ClientOrderItem item in latest) {
        if (item.id == fallback.id) {
          current = item;
          break;
        }
      }
      setState(() {
        _orders = latest;
        _errorMessage = null;
      });
      _tabUiStateService.setOrdersCount(latest.length);
      return current ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  Widget _buildOrderItemsSection(ClientOrderItem order) {
    if (order.items.isEmpty) {
      return _ServiceChip(label: order.title);
    }

    return Column(
      children: order.items.map((ClientOrderLineItem item) {
        final List<String> selectedNames = item.selectedProducts
            .map((ClientOrderSelectedProduct product) => product.name.trim())
            .where((String value) => value.isNotEmpty)
            .toList();
        final int? lineTotal = item.totalItemCents ?? item.unitPriceCents;
        final String serviceName = item.serviceName.trim().isEmpty
            ? order.title
            : item.serviceName;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                serviceName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if ((item.productName ?? '').trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  'Producto: ${item.productName}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (selectedNames.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  'Seleccionados: ${selectedNames.join(', ')}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (lineTotal != null && lineTotal > 0) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  'Total ítem: ${_formatCurrency(lineTotal)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<bool?> _showPaymentSheet(ClientOrderItem order) {
    _PaymentMethodOption selected = _PaymentMethodOption.savedCard;
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Confirmar pago',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Orden #${order.id} • ${_resolvedPayableLabel(order)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PaymentMethodTile(
                      option: _PaymentMethodOption.savedCard,
                      isSelected: selected == _PaymentMethodOption.savedCard,
                      onTap: () => setModalState(
                        () => selected = _PaymentMethodOption.savedCard,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _PaymentMethodTile(
                      option: _PaymentMethodOption.spei,
                      isSelected: selected == _PaymentMethodOption.spei,
                      onTap: () => setModalState(
                        () => selected = _PaymentMethodOption.spei,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(true),
                        icon: const Icon(Icons.lock_rounded),
                        label: const Text('Pagar de forma segura'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showProviderContactSheet(ClientOrderItem order) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Canales de contacto',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.call_outlined),
                  title: Text('Llamada'),
                  subtitle: Text('+52 222 000 0000'),
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.chat_outlined),
                  title: Text('Chat interno'),
                  subtitle: Text('Respuesta estimada: 5-10 min'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRatingSheet(ClientOrderItem order) async {
    int selectedStars = 5;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Calificar servicio',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(order.title),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: List<Widget>.generate(5, (int index) {
                        final int star = index + 1;
                        final bool active = star <= selectedStars;
                        return IconButton.filledTonal(
                          onPressed: () =>
                              setModalState(() => selectedStars = star),
                          icon: Icon(
                            active
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ClientFeedback.showMessage(
                            this.context,
                            message: 'Gracias. Tu calificación fue enviada.',
                          );
                        },
                        child: const Text('Enviar evaluación'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  _OrderPrimaryAction _primaryActionFor(ClientOrderStatus status) {
    switch (status) {
      case ClientOrderStatus.pendingProviderApproval:
        return const _OrderPrimaryAction(
          label: 'Esperando aprobación',
          icon: Icons.pending_actions_rounded,
          enabled: false,
        );
      case ClientOrderStatus.pendingPayment:
        return const _OrderPrimaryAction(
          label: 'Pagar ahora',
          icon: Icons.credit_card_rounded,
          enabled: true,
        );
      case ClientOrderStatus.confirmed:
        return const _OrderPrimaryAction(
          label: 'Pagar ahora',
          icon: Icons.credit_card_rounded,
          enabled: true,
        );
      case ClientOrderStatus.inProgress:
        return const _OrderPrimaryAction(
          label: 'Contactar proveedor',
          icon: Icons.chat_bubble_outline_rounded,
          enabled: true,
        );
      case ClientOrderStatus.completed:
        return const _OrderPrimaryAction(
          label: 'Calificar servicio',
          icon: Icons.star_outline_rounded,
          enabled: true,
        );
      case ClientOrderStatus.cancelled:
        return const _OrderPrimaryAction(
          label: 'Orden cancelada',
          icon: Icons.block_rounded,
          enabled: false,
        );
    }
  }

  String _resolvedPayableLabel(ClientOrderItem order) {
    final int? totalCents = order.totalCents;
    if (totalCents == null || totalCents <= 0) {
      return order.totalLabel;
    }
    return _formatCurrency(totalCents);
  }

  String _formatCurrency(int cents) {
    final int pesos = (cents / 100).round();
    final String raw = pesos.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final int position = raw.length - i;
      buffer.write(raw[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write(',');
      }
    }
    return '\$${buffer.toString()} MXN';
  }
}

class _OrderPrimaryAction {
  const _OrderPrimaryAction({
    required this.label,
    required this.icon,
    required this.enabled,
  });

  final String label;
  final IconData icon;
  final bool enabled;
}

enum _PaymentMethodOption {
  savedCard(
    title: 'Tarjeta guardada',
    subtitle: 'Visa terminación 4242',
    icon: Icons.credit_card_rounded,
  ),
  spei(
    title: 'Transferencia SPEI',
    subtitle: 'Aplicación en menos de 1 hora',
    icon: Icons.account_balance_rounded,
  );

  const _PaymentMethodOption({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _PaymentMethodOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.activeIcon : AppColors.outline,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(option.icon, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(option.title),
                  Text(
                    option.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.activeIcon : AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderMetaRow extends StatelessWidget {
  const _OrderMetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.status});

  final ClientOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final List<_TimelineStep> steps = _buildSteps(status);
    return Column(
      children: steps
          .map((_TimelineStep step) => _TimelineRow(step: step))
          .toList(),
    );
  }

  List<_TimelineStep> _buildSteps(ClientOrderStatus status) {
    if (status == ClientOrderStatus.cancelled) {
      return const <_TimelineStep>[
        _TimelineStep(label: 'Solicitud recibida', isDone: true),
        _TimelineStep(label: 'Orden cancelada', isDone: true),
      ];
    }

    final List<_TimelineStep> base = <_TimelineStep>[
      const _TimelineStep(label: 'Solicitud recibida'),
      const _TimelineStep(label: 'Confirmacion de disponibilidad'),
      const _TimelineStep(label: 'Pago inicial'),
      const _TimelineStep(label: 'Evento completado'),
    ];

    final int completed = status.timelineCompletedSteps;

    return <_TimelineStep>[
      for (int i = 0; i < base.length; i++)
        base[i].copyWith(isDone: i < completed),
    ];
  }
}

class _TimelineStep {
  const _TimelineStep({required this.label, this.isDone = false});

  final String label;
  final bool isDone;

  _TimelineStep copyWith({bool? isDone}) {
    return _TimelineStep(label: label, isDone: isDone ?? this.isDone);
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step});

  final _TimelineStep step;

  @override
  Widget build(BuildContext context) {
    final Color color = step.isDone ? AppColors.activeIcon : AppColors.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(
              color: step.isDone ? color : Colors.transparent,
              border: Border.all(color: color, width: 1.5),
              shape: BoxShape.circle,
            ),
            child: step.isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              step.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: step.isDone
                    ? AppColors.primaryText
                    : AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
