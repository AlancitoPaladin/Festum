import 'dart:async';

import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_order_item.dart';
import 'package:festum/features/client/widgets/order_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientCheckoutSuccessView extends StatefulWidget {
  const ClientCheckoutSuccessView({
    required this.orderId,
    required this.title,
    required this.totalLabel,
    super.key,
  });

  final String orderId;
  final String title;
  final String totalLabel;

  @override
  State<ClientCheckoutSuccessView> createState() =>
      _ClientCheckoutSuccessViewState();
}

class _ClientCheckoutSuccessViewState extends State<ClientCheckoutSuccessView> {
  Timer? _redirectTimer;
  bool _animateIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _animateIn = true);
    });
    _redirectTimer = Timer(const Duration(seconds: 3), _goToOrders);
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  void _goToOrders() {
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.clientOrders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOut,
                opacity: _animateIn ? 1 : 0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutBack,
                  scale: _animateIn ? 1 : 0.96,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          AnimatedScale(
                            duration: const Duration(milliseconds: 420),
                            curve: Curves.easeOutBack,
                            scale: _animateIn ? 1 : 0.8,
                            child: Container(
                              height: 76,
                              width: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.secondaryButton.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                size: 48,
                                color: AppColors.activeIcon,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Orden creada con éxito',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tu orden fue registrada y ya está lista para seguimiento.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 18),
                          _MetaRow(label: 'ID de orden', value: widget.orderId),
                          _MetaRow(
                            label: 'Estado',
                            valueWidget: const OrderStatusChip(
                              status: ClientOrderStatus.pendingProviderApproval,
                            ),
                          ),
                          _MetaRow(label: 'Servicio', value: widget.title),
                          _MetaRow(label: 'Total', value: widget.totalLabel),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _goToOrders,
                              icon: const Icon(Icons.receipt_long_rounded),
                              label: const Text('Ir a mis órdenes'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () =>
                                  context.go(AppRoutes.clientServices),
                              child: const Text('Volver a servicios'),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Redirigiendo automáticamente en unos segundos...',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, this.value, this.valueWidget})
    : assert(value != null || valueWidget != null);

  final String label;
  final String? value;
  final Widget? valueWidget;

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
            child:
                valueWidget ??
                Text(
                  value!,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
          ),
        ],
      ),
    );
  }
}
