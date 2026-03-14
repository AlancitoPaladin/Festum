import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:flutter/material.dart';

class ClientBottomNavBar extends StatelessWidget {
  const ClientBottomNavBar({
    required this.currentTab,
    required this.onTabPressed,
    super.key,
  });

  final ClientTab currentTab;
  final ValueChanged<ClientTab> onTabPressed;

  @override
  Widget build(BuildContext context) {
    final ClientTabUiStateService tabUiStateService =
        locator<ClientTabUiStateService>();
    final ThemeData theme = Theme.of(context);

    return AnimatedBuilder(
      animation: tabUiStateService,
      builder: (BuildContext context, Widget? child) {
        return SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.35),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.appBar.withValues(alpha: 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: ClientTab.values
                    .map(
                      (ClientTab tab) => Expanded(
                        child: _BottomTabButton(
                          tab: tab,
                          selected: tab == currentTab,
                          badgeCount: tabUiStateService.badgeFor(tab),
                          onTap: () => onTabPressed(tab),
                          theme: theme,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomTabButton extends StatelessWidget {
  const _BottomTabButton({
    required this.tab,
    required this.selected,
    required this.badgeCount,
    required this.onTap,
    required this.theme,
  });

  final ClientTab tab;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected
                ? AppColors.primaryButton.withValues(alpha: 0.32)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Icon(
                    selected ? tab.activeIcon : tab.icon,
                    size: 22,
                    color: selected
                        ? AppColors.activeIcon
                        : AppColors.secondaryText,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: -10,
                      top: -6,
                      child: _TabBadge(count: badgeCount),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.primaryText
                      : AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBadge extends StatelessWidget {
  const _TabBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final String label = count > 9 ? '9+' : '$count';

    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.alert,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
