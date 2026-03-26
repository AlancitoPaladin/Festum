import 'dart:async';

import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:festum/features/client/usecases/get_client_orders_use_case.dart';
import 'package:festum/features/client/widgets/client_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

class ClientShellScaffold extends StatefulWidget {
  const ClientShellScaffold({
    required this.currentTab,
    required this.body,
    this.title,
    this.showAppBar = true,
    this.showBackButton = false,
    this.onBackPressed,
    this.onRefresh,
    super.key,
  });

  final ClientTab currentTab;
  final Widget body;
  final String? title;
  final bool showAppBar;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final RefreshCallback? onRefresh;

  @override
  State<ClientShellScaffold> createState() => _ClientShellScaffoldState();
}

class _ClientShellScaffoldState extends State<ClientShellScaffold> {
  bool _isBottomBarVisible = true;
  late final ClientTabUiStateService _tabUiStateService;
  late final GetClientOrdersUseCase _getClientOrdersUseCase;
  Timer? _ordersPollingTimer;
  bool _isSyncingNotifications = false;

  @override
  void initState() {
    super.initState();
    _tabUiStateService = locator<ClientTabUiStateService>();
    _getClientOrdersUseCase = locator<GetClientOrdersUseCase>();
    _syncOrderNotifications();
    _ordersPollingTimer = Timer.periodic(
      const Duration(seconds: 25),
      (_) => _syncOrderNotifications(),
    );
  }

  @override
  void dispose() {
    _ordersPollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: AppColors.backgroundElevated,
              foregroundColor: AppColors.primaryText,
              surfaceTintColor: Colors.transparent,
              shadowColor: AppColors.primaryText.withValues(alpha: 0.08),
              elevation: 0.6,
              scrolledUnderElevation: 1.2,
              shape: const Border(
                bottom: BorderSide(color: AppColors.outline, width: 0.6),
              ),
              title: Text(widget.title ?? widget.currentTab.label),
              iconTheme: const IconThemeData(color: AppColors.primaryText),
              actionsIconTheme: const IconThemeData(
                color: AppColors.primaryText,
              ),
              leading: widget.showBackButton
                  ? IconButton(
                      tooltip: 'Volver',
                      color: AppColors.primaryText,
                      onPressed: () {
                        final VoidCallback? onBackPressed =
                            widget.onBackPressed;
                        if (onBackPressed != null) {
                          onBackPressed();
                          return;
                        }
                        if (context.canPop()) {
                          context.pop();
                          return;
                        }
                        context.go(AppRoutes.clientServices);
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                    )
                  : null,
              actions: <Widget>[
                AnimatedBuilder(
                  animation: _tabUiStateService,
                  builder: (BuildContext context, Widget? child) {
                    final int notificationCount =
                        _tabUiStateService.orderNotificationsCount;
                    return IconButton(
                      tooltip: 'Notificaciones',
                      color: AppColors.primaryText,
                      onPressed: () {
                        _tabUiStateService.clearOrderNotifications();
                        if (widget.currentTab != ClientTab.orders) {
                          context.go(AppRoutes.clientOrders);
                        }
                      },
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          const Icon(Icons.notifications_outlined),
                          if (notificationCount > 0)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.alert,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  notificationCount > 9
                                      ? '9+'
                                      : '$notificationCount',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Cerrar sesión',
                  color: AppColors.primaryText,
                  onPressed: () async {
                    final bool confirmed = await _confirmSignOut(context);
                    if (!confirmed || !context.mounted) {
                      return;
                    }
                    await locator<AuthStateService>().signOut();
                    if (!context.mounted) {
                      return;
                    }
                    context.go(AppRoutes.login);
                  },
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            )
          : null,
      body: RefreshIndicator.adaptive(
        onRefresh: widget.onRefresh ?? _defaultRefresh,
        child: NotificationListener<UserScrollNotification>(
          onNotification: _onUserScroll,
          child: widget.body,
        ),
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        offset: _isBottomBarVisible ? Offset.zero : const Offset(0, 1.2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isBottomBarVisible ? 1 : 0,
          child: ClientBottomNavBar(
            currentTab: widget.currentTab,
            onTabPressed: _onTabPressed,
          ),
        ),
      ),
    );
  }

  bool _onUserScroll(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse &&
        _isBottomBarVisible) {
      setState(() => _isBottomBarVisible = false);
    } else if (notification.direction != ScrollDirection.reverse &&
        !_isBottomBarVisible) {
      setState(() => _isBottomBarVisible = true);
    }
    return false;
  }

  void _onTabPressed(ClientTab tab) {
    if (tab == widget.currentTab) {
      return;
    }
    context.go(tab.route);
  }

  Future<void> _syncOrderNotifications() async {
    if (_isSyncingNotifications) {
      return;
    }
    _isSyncingNotifications = true;
    try {
      final orders = await _getClientOrdersUseCase();
      _tabUiStateService.ingestOrders(orders);
    } catch (_) {
      // Best-effort sync: UI should continue even if orders are unavailable.
    } finally {
      _isSyncingNotifications = false;
    }
  }

  Future<bool> _confirmSignOut(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _defaultRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}
