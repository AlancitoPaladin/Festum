import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/app_remote_image.dart';
import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:festum/features/client/usecases/add_service_to_cart_use_case.dart';
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
  late final AddServiceToCartUseCase _addServiceToCartUseCase;
  late final ClientTabUiStateService _tabUiStateService;

  bool _isLoading = true;
  String? _errorMessage;
  List<ClientServiceItem> _services = <ClientServiceItem>[];
  Set<String> _cartServiceIds = <String>{};
  Set<String> _addingServiceIds = <String>{};
  bool _didRefreshAfterImage403 = false;

  @override
  void initState() {
    super.initState();
    _getServicesByCategoryUseCase = locator<GetServicesByCategoryUseCase>();
    _getClientCartItemsUseCase = locator<GetClientCartItemsUseCase>();
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
      await _syncCartState();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'No pudimos cargar esta categoría.';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshAfterImageForbidden() async {
    if (_didRefreshAfterImage403) {
      return;
    }
    _didRefreshAfterImage403 = true;
    await _loadServices(showLoader: false);
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

  Future<void> _addService(ClientServiceItem item) async {
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
    });
    _tabUiStateService.setCartCount(_cartServiceIds.length);
    ClientFeedback.showMessage(
      context,
      message: 'Servicio agregado al carrito.',
    );
    HapticFeedback.lightImpact();
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
                      tooltip: _cartServiceIds.contains(item.id)
                          ? 'Ver carrito'
                          : 'Agregar',
                      onPressed: _addingServiceIds.contains(item.id)
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
                          : Icon(
                              _cartServiceIds.contains(item.id)
                                  ? Icons.shopping_cart_checkout_rounded
                                  : Icons.add_shopping_cart_rounded,
                              size: 20,
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
