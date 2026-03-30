import 'dart:ui';

import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/network/api_error_mapper.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_cart_item.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:festum/features/client/usecases/checkout_cart_use_case.dart';
import 'package:festum/features/client/usecases/get_client_cart_items_use_case.dart';
import 'package:festum/features/client/usecases/remove_client_cart_item_use_case.dart';
import 'package:festum/features/client/usecases/restore_client_cart_item_use_case.dart';
import 'package:festum/features/client/widgets/client_feedback.dart';
import 'package:festum/features/client/widgets/client_shell_scaffold.dart';
import 'package:festum/features/client/widgets/client_status_view.dart';
import 'package:festum/features/client/widgets/staggered_appear.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ClientCartView extends StatefulWidget {
  const ClientCartView({super.key});

  @override
  State<ClientCartView> createState() => _ClientCartViewState();
}

class _ClientCartViewState extends State<ClientCartView> {
  late final GetClientCartItemsUseCase _getClientCartItemsUseCase;
  late final CheckoutCartUseCase _checkoutCartUseCase;
  late final RemoveClientCartItemUseCase _removeClientCartItemUseCase;
  late final RestoreClientCartItemUseCase _restoreClientCartItemUseCase;
  late final ClientTabUiStateService _tabUiStateService;
  late final ScrollController _scrollController;

  bool _isLoading = true;
  bool _isCheckingOut = false;
  String? _errorMessage;
  List<ClientCartItem> _cartItems = <ClientCartItem>[];
  DateTime? _requestedEventDate;
  String _requestNotes = '';

  @override
  void initState() {
    super.initState();
    _getClientCartItemsUseCase = locator<GetClientCartItemsUseCase>();
    _checkoutCartUseCase = locator<CheckoutCartUseCase>();
    _removeClientCartItemUseCase = locator<RemoveClientCartItemUseCase>();
    _restoreClientCartItemUseCase = locator<RestoreClientCartItemUseCase>();
    _tabUiStateService = locator<ClientTabUiStateService>();
    _scrollController = ScrollController(
      initialScrollOffset: _tabUiStateService.scrollOffsetFor(ClientTab.cart),
    )..addListener(_onScroll);

    _loadCart(showLoader: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _tabUiStateService.saveScrollOffset(
      ClientTab.cart,
      _scrollController.offset,
    );
  }

  Future<void> _loadCart({required bool showLoader}) async {
    if (showLoader) {
      setState(() => _isLoading = true);
    }

    try {
      final List<ClientCartItem> result = await _getClientCartItemsUseCase();
      if (!mounted) {
        return;
      }
      setState(() {
        _cartItems = result;
        _errorMessage = null;
        _isLoading = false;
      });
      _tabUiStateService.setCartCount(result.length);
      if (!showLoader) {
        ClientFeedback.showMessage(context, message: 'Carrito actualizado');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = ApiErrorMapper.toUserMessage(
          error,
          fallback: 'No pudimos cargar tu carrito.',
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _removeItem(int index) async {
    final ClientCartItem item = _cartItems[index];
    final bool confirmed = await ClientFeedback.confirmDelete(
      context,
      itemLabel: item.name,
    );
    if (!confirmed || !mounted) {
      return;
    }

    final ClientCartItem? removed = await _removeClientCartItemUseCase(item.id);
    if (!mounted) {
      return;
    }
    if (removed == null) {
      ClientFeedback.showMessage(
        context,
        message: 'No se pudo eliminar el elemento. Intenta nuevamente.',
      );
      HapticFeedback.selectionClick();
      return;
    }

    setState(
      () => _cartItems.removeWhere((ClientCartItem it) => it.id == item.id),
    );
    _tabUiStateService.setCartCount(_cartItems.length);

    ClientFeedback.showMessage(
      context,
      message: 'Se elimino "${item.name}" del carrito',
      actionLabel: 'Deshacer',
      onAction: () async {
        await _restoreClientCartItemUseCase(item: removed, index: index);
        if (!mounted) {
          return;
        }
        setState(() {
          final int safeIndex = index.clamp(0, _cartItems.length);
          _cartItems.insert(safeIndex, removed);
        });
        _tabUiStateService.setCartCount(_cartItems.length);
      },
    );
    HapticFeedback.lightImpact();
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

  Future<void> _showCheckoutSheet(_CartTotals totals) async {
    if (_cartItems.isEmpty) {
      return;
    }

    DateTime selectedDate =
        _requestedEventDate ?? DateTime.now().add(const Duration(days: 7));
    String notesValue = _requestNotes;

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
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Confirmar orden',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Revisa el resumen antes de continuar con el pago.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Fecha del evento',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setModalState) {
                      return OutlinedButton.icon(
                        onPressed: _isCheckingOut
                            ? null
                            : () async {
                                final DateTime now = DateTime.now();
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate.isBefore(now)
                                      ? now
                                      : selectedDate,
                                  firstDate: DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                  ),
                                  lastDate: now.add(
                                    const Duration(days: 365 * 2),
                                  ),
                                );
                                if (picked == null) {
                                  return;
                                }
                                setModalState(() => selectedDate = picked);
                              },
                        icon: const Icon(Icons.event_rounded),
                        label: Text(_formatDate(selectedDate)),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: notesValue,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    onChanged: (String value) => notesValue = value,
                    decoration: const InputDecoration(
                      labelText: 'Notas para el proveedor (opcional)',
                      hintText: 'Ej. Horario preferido, tipo de evento...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Elementos',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  ..._cartItems.map((ClientCartItem item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CheckoutItemRow(
                        title: item.resolvedServiceName,
                        subtitle: item.resolvedProductName,
                        amount: _formatCurrency(item.unitPriceCents),
                      ),
                    );
                  }),
                  const Divider(height: 20),
                  _SummaryRow(
                    label: 'Subtotal',
                    value: _formatCurrency(totals.subtotal),
                  ),
                  _SummaryRow(
                    label: 'Cargo de servicio (5%)',
                    value: _formatCurrency(totals.serviceFee),
                  ),
                  _SummaryRow(
                    label: 'Impuestos (16%)',
                    value: _formatCurrency(totals.tax),
                  ),
                  const Divider(height: 20),
                  _SummaryRow(
                    label: 'Total estimado',
                    value: _formatCurrency(totals.total),
                    emphasis: true,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCheckingOut
                          ? null
                          : () async {
                              _requestedEventDate = selectedDate;
                              _requestNotes = notesValue.trim();
                              Navigator.of(context).pop();
                              await _confirmCheckout(
                                eventDate: selectedDate,
                                notes: _requestNotes,
                              );
                            },
                      child: _isCheckingOut
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Confirmar y continuar'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isCheckingOut
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Seguir editando'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmCheckout({
    required DateTime eventDate,
    String? notes,
  }) async {
    if (_isCheckingOut) {
      return;
    }

    setState(() => _isCheckingOut = true);
    try {
      final createdOrder = await _checkoutCartUseCase(
        eventDate: eventDate,
        notes: notes,
      );

      if (!mounted) {
        return;
      }

      if (createdOrder == null) {
        ClientFeedback.showMessage(
          context,
          message:
              'El carrito está vacío. Agrega servicios antes de continuar.',
        );
        HapticFeedback.selectionClick();
        return;
      }

      await _loadCart(showLoader: false);
      if (!mounted) {
        return;
      }
      _tabUiStateService.setOrdersCount(
        _tabUiStateService.badgeFor(ClientTab.orders) + 1,
      );
      ClientFeedback.showMessage(
        context,
        message: 'Orden #${createdOrder.id} creada correctamente.',
      );
      HapticFeedback.mediumImpact();
      if (!mounted) {
        return;
      }
      context.go(
        AppRoutes.clientCheckoutSuccessRoute(
          orderId: createdOrder.id,
          title: createdOrder.title,
          totalLabel: createdOrder.totalLabel,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ClientFeedback.showMessage(
        context,
        message: ApiErrorMapper.toUserMessage(
          error,
          fallback: 'No se pudo completar la orden. Intenta nuevamente.',
        ),
      );
      HapticFeedback.selectionClick();
    } finally {
      if (mounted) {
        setState(() => _isCheckingOut = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  _CartTotals _calculateTotals() {
    final int subtotal = _cartItems.fold<int>(
      0,
      (int sum, ClientCartItem item) =>
          sum + item.unitPriceCents * item.quantity,
    );
    final int serviceFee = (subtotal * 0.05).round();
    final int tax = ((subtotal + serviceFee) * 0.16).round();
    final int total = subtotal + serviceFee + tax;
    return _CartTotals(
      subtotal: subtotal,
      serviceFee: serviceFee,
      tax: tax,
      total: total,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClientShellScaffold(
      currentTab: ClientTab.cart,
      title: 'Carrito de órdenes',
      onRefresh: () => _loadCart(showLoader: false),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ClientStatusView.loading(
        title: 'Cargando carrito',
        message: 'Sincronizando productos y disponibilidad...',
      );
    }

    if (_errorMessage != null) {
      return ClientStatusView.error(
        message: _errorMessage!,
        onRetry: () => _loadCart(showLoader: true),
      );
    }

    if (_cartItems.isEmpty) {
      return ClientStatusView.empty(
        title: 'Tu carrito está vacío',
        message: 'Agrega servicios para continuar con tu orden.',
        icon: Icons.shopping_cart_outlined,
        onPrimaryAction: () => context.go(AppRoutes.clientServices),
        primaryActionLabel: 'Ver servicios',
        onRetry: () => _loadCart(showLoader: true),
        retryLabel: 'Actualizar',
      );
    }

    final _CartTotals totals = _calculateTotals();

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      cacheExtent: 700,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: _cartItems.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        if (index == _cartItems.length) {
          return StaggeredAppear(
            index: index,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardAccent.withValues(alpha: 0.84),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.outline.withValues(alpha: 0.28),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.primaryText.withValues(alpha: 0.1),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Resumen de pago',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        _SummaryRow(
                          label: 'Subtotal',
                          value: _formatCurrency(totals.subtotal),
                        ),
                        _SummaryRow(
                          label: 'Cargo de servicio (5%)',
                          value: _formatCurrency(totals.serviceFee),
                        ),
                        _SummaryRow(
                          label: 'Impuestos (16%)',
                          value: _formatCurrency(totals.tax),
                        ),
                        const Divider(height: 20),
                        _SummaryRow(
                          label: 'Total estimado',
                          value: _formatCurrency(totals.total),
                          emphasis: true,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showCheckoutSheet(totals),
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('Continuar con la orden'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final ClientCartItem item = _cartItems[index];
        return StaggeredAppear(
          index: index,
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.shopping_bag_rounded),
              title: Text(item.resolvedServiceName),
              subtitle: Text(
                item.resolvedProductName == null
                    ? 'Cantidad: 1 • ${_formatCurrency(item.unitPriceCents)}'
                    : '${item.resolvedProductName} • ${_formatCurrency(item.unitPriceCents)}',
              ),
              trailing: IconButton(
                tooltip: 'Eliminar',
                onPressed: () => _removeItem(index),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.alert,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CartTotals {
  const _CartTotals({
    required this.subtotal,
    required this.serviceFee,
    required this.tax,
    required this.total,
  });

  final int subtotal;
  final int serviceFee;
  final int tax;
  final int total;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final TextStyle? base = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: emphasis
                  ? base?.copyWith(fontWeight: FontWeight.w700)
                  : base,
            ),
          ),
          Text(
            value,
            style: emphasis
                ? base?.copyWith(fontWeight: FontWeight.w800)
                : base,
          ),
        ],
      ),
    );
  }
}

class _CheckoutItemRow extends StatelessWidget {
  const _CheckoutItemRow({
    required this.title,
    required this.amount,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty)
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          amount,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
