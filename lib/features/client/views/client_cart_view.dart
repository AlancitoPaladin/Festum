import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_cart_item.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:festum/features/client/usecases/get_client_cart_items_use_case.dart';
import 'package:festum/features/client/usecases/remove_client_cart_item_use_case.dart';
import 'package:festum/features/client/usecases/restore_client_cart_item_use_case.dart';
import 'package:festum/features/client/widgets/client_feedback.dart';
import 'package:festum/features/client/widgets/client_shell_scaffold.dart';
import 'package:festum/features/client/widgets/client_status_view.dart';
import 'package:flutter/material.dart';

class ClientCartView extends StatefulWidget {
  const ClientCartView({super.key});

  @override
  State<ClientCartView> createState() => _ClientCartViewState();
}

class _ClientCartViewState extends State<ClientCartView> {
  late final GetClientCartItemsUseCase _getClientCartItemsUseCase;
  late final RemoveClientCartItemUseCase _removeClientCartItemUseCase;
  late final RestoreClientCartItemUseCase _restoreClientCartItemUseCase;
  late final ClientTabUiStateService _tabUiStateService;
  late final ScrollController _scrollController;

  bool _isLoading = true;
  String? _errorMessage;
  List<ClientCartItem> _cartItems = <ClientCartItem>[];

  @override
  void initState() {
    super.initState();
    _getClientCartItemsUseCase = locator<GetClientCartItemsUseCase>();
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
    _tabUiStateService.saveScrollOffset(ClientTab.cart, _scrollController.offset);
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
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'No pudimos cargar tu carrito.';
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
      return;
    }

    setState(
      () => _cartItems.removeWhere((ClientCartItem it) => it.id == item.id),
    );
    _tabUiStateService.setCartCount(_cartItems.length);

    ClientFeedback.showMessage(
      context,
      message: 'Se eliminó "${item.name}" del carrito',
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
                  'Confirmar orden',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Revisa el resumen antes de continuar con el pago.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      ClientFeedback.showMessage(
                        this.context,
                        message: 'Orden confirmada. Pasaremos a pago.',
                      );
                    },
                    child: const Text('Confirmar y continuar'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Seguir editando'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _CartTotals _calculateTotals() {
    final int subtotal = _cartItems.fold<int>(
      0,
      (int sum, ClientCartItem item) => sum + item.unitPriceCents * item.quantity,
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
        title: 'Tu carrito está vacio',
        message: 'Agrega servicios para continuar con tu orden.',
        icon: Icons.shopping_cart_outlined,
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: _cartItems.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        if (index == _cartItems.length) {
          return Card(
            color: AppColors.cardAccent,
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
          );
        }

        final ClientCartItem item = _cartItems[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.shopping_bag_rounded),
            title: Text(item.name),
            subtitle: Text('Cantidad: 1 • ${_formatCurrency(item.unitPriceCents)}'),
            trailing: IconButton(
              tooltip: 'Eliminar',
              onPressed: () => _removeItem(index),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.alert,
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
