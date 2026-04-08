import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_order_item.dart';
import 'package:flutter/material.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({required this.status, this.maxWidth, super.key});

  final ClientOrderStatus status;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final _StatusPalette palette = _StatusPalette.fromStatus(status);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: Container(
          key: ValueKey<ClientOrderStatus>(status),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: palette.background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(palette.icon, size: 14, color: palette.foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  status.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPalette {
  const _StatusPalette({
    required this.background,
    required this.border,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final IconData icon;

  factory _StatusPalette.fromStatus(ClientOrderStatus status) {
    switch (status) {
      case ClientOrderStatus.pendingProviderApproval:
        return _StatusPalette(
          background: AppColors.secondaryButton.withValues(alpha: 0.2),
          border: AppColors.secondaryText.withValues(alpha: 0.42),
          foreground: AppColors.primaryText,
          icon: Icons.pending_actions_rounded,
        );
      case ClientOrderStatus.pendingPayment:
        return _StatusPalette(
          background: AppColors.primaryButton.withValues(alpha: 0.18),
          border: AppColors.primaryButton.withValues(alpha: 0.45),
          foreground: AppColors.primaryText,
          icon: Icons.payments_outlined,
        );
      case ClientOrderStatus.confirmed:
        return _StatusPalette(
          background: AppColors.secondaryButton.withValues(alpha: 0.22),
          border: AppColors.outline.withValues(alpha: 0.5),
          foreground: AppColors.activeIcon,
          icon: Icons.verified_outlined,
        );
      case ClientOrderStatus.inProgress:
        return _StatusPalette(
          background: AppColors.activeIcon.withValues(alpha: 0.12),
          border: AppColors.activeIcon.withValues(alpha: 0.35),
          foreground: AppColors.activeIcon,
          icon: Icons.autorenew_rounded,
        );
      case ClientOrderStatus.completed:
        return _StatusPalette(
          background: AppColors.secondaryButton.withValues(alpha: 0.14),
          border: AppColors.outline.withValues(alpha: 0.42),
          foreground: AppColors.primaryText,
          icon: Icons.check_circle_outline_rounded,
        );
      case ClientOrderStatus.cancelled:
        return _StatusPalette(
          background: AppColors.alert.withValues(alpha: 0.12),
          border: AppColors.alert.withValues(alpha: 0.35),
          foreground: AppColors.alert,
          icon: Icons.block_rounded,
        );
    }
  }
}
