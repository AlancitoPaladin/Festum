import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/core/network/api_url_resolver.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/app_remote_image.dart';
import 'package:festum/features/provider/models/provider_home_response.dart';
import 'package:festum/features/provider/models/provider_notification.dart';
import 'package:festum/features/provider/models/provider_tab.dart';
import 'package:festum/features/provider/usecases/clear_provider_notifications_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_home_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_notifications_use_case.dart';
import 'package:festum/features/provider/usecases/mark_all_provider_notifications_as_read_use_case.dart';
import 'package:festum/features/provider/usecases/mark_provider_notification_as_read_use_case.dart';
import 'package:festum/features/provider/viewmodels/provider_home_viewmodel.dart';
import 'package:festum/features/provider/views/my_services_view.dart';
import 'package:festum/features/provider/views/provider_profile_view.dart';
import 'package:festum/features/provider/views/reservations_view.dart';
import 'package:festum/features/provider/widgets/provider_bottom_nav_bar.dart';
import 'package:festum/features/provider/widgets/provider_home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ProviderHomeView extends StatefulWidget {
  final ProviderTab initialTab;

  const ProviderHomeView({super.key, this.initialTab = ProviderTab.home});

  @override
  State<ProviderHomeView> createState() => _ProviderHomeViewState();
}

class _ProviderHomeViewState extends State<ProviderHomeView> {
  late ProviderTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentTab.index,
        children: const [
          _HomeTabBody(),
          ReservationsView(),
          MyServicesView(showAppBar: true),
          ProviderProfileView(),
        ],
      ),
      bottomNavigationBar: ProviderBottomNavBar(
        currentTab: _currentTab,
        onTabPressed: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }
}

class _HomeTabBody extends StatelessWidget {
  const _HomeTabBody();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProviderHomeViewModel>.reactive(
      viewModelBuilder: () => ProviderHomeViewModel(
        locator<GetProviderHomeUseCase>(),
        locator<GetProviderNotificationsUseCase>(),
        locator<MarkProviderNotificationAsReadUseCase>(),
        locator<MarkAllProviderNotificationsAsReadUseCase>(),
        locator<ClearProviderNotificationsUseCase>(),
        locator<ProviderReactivityService>(),
      ),
      onViewModelReady: (ProviderHomeViewModel model) => model.initialize(),
      builder: (context, model, child) {
        if (model.isBusy && !model.hasContent) {
          return const Center(child: CircularProgressIndicator());
        }

        if (model.errorMessage != null && !model.hasContent) {
          return _HomeErrorState(
            message: model.errorMessage!,
            onRetry: model.refresh,
          );
        }

        final ProviderHomeResponse? home = model.home;
        final List<ProviderFeaturedService> featuredServices =
            home?.featuredServices ?? const <ProviderFeaturedService>[];
        final String businessName = home?.businessName.trim().isNotEmpty == true
            ? home!.businessName.trim()
            : '';
        final String displayName = home?.displayName.trim().isNotEmpty == true
            ? home!.displayName.trim()
            : 'Proveedor';
        final String headerName = businessName.isNotEmpty
            ? businessName
            : displayName;
        final String subtitle = businessName.isNotEmpty
            ? displayName
            : 'Administra tu negocio';

        return RefreshIndicator(
          onRefresh: model.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, $headerName',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _NotificationsButton(
                          unreadCount: model.unreadCount,
                          onTap: () => _showNotificationsSheet(context, model),
                        ),
                        const SizedBox(width: 16),
                        _ProviderAvatar(imageUrl: home?.avatarUrl ?? ''),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Estadisticas rapidas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Reservas',
                        value: '${home?.quickStats.reservationsThisMonth ?? 0}',
                        subtitle: 'este mes',
                        icon: Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Servicios activos',
                        value: '${home?.quickStats.activeServices ?? 0}',
                        subtitle: 'activos',
                        icon: Icons.room_service_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Mis servicios destacados',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (featuredServices.isEmpty)
                  const _EmptyFeaturedServicesState(),
                ...featuredServices.map(
                  (ProviderFeaturedService service) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ServiceItemCard(
                      title: service.title,
                      category: service.category,
                      status: service.status,
                      info: service.priceLabel,
                      reservations: service.reservations,
                      imageUrl: service.imageUrl,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationsSheet(
    BuildContext context,
    ProviderHomeViewModel model,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return ListenableBuilder(
          listenable: model,
          builder: (context, child) => SafeArea(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetContext).size.height * 0.72,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 52,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notificaciones',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                model.unreadCount == 0
                                    ? 'Ya revisaste todas tus notificaciones.'
                                    : 'Tienes ${model.unreadCount} notificaciones sin leer.',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (model.notifications.isNotEmpty)
                          TextButton(
                            onPressed: () => model.clearAll(),
                            child: const Text('Borrar todo'),
                          ),
                        if (model.unreadCount > 0)
                          TextButton(
                            onPressed: () => model.markAllAsRead(),
                            child: const Text('Marcar todo'),
                          ),
                        TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: model.notifications.isEmpty
                        ? const _EmptyNotificationsState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            itemCount: model.notifications.length,
                            separatorBuilder: (_, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final ProviderNotification item =
                                  model.notifications[index];
                              return _NotificationCard(
                                item: item,
                                onTap: () => model.markAsRead(item.id),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProviderAvatar extends StatelessWidget {
  const _ProviderAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final String resolvedImageUrl = resolveApiAssetUrl(imageUrl);

    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.backgroundElevated,
      child: resolvedImageUrl.isEmpty
          ? const Icon(Icons.person_outline, color: AppColors.secondaryText)
          : ClipOval(
              child: AppRemoteImage(
                imageUrl: resolvedImageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: Container(
                  width: 40,
                  height: 40,
                  color: AppColors.backgroundElevated,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.secondaryText,
              size: 34,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onRetry(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFeaturedServicesState extends StatelessWidget {
  const _EmptyFeaturedServicesState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: const Text(
        'Todavia no tienes servicios destacados para mostrar aqui.',
        style: TextStyle(color: AppColors.secondaryText, height: 1.35),
      ),
    );
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: AppColors.secondaryText,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No tienes notificaciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Cuando lleguen avisos nuevos del sistema o de tus reservas apareceran aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onTap;

  const _NotificationsButton({required this.unreadCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_outlined,
              size: 28,
              color: AppColors.primaryText,
            ),
            if (unreadCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.alert,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final ProviderNotification item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.isUnread
                    ? AppColors.appBar.withValues(alpha: 0.14)
                    : AppColors.backgroundElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.isUnread
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_none_outlined,
                color: AppColors.appBar,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.timeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
