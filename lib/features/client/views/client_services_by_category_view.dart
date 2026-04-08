import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/network/api_error_mapper.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/app_remote_image.dart';
import 'package:festum/features/client/models/client_cart_item.dart';
import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/services/client_query_cache_service.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:festum/features/client/usecases/add_service_to_cart_use_case.dart';
import 'package:festum/features/client/usecases/get_client_active_order_service_ids_use_case.dart';
import 'package:festum/features/client/usecases/get_client_cart_items_use_case.dart';
import 'package:festum/features/client/usecases/get_services_by_category_use_case.dart';
import 'package:festum/features/client/widgets/client_feedback.dart';
import 'package:festum/features/client/widgets/client_shell_scaffold.dart';
import 'package:festum/features/client/widgets/client_status_view.dart';
import 'package:festum/features/client/widgets/staggered_appear.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ClientServicesByCategoryView extends StatefulWidget {
  const ClientServicesByCategoryView({required this.category, super.key});

  final ClientServiceCategory category;

  @override
  State<ClientServicesByCategoryView> createState() =>
      _ClientServicesByCategoryViewState();
}

class _ClientServicesByCategoryViewState
    extends State<ClientServicesByCategoryView> {
  late final GetServicesByCategoryUseCase _getServicesByCategoryUseCase;
  late final GetClientCartItemsUseCase _getClientCartItemsUseCase;
  late final GetClientActiveOrderServiceIdsUseCase
  _getClientActiveOrderServiceIdsUseCase;
  late final AddServiceToCartUseCase _addServiceToCartUseCase;
  late final ClientTabUiStateService _tabUiStateService;

  bool _isLoading = true;
  String? _errorMessage;
  List<ClientServiceItem> _services = <ClientServiceItem>[];
  Set<String> _cartServiceIds = <String>{};
  Set<String> _activeOrderServiceIds = <String>{};
  Set<String> _addingServiceIds = <String>{};
  Set<String> _recentlyAddedServiceIds = <String>{};
  Set<String> _addErrorServiceIds = <String>{};
  bool _didRefreshAfterImage403 = false;

  @override
  void initState() {
    super.initState();
    _getServicesByCategoryUseCase = locator<GetServicesByCategoryUseCase>();
    _getClientCartItemsUseCase = locator<GetClientCartItemsUseCase>();
    _getClientActiveOrderServiceIdsUseCase =
        locator<GetClientActiveOrderServiceIdsUseCase>();
    _addServiceToCartUseCase = locator<AddServiceToCartUseCase>();
    _tabUiStateService = locator<ClientTabUiStateService>();
    _loadServices(showLoader: true);
  }

  Future<void> _loadServices({required bool showLoader}) async {
    if (showLoader) {
      setState(() => _isLoading = true);
    }

    try {
      final List<ClientServiceItem> result =
          await _getServicesByCategoryUseCase(widget.category);
      if (!mounted) {
        return;
      }
      setState(() {
        _services = result;
        _errorMessage = null;
        _isLoading = false;
        _didRefreshAfterImage403 = false;
      });
      if (!showLoader) {
        ClientFeedback.showMessage(context, message: 'Servicios actualizados');
      }
      await _syncClientLocks();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = ApiErrorMapper.toUserMessage(
          error,
          fallback: 'No pudimos cargar esta categoría.',
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshAfterImageForbidden() async {
    if (_didRefreshAfterImage403) {
      return;
    }
    _didRefreshAfterImage403 = true;
    locator<ClientQueryCacheService>().invalidatePrefix('client_services/');
    await _loadServices(showLoader: false);
  }

  Future<void> _syncClientLocks() async {
    final List<ClientCartItem> cartItems = await _getClientCartItemsUseCase();
    final Set<String> activeOrderServiceIds =
        await _getClientActiveOrderServiceIdsUseCase();
    if (!mounted) {
      return;
    }
    setState(() {
      _cartServiceIds = cartItems.map((ClientCartItem item) => item.id).toSet();
      _activeOrderServiceIds = activeOrderServiceIds;
    });
    _tabUiStateService.setCartCount(cartItems.length);
  }

  Future<void> _addService(ClientServiceItem item) async {
    if (item.products.isNotEmpty) {
      context.go(
        AppRoutes.clientServiceDetails(
          category: widget.category.slug,
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
    if (_activeOrderServiceIds.contains(item.id)) {
      ClientFeedback.showMessage(
        context,
        message:
            'Este servicio ya tiene una orden activa. Podrás solicitarlo de nuevo cuando se complete o se cancele.',
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
    bool added = false;
    try {
      added = await _addServiceToCartUseCase(
        serviceId: item.id,
        name: item.name,
        unitPriceCents: item.unitPriceCents,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _addingServiceIds = <String>{..._addingServiceIds}..remove(item.id);
        _addErrorServiceIds = <String>{..._addErrorServiceIds, item.id};
      });
      ClientFeedback.showMessage(
        context,
        message: ApiErrorMapper.toUserMessage(
          error,
          fallback: 'No se pudo agregar el servicio al carrito.',
        ),
      );
      HapticFeedback.selectionClick();
      _clearTransientAddState(item.id);
      return;
    }
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
      await _syncClientLocks();
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
    return ClientShellScaffold(
      currentTab: ClientTab.services,
      title: widget.category.title,
      showBackButton: true,
      onBackPressed: () => context.go(AppRoutes.clientServices),
      onRefresh: () => _loadServices(showLoader: false),
      body: _buildBody(context),
    );
  }

  void _goToCart() {
    context.go(AppRoutes.clientCart);
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const ClientStatusView.loading(
        title: 'Cargando categoría',
        message: 'Obteniendo servicios disponibles...',
      );
    }

    if (_errorMessage != null) {
      return ClientStatusView.error(
        message: _errorMessage!,
        onRetry: () => _loadServices(showLoader: true),
      );
    }

    if (_services.isEmpty) {
      return ClientStatusView.empty(
        title: 'Sin servicios disponibles',
        message: 'Esta categoría aún no tiene opciones publicadas.',
        onPrimaryAction: () => context.go(AppRoutes.clientServices),
        primaryActionLabel: 'Ver todas las categorías',
        onRetry: () => _loadServices(showLoader: true),
        retryLabel: 'Actualizar',
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      cacheExtent: 800,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: _services.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final ClientServiceItem item = _services[index];
        return StaggeredAppear(
          index: index,
          child: Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.backgroundElevated,
                child: ClipOval(
                  child: AppRemoteImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    width: 44,
                    height: 44,
                    onForbidden: _refreshAfterImageForbidden,
                    placeholder: Container(
                      width: 44,
                      height: 44,
                      color: AppColors.secondaryButton.withValues(alpha: 0.35),
                      alignment: Alignment.center,
                      child: Icon(
                        widget.category.icon,
                        color: AppColors.activeIcon,
                      ),
                    ),
                  ),
                ),
              ),
              title: Hero(
                tag: 'client-service-title-${item.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    item.cardName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              subtitle: Text(
                item.cardSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: SizedBox(
                width: 86,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      tooltip: _addErrorServiceIds.contains(item.id)
                          ? 'Error al agregar'
                          : _recentlyAddedServiceIds.contains(item.id)
                          ? 'Agregado'
                          : _activeOrderServiceIds.contains(item.id)
                          ? 'Orden activa en curso'
                          : _cartServiceIds.contains(item.id)
                          ? 'Ver carrito'
                          : 'Agregar',
                      onPressed: _addingServiceIds.contains(item.id)
                          ? null
                          : _activeOrderServiceIds.contains(item.id)
                          ? null
                          : _cartServiceIds.contains(item.id)
                          ? _goToCart
                          : () => _addService(item),
                      icon: _addingServiceIds.contains(item.id)
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0,
                                end: _recentlyAddedServiceIds.contains(item.id)
                                    ? 1
                                    : 0,
                              ),
                              duration: const Duration(milliseconds: 380),
                              curve: Curves.easeOutCubic,
                              builder:
                                  (
                                    BuildContext context,
                                    double pulse,
                                    Widget? child,
                                  ) {
                                    final double scale =
                                        1 +
                                        (0.16 * (1 - (2 * pulse - 1).abs()));
                                    return Transform.scale(
                                      scale: scale,
                                      child: child,
                                    );
                                  },
                              child: Icon(
                                _addErrorServiceIds.contains(item.id)
                                    ? Icons.error_outline_rounded
                                    : _recentlyAddedServiceIds.contains(item.id)
                                    ? Icons.check_circle_rounded
                                    : _activeOrderServiceIds.contains(item.id)
                                    ? Icons.lock_clock_rounded
                                    : _cartServiceIds.contains(item.id)
                                    ? Icons.shopping_cart_checkout_rounded
                                    : Icons.add_shopping_cart_rounded,
                                size: 21,
                                color: _addErrorServiceIds.contains(item.id)
                                    ? AppColors.alert
                                    : _recentlyAddedServiceIds.contains(item.id)
                                    ? AppColors.activeIcon
                                    : null,
                              ),
                            ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
              onTap: () {
                context.go(
                  AppRoutes.clientServiceDetails(
                    category: widget.category.slug,
                    serviceId: item.id,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
