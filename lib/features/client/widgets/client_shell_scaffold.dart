import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_tab.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(widget.title ?? widget.currentTab.label),
              leading: widget.showBackButton
                  ? IconButton(
                      tooltip: 'Volver',
                      color: AppColors.appBarText,
                      onPressed: () {
                        final VoidCallback? onBackPressed = widget.onBackPressed;
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
                IconButton(
                  tooltip: 'Cerrar sesión',
                  color: AppColors.appBarText,
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

  Future<bool> _confirmSignOut(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text(
            '¿Estás seguro de que quieres cerrar sesión?',
          ),
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
