import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_order_item.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:festum/features/client/usecases/get_client_orders_use_case.dart';
import 'package:festum/features/client/widgets/client_feedback.dart';
import 'package:festum/features/client/widgets/client_shell_scaffold.dart';
import 'package:festum/features/client/widgets/client_status_view.dart';
import 'package:flutter/material.dart';

class ClientOrdersView extends StatefulWidget {
  const ClientOrdersView({super.key});

  @override
  State<ClientOrdersView> createState() => _ClientOrdersViewState();
}

class _ClientOrdersViewState extends State<ClientOrdersView> {
  late final GetClientOrdersUseCase _getClientOrdersUseCase;
  late final ClientTabUiStateService _tabUiStateService;
  late final ScrollController _scrollController;

  bool _isLoading = true;
  String? _errorMessage;
  List<ClientOrderItem> _orders = <ClientOrderItem>[];

  @override
  void initState() {
    super.initState();
    _getClientOrdersUseCase = locator<GetClientOrdersUseCase>();
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
      final List<ClientOrderItem> result = await _getClientOrdersUseCase();
      if (!mounted) {
        return;
      }
      setState(() {
        _orders = result;
        _errorMessage = null;
        _isLoading = false;
      });
      _tabUiStateService.setOrdersCount(result.length);
      if (!showLoader) {
        ClientFeedback.showMessage(context, message: 'Órdenes actualizadas');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'No pudimos cargar tus órdenes.';
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
        onRetry: () => _loadOrders(showLoader: true),
        retryLabel: 'Actualizar',
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: _orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final ClientOrderItem order = _orders[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.receipt_long_rounded),
            title: Text('Orden #${order.id} - ${order.title}'),
            subtitle: Text(
              'Estado: ${order.status} • Total: ${order.totalLabel}',
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryText,
            ),
            onTap: () => _openOrderDetail(order),
          ),
        );
      },
    );
  }

  Future<void> _openOrderDetail(ClientOrderItem order) async {
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
                _OrderMetaRow(label: 'Estado', value: order.status),
                _OrderMetaRow(label: 'Total estimado', value: order.totalLabel),
                const SizedBox(height: 16),
                Text(
                  'Servicios incluidos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _ServiceChip(label: order.title),
                _ServiceChip(label: 'Coordinacion y montaje'),
                _ServiceChip(label: 'Soporte en evento'),
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      ClientFeedback.showMessage(
                        this.context,
                        message: 'Factura enviada al correo registrado.',
                      );
                    },
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text('Descargar comprobante'),
                  ),
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
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: Text(label),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final List<_TimelineStep> steps = _buildSteps(status);
    return Column(
      children: steps
          .map((_TimelineStep step) => _TimelineRow(step: step))
          .toList(),
    );
  }

  List<_TimelineStep> _buildSteps(String status) {
    final List<_TimelineStep> base = <_TimelineStep>[
      const _TimelineStep(label: 'Solicitud recibida'),
      const _TimelineStep(label: 'Confirmacion de disponibilidad'),
      const _TimelineStep(label: 'Pago inicial'),
      const _TimelineStep(label: 'Evento completado'),
    ];

    int completed = 1;
    if (status.toLowerCase().contains('confirm')) {
      completed = 2;
    } else if (status.toLowerCase().contains('pago')) {
      completed = 3;
    } else if (status.toLowerCase().contains('complet')) {
      completed = 4;
    }

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
