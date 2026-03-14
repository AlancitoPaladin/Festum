import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:festum/features/client/usecases/get_client_home_sections_use_case.dart';
import 'package:festum/features/client/widgets/client_feedback.dart';
import 'package:festum/features/client/widgets/client_shell_scaffold.dart';
import 'package:festum/features/client/widgets/client_status_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientHomeView extends StatefulWidget {
  const ClientHomeView({required this.tab, super.key});

  final ClientTab tab;

  @override
  State<ClientHomeView> createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  late final GetClientHomeSectionsUseCase _getClientHomeSectionsUseCase;
  late final ClientTabUiStateService _tabUiStateService;
  late final ScrollController _scrollController;

  bool _isLoading = true;
  String? _errorMessage;
  Map<ClientServiceCategory, List<ClientServiceItem>> _sections =
      <ClientServiceCategory, List<ClientServiceItem>>{};

  @override
  void initState() {
    super.initState();
    _getClientHomeSectionsUseCase = locator<GetClientHomeSectionsUseCase>();
    _tabUiStateService = locator<ClientTabUiStateService>();
    _scrollController = ScrollController(
      initialScrollOffset: _tabUiStateService.scrollOffsetFor(
        ClientTab.services,
      ),
    )..addListener(_onScroll);

    _loadHomeSections(showLoader: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _tabUiStateService.saveScrollOffset(
      ClientTab.services,
      _scrollController.offset,
    );
  }

  Future<void> _loadHomeSections({required bool showLoader}) async {
    if (showLoader) {
      setState(() => _isLoading = true);
    }

    try {
      final Map<ClientServiceCategory, List<ClientServiceItem>> result =
          await _getClientHomeSectionsUseCase();
      if (!mounted) {
        return;
      }
      setState(() {
        _sections = result;
        _errorMessage = null;
        _isLoading = false;
      });
      if (!showLoader) {
        ClientFeedback.showMessage(context, message: 'Inicio actualizado');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'No pudimos cargar los servicios por categoría.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayName =
        locator<AuthStateService>().displayName ?? 'Cliente';

    return ClientShellScaffold(
      currentTab: widget.tab,
      title: 'Bienvenido, $displayName',
      onRefresh: () => _loadHomeSections(showLoader: false),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ClientStatusView.loading(
        title: 'Cargando inicio',
        message: 'Preparando servicios destacados...',
      );
    }

    if (_errorMessage != null) {
      return ClientStatusView.error(
        message: _errorMessage!,
        onRetry: () => _loadHomeSections(showLoader: true),
      );
    }

    if (_sections.isEmpty) {
      return ClientStatusView.empty(
        title: 'No hay servicios por mostrar',
        message: 'Vuelve más tarde para consultar las categorías.',
        onRetry: () => _loadHomeSections(showLoader: true),
      );
    }

    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
      children: ClientServiceCategory.values
          .map(
            (ClientServiceCategory category) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ServiceCategorySection(
                category: category,
                services: _sections[category] ?? const <ClientServiceItem>[],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ServiceCategorySection extends StatelessWidget {
  const _ServiceCategorySection({
    required this.category,
    required this.services,
  });

  final ClientServiceCategory category;
  final List<ClientServiceItem> services;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(category.icon, color: AppColors.activeIcon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Ver todos',
                  onPressed: () {
                    context.go(AppRoutes.clientServicesCategory(category.slug));
                  },
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 156,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: services.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (BuildContext context, int index) {
                  final ClientServiceItem item = services[index];
                  return _ServicePreviewCard(
                    item: item,
                    onTap: () {
                      context.go(
                        AppRoutes.clientServiceDetails(
                          category: category.slug,
                          serviceId: item.id,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicePreviewCard extends StatelessWidget {
  const _ServicePreviewCard({required this.item, required this.onTap});

  final ClientServiceItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 228,
      child: Material(
        color: AppColors.cardAccent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryButton.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.badge,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.priceLabel,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.activeIcon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
