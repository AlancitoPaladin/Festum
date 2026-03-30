import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_in_app_notification.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ClientNotificationsView extends StatefulWidget {
  const ClientNotificationsView({super.key});

  @override
  State<ClientNotificationsView> createState() =>
      _ClientNotificationsViewState();
}

class _ClientNotificationsViewState extends State<ClientNotificationsView> {
  late final ClientTabUiStateService _uiStateService;
  _NotificationFilter _filter = _NotificationFilter.unread;

  @override
  void initState() {
    super.initState();
    _uiStateService = locator<ClientTabUiStateService>();
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _uiStateService,
      builder: (BuildContext context, Widget? child) {
        final List<ClientInAppNotification> notifications =
            _uiStateService.notifications;
        final List<ClientInAppNotification> filtered =
            _filter == _NotificationFilter.unread
            ? notifications
                  .where((ClientInAppNotification item) => !item.isRead)
                  .toList()
            : notifications;
        final Map<String, List<ClientInAppNotification>> grouped =
            _groupNotifications(filtered);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notificaciones'),
            actions: <Widget>[
              TextButton(
                onPressed: notifications.isEmpty
                    ? null
                    : _uiStateService.markAllNotificationsAsRead,
                child: const Text('Marcar todas'),
              ),
            ],
          ),
          body: RefreshIndicator.adaptive(
            onRefresh: _refresh,
            child: filtered.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      const SizedBox(height: 18),
                      _FilterSegment(),
                      SizedBox(height: 120),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _filter == _NotificationFilter.unread
                                ? 'No tienes notificaciones sin leer.'
                                : 'No tienes notificaciones por ahora.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: <Widget>[
                      _FilterSegment(
                        selected: _filter,
                        onChanged: (_NotificationFilter value) {
                          setState(() => _filter = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      for (final MapEntry<String, List<ClientInAppNotification>>
                          entry
                          in grouped.entries) ...<Widget>[
                        _SectionHeader(title: entry.key),
                        const SizedBox(height: 8),
                        for (int index = 0; index < entry.value.length; index++)
                          Builder(
                            builder: (BuildContext context) {
                              final ClientInAppNotification item =
                                  entry.value[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == entry.value.length - 1
                                      ? 12
                                      : 10,
                                ),
                                child: Dismissible(
                                  key: ValueKey<String>(item.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 18),
                                    decoration: BoxDecoration(
                                      color: AppColors.alert.withValues(
                                        alpha: 0.92,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (_) {
                                    final int previousIndex = _uiStateService
                                        .notifications
                                        .indexWhere(
                                          (
                                            ClientInAppNotification
                                            notification,
                                          ) => notification.id == item.id,
                                        );
                                    final ClientInAppNotification? removed =
                                        _uiStateService.removeNotification(
                                          item.id,
                                        );
                                    HapticFeedback.lightImpact();
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Notificación eliminada',
                                        ),
                                        duration: const Duration(
                                          milliseconds: 1800,
                                        ),
                                        action: removed == null
                                            ? null
                                            : SnackBarAction(
                                                label: 'Deshacer',
                                                onPressed: () {
                                                  _uiStateService
                                                      .restoreNotification(
                                                        removed,
                                                        index: previousIndex < 0
                                                            ? 0
                                                            : previousIndex,
                                                      );
                                                },
                                              ),
                                      ),
                                    );
                                  },
                                  child: _NotificationCard(
                                    item: item,
                                    onTap: () {
                                      _uiStateService.markNotificationAsRead(
                                        item.id,
                                      );
                                      context.go(AppRoutes.clientOrders);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }
}

Map<String, List<ClientInAppNotification>> _groupNotifications(
  List<ClientInAppNotification> items,
) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime yesterday = today.subtract(const Duration(days: 1));

  final Map<String, List<ClientInAppNotification>> grouped =
      <String, List<ClientInAppNotification>>{
        'Hoy': <ClientInAppNotification>[],
        'Ayer': <ClientInAppNotification>[],
        'Anteriores': <ClientInAppNotification>[],
      };

  for (final ClientInAppNotification item in items) {
    final DateTime created = item.createdAt;
    final DateTime dateOnly = DateTime(
      created.year,
      created.month,
      created.day,
    );
    if (dateOnly == today) {
      grouped['Hoy']!.add(item);
      continue;
    }
    if (dateOnly == yesterday) {
      grouped['Ayer']!.add(item);
      continue;
    }
    grouped['Anteriores']!.add(item);
  }

  grouped.removeWhere((String _, List<ClientInAppNotification> value) {
    return value.isEmpty;
  });
  return grouped;
}

enum _NotificationFilter { unread, all }

class _FilterSegment extends StatelessWidget {
  const _FilterSegment({
    this.selected = _NotificationFilter.unread,
    this.onChanged,
  });

  final _NotificationFilter selected;
  final ValueChanged<_NotificationFilter>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_NotificationFilter>(
      showSelectedIcon: false,
      segments: const <ButtonSegment<_NotificationFilter>>[
        ButtonSegment<_NotificationFilter>(
          value: _NotificationFilter.unread,
          label: Text('No leídas'),
          icon: Icon(Icons.markunread_rounded),
        ),
        ButtonSegment<_NotificationFilter>(
          value: _NotificationFilter.all,
          label: Text('Todas'),
          icon: Icon(Icons.notifications_rounded),
        ),
      ],
      selected: <_NotificationFilter>{selected},
      onSelectionChanged: onChanged == null
          ? null
          : (Set<_NotificationFilter> values) {
              if (values.isEmpty) {
                return;
              }
              onChanged!(values.first);
            },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final ClientInAppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.isRead
                  ? AppColors.outline.withValues(alpha: 0.24)
                  : AppColors.activeIcon.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                item.isRead
                    ? Icons.notifications_none_rounded
                    : Icons.notifications_active_rounded,
                color: item.isRead
                    ? AppColors.secondaryText
                    : AppColors.activeIcon,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: item.isRead
                            ? FontWeight.w600
                            : FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(item.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _timeAgo(DateTime date) {
  final Duration diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) {
    return 'Ahora';
  }
  if (diff.inMinutes < 60) {
    return 'Hace ${diff.inMinutes} min';
  }
  if (diff.inHours < 24) {
    return 'Hace ${diff.inHours} h';
  }
  return 'Hace ${diff.inDays} d';
}
