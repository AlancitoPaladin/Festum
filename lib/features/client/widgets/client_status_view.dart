import 'package:festum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ClientStatusView extends StatelessWidget {
  const ClientStatusView.loading({
    this.title = 'Cargando',
    this.message = 'Espera un momento...',
    super.key,
  }) : icon = Icons.hourglass_top_rounded,
       onRetry = null,
       retryLabel = null;

  const ClientStatusView.empty({
    required this.title,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  const ClientStatusView.error({
    this.title = 'No pudimos cargar esta sección',
    this.message = 'Revisa tu conexión e inténtalo de nuevo.',
    this.icon = Icons.wifi_off_rounded,
    this.onRetry,
    this.retryLabel = 'Reintentar',
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (onRetry == null && icon == Icons.hourglass_top_rounded)
                const CircularProgressIndicator.adaptive()
              else
                Icon(icon, size: 40, color: AppColors.secondaryText),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (onRetry != null) ...<Widget>[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(retryLabel ?? 'Reintentar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
