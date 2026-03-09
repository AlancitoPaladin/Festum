import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/auth_state_service.dart';
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
    super.key,
  });

  final ClientTab currentTab;
  final Widget body;
  final String? title;
  final bool showAppBar;

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
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    await locator<AuthStateService>().signOut();
                    if (!context.mounted) {
                      return;
                    }
                    context.go(AppRoutes.login);
                  },
                  child: const Text('Salir'),
                ),
              ],
            )
          : null,
      body: NotificationListener<UserScrollNotification>(
        onNotification: _onUserScroll,
        child: widget.body,
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
}
