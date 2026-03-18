import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/provider/models/provider_tab.dart';
import 'package:flutter/material.dart';

class ProviderBottomNavBar extends StatelessWidget {
  const ProviderBottomNavBar({
    required this.currentTab,
    required this.onTabPressed,
    super.key,
  });

  final ProviderTab currentTab;
  final ValueChanged<ProviderTab> onTabPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outline.withOpacity(0.35)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.appBar.withOpacity(0.14),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: ProviderTab.values
                .map(
                  (ProviderTab tab) => Expanded(
                    child: _BottomTabButton(
                      tab: tab,
                      selected: tab == currentTab,
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
  }
}

class _BottomTabButton extends StatelessWidget {
  const _BottomTabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final ProviderTab tab;
  final bool selected;
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
                ? AppColors.primaryButton.withOpacity(0.32)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                selected ? tab.activeIcon : tab.icon,
                size: 22,
                color: selected
                    ? AppColors.activeIcon
                    : AppColors.secondaryText,
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
