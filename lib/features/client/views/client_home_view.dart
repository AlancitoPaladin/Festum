import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/app_remote_image.dart';
import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:festum/features/client/usecases/add_service_to_cart_use_case.dart';
import 'package:festum/features/client/usecases/get_client_cart_items_use_case.dart';
import 'package:festum/features/client/usecases/get_client_home_sections_use_case.dart';
import 'package:festum/features/client/widgets/client_feedback.dart';
import 'package:festum/features/client/widgets/client_shell_scaffold.dart';
import 'package:festum/features/client/widgets/client_status_view.dart';
import 'package:festum/features/client/widgets/staggered_appear.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ClientHomeView extends StatefulWidget {
  const ClientHomeView({required this.tab, super.key});

  final ClientTab tab;

  @override
  State<ClientHomeView> createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  late final GetClientHomeSectionsUseCase _getClientHomeSectionsUseCase;
  late final GetClientCartItemsUseCase _getClientCartItemsUseCase;
  late final AddServiceToCartUseCase _addServiceToCartUseCase;
  late final ClientTabUiStateService _tabUiStateService;
  late final ScrollController _scrollController;

  bool _isLoading = true;
  String? _errorMessage;
  Map<ClientServiceCategory, List<ClientServiceItem>> _sections =
      <ClientServiceCategory, List<ClientServiceItem>>{};
  Set<String> _cartServiceIds = <String>{};
  Set<String> _addingServiceIds = <String>{};
  Set<String> _recentlyAddedServiceIds = <String>{};
  Set<String> _addErrorServiceIds = <String>{};
  bool _didRefreshAfterImage403 = false;

  @override
  void initState() {
    super.initState();
    _getClientHomeSectionsUseCase = locator<GetClientHomeSectionsUseCase>();
    _getClientCartItemsUseCase = locator<GetClientCartItemsUseCase>();
    _addServiceToCartUseCase = locator<AddServiceToCartUseCase>();
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
        _didRefreshAfterImage403 = false;
      });
      if (!showLoader) {
        ClientFeedback.showMessage(context, message: 'Inicio actualizado');
      }
      await _syncCartState();
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

  Future<void> _refreshAfterImageForbidden() async {
    if (_didRefreshAfterImage403) {
      return;
    }
    _didRefreshAfterImage403 = true;
    await _loadHomeSections(showLoader: false);
  }

  Future<void> _syncCartState() async {
    final cartItems = await _getClientCartItemsUseCase();
    if (!mounted) {
      return;
    }
    setState(() {
      _cartServiceIds = cartItems.map((item) => item.id).toSet();
    });
    _tabUiStateService.setCartCount(cartItems.length);
  }

  Future<void> _addService({
    required ClientServiceCategory category,
    required ClientServiceItem item,
  }) async {
    if (item.products.isNotEmpty) {
      context.go(
        AppRoutes.clientServiceDetails(
          category: category.slug,
          serviceId: item.id,
        ),
      );
      return;
    }

    if (_cartServiceIds.contains(item.id) ||
        _addingServiceIds.contains(item.id)) {
      ClientFeedback.showMessage(
        context,
        message: 'Este servicio ya está en el carrito.',
      );
      HapticFeedback.selectionClick();
      return;
    }

    setState(() {
      _addingServiceIds = <String>{..._addingServiceIds, item.id};
      _addErrorServiceIds = <String>{..._addErrorServiceIds}..remove(item.id);
      _recentlyAddedServiceIds = <String>{..._recentlyAddedServiceIds}
        ..remove(item.id);
    });
    final bool added = await _addServiceToCartUseCase(
      serviceId: item.id,
      name: item.name,
      unitPriceCents: item.unitPriceCents,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _addingServiceIds = <String>{..._addingServiceIds}..remove(item.id);
    });
    if (!added) {
      setState(() {
        _addErrorServiceIds = <String>{..._addErrorServiceIds, item.id};
      });
      _clearTransientAddState(item.id);
      ClientFeedback.showMessage(
        context,
        message: 'Este servicio ya está en el carrito.',
      );
      HapticFeedback.selectionClick();
      await _syncCartState();
      return;
    }

    setState(() {
      _cartServiceIds = <String>{..._cartServiceIds, item.id};
      _recentlyAddedServiceIds = <String>{..._recentlyAddedServiceIds, item.id};
      _addErrorServiceIds = <String>{..._addErrorServiceIds}..remove(item.id);
    });
    _clearTransientAddState(item.id);
    _tabUiStateService.setCartCount(_cartServiceIds.length);
    ClientFeedback.showMessage(
      context,
      message: 'Servicio agregado al carrito.',
    );
    HapticFeedback.lightImpact();
  }

  void _clearTransientAddState(String serviceId) {
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _recentlyAddedServiceIds = <String>{..._recentlyAddedServiceIds}
          ..remove(serviceId);
        _addErrorServiceIds = <String>{..._addErrorServiceIds}
          ..remove(serviceId);
      });
    });
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

  void _goToCart() {
    context.go(AppRoutes.clientCart);
  }

  Widget _buildBody() {
    final List<ClientServiceCategory> visibleCategories = ClientServiceCategory
        .values
        .where((ClientServiceCategory category) {
          return (_sections[category] ?? const <ClientServiceItem>[])
              .isNotEmpty;
        })
        .toList();

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

    if (visibleCategories.isEmpty) {
      return ClientStatusView.empty(
        title: 'No hay servicios por mostrar',
        message: 'Vuelve más tarde para consultar las categorías.',
        onPrimaryAction: () => context.go(AppRoutes.clientOrders),
        primaryActionLabel: 'Ir a mis órdenes',
        onRetry: () => _loadHomeSections(showLoader: true),
      );
    }

    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
      children: visibleCategories
          .map(
            (ClientServiceCategory category) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ServiceCategorySection(
                category: category,
                services: _sections[category] ?? const <ClientServiceItem>[],
                cartServiceIds: _cartServiceIds,
                addingServiceIds: _addingServiceIds,
                recentlyAddedServiceIds: _recentlyAddedServiceIds,
                addErrorServiceIds: _addErrorServiceIds,
                onAddService: (ClientServiceItem item) {
                  return _addService(category: category, item: item);
                },
                onOpenCart: _goToCart,
                onForbiddenImage: _refreshAfterImageForbidden,
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
    required this.cartServiceIds,
    required this.addingServiceIds,
    required this.recentlyAddedServiceIds,
    required this.addErrorServiceIds,
    required this.onAddService,
    required this.onOpenCart,
    required this.onForbiddenImage,
  });

  final ClientServiceCategory category;
  final List<ClientServiceItem> services;
  final Set<String> cartServiceIds;
  final Set<String> addingServiceIds;
  final Set<String> recentlyAddedServiceIds;
  final Set<String> addErrorServiceIds;
  final Future<void> Function(ClientServiceItem item) onAddService;
  final VoidCallback onOpenCart;
  final Future<void> Function() onForbiddenImage;

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
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: services.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (BuildContext context, int index) {
                  final ClientServiceItem item = services[index];
                  return StaggeredAppear(
                    index: index,
                    child: _ServicePreviewCard(
                      item: item,
                      isAdded: cartServiceIds.contains(item.id),
                      isAdding: addingServiceIds.contains(item.id),
                      hasRecentSuccess: recentlyAddedServiceIds.contains(
                        item.id,
                      ),
                      hasAddError: addErrorServiceIds.contains(item.id),
                      onAdd: () => onAddService(item),
                      onOpenCart: onOpenCart,
                      onForbiddenImage: onForbiddenImage,
                      onTap: () {
                        context.go(
                          AppRoutes.clientServiceDetails(
                            category: category.slug,
                            serviceId: item.id,
                          ),
                        );
                      },
                    ),
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
  const _ServicePreviewCard({
    required this.item,
    required this.isAdded,
    required this.isAdding,
    required this.hasRecentSuccess,
    required this.hasAddError,
    required this.onAdd,
    required this.onOpenCart,
    required this.onForbiddenImage,
    required this.onTap,
  });

  final ClientServiceItem item;
  final bool isAdded;
  final bool isAdding;
  final bool hasRecentSuccess;
  final bool hasAddError;
  final VoidCallback onAdd;
  final VoidCallback onOpenCart;
  final Future<void> Function() onForbiddenImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 236,
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
                SizedBox(
                  height: 58,
                  width: double.infinity,
                  child: AppRemoteImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                    onForbidden: onForbiddenImage,
                    placeholder: Container(
                      color: AppColors.backgroundElevated,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.secondaryText.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Hero(
                  tag: 'client-service-badge-${item.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: item.resolvedBadge.isEmpty
                        ? const SizedBox.shrink()
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryButton.withValues(
                                alpha: 0.42,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item.resolvedBadge,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Hero(
                        tag: 'client-service-title-${item.id}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            item.cardName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.resolvedPriceLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.activeIcon,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: isAdding ? null : (isAdded ? onOpenCart : onAdd),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      minimumSize: const Size.fromHeight(34),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: hasRecentSuccess ? 1 : 0,
                      ),
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutCubic,
                      builder:
                          (BuildContext context, double pulse, Widget? child) {
                            final double scale =
                                1 + (0.16 * (1 - (2 * pulse - 1).abs()));
                            return Transform.scale(scale: scale, child: child);
                          },
                      child: Icon(
                        hasAddError
                            ? Icons.error_outline_rounded
                            : hasRecentSuccess
                            ? Icons.check_circle_rounded
                            : isAdded
                            ? Icons.shopping_cart_checkout_rounded
                            : isAdding
                            ? Icons.hourglass_top_rounded
                            : Icons.add_shopping_cart_rounded,
                        size: 18,
                      ),
                    ),
                    label: Text(
                      hasAddError
                          ? 'Intenta de nuevo'
                          : hasRecentSuccess
                          ? 'Agregado'
                          : isAdded
                          ? 'Ver carrito'
                          : isAdding
                          ? 'Agregando...'
                          : 'Agregar',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
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
