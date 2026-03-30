import 'dart:ui';

import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/network/api_error_mapper.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/app_remote_image.dart';
import 'package:festum/features/client/models/client_order_item.dart';
import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:festum/features/client/usecases/add_service_to_cart_use_case.dart';
import 'package:festum/features/client/usecases/get_client_orders_use_case.dart';
import 'package:festum/features/client/usecases/get_client_service_by_id_use_case.dart';
import 'package:festum/features/client/usecases/is_service_in_cart_use_case.dart';
import 'package:festum/features/client/widgets/client_feedback.dart';
import 'package:festum/features/client/widgets/client_shell_scaffold.dart';
import 'package:festum/features/client/widgets/client_status_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ClientServiceDetailView extends StatefulWidget {
  const ClientServiceDetailView({
    required this.category,
    required this.serviceId,
    super.key,
  });

  final ClientServiceCategory category;
  final String serviceId;

  @override
  State<ClientServiceDetailView> createState() =>
      _ClientServiceDetailViewState();
}

class _ClientServiceDetailViewState extends State<ClientServiceDetailView> {
  late final GetClientServiceByIdUseCase _getClientServiceByIdUseCase;
  late final GetClientOrdersUseCase _getClientOrdersUseCase;
  late final AddServiceToCartUseCase _addServiceToCartUseCase;
  late final IsServiceInCartUseCase _isServiceInCartUseCase;

  bool _isLoading = true;
  bool _isAddingToCart = false;
  bool _isInCart = false;
  bool _isBlockedByActiveOrder = false;
  String? _errorMessage;
  ClientServiceItem? _service;
  Set<String> _selectedProductIds = <String>{};
  bool _didRefreshAfterImage403 = false;

  @override
  void initState() {
    super.initState();
    _getClientServiceByIdUseCase = locator<GetClientServiceByIdUseCase>();
    _getClientOrdersUseCase = locator<GetClientOrdersUseCase>();
    _addServiceToCartUseCase = locator<AddServiceToCartUseCase>();
    _isServiceInCartUseCase = locator<IsServiceInCartUseCase>();
    _loadDetail(showLoader: true);
  }

  Future<void> _loadDetail({required bool showLoader}) async {
    if (showLoader) {
      setState(() => _isLoading = true);
    }

    try {
      final ClientServiceItem? result = await _getClientServiceByIdUseCase(
        category: widget.category,
        serviceId: widget.serviceId,
      );
      if (!mounted) {
        return;
      }
      if (result == null) {
        setState(() {
          _service = null;
          _errorMessage = 'No encontramos el servicio solicitado.';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _service = result;
        _errorMessage = null;
        _isLoading = false;
        _didRefreshAfterImage403 = false;
        _selectedProductIds = <String>{};
      });
      final List<dynamic> lockSnapshot = await Future.wait<dynamic>(<Future<dynamic>>[
        _isServiceInCartUseCase(result.id),
        _getClientOrdersUseCase(),
      ]);
      final bool isInCart = lockSnapshot[0] as bool;
      final List<ClientOrderItem> orders =
          lockSnapshot[1] as List<ClientOrderItem>;
      final bool isBlockedByActiveOrder = orders
          .where(
            (ClientOrderItem order) =>
                order.status != ClientOrderStatus.cancelled &&
                order.status != ClientOrderStatus.completed,
          )
          .expand((ClientOrderItem order) => order.items)
          .any((ClientOrderLineItem item) => item.serviceId == result.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _isInCart = isInCart;
        _isBlockedByActiveOrder = isBlockedByActiveOrder;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = ApiErrorMapper.toUserMessage(
          error,
          fallback: 'No pudimos cargar el detalle del servicio.',
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
    await _loadDetail(showLoader: false);
  }

  Future<void> _addCurrentServiceToCart() async {
    final ClientServiceItem? service = _service;
    if (service == null || _isInCart || _isAddingToCart) {
      return;
    }
    if (_isBlockedByActiveOrder) {
      ClientFeedback.showMessage(
        context,
        message:
            'Este servicio ya tiene una orden activa. Podrás solicitarlo de nuevo cuando se complete o se cancele.',
      );
      HapticFeedback.selectionClick();
      return;
    }

    final List<ClientServiceProduct> selectedProducts =
        _resolveSelectedProducts(service);
    final String itemName = service.resolvedName;
    final int selectedProductsTotal = selectedProducts.fold<int>(
      0,
      (int sum, ClientServiceProduct product) => sum + product.unitPriceCents,
    );
    final int itemUnitPriceCents =
        service.unitPriceCents + selectedProductsTotal;
    final ClientServiceProduct? primaryProduct = selectedProducts.isEmpty
        ? null
        : selectedProducts.first;
    final String? selectedProductsLabel = selectedProducts.isEmpty
        ? null
        : selectedProducts
              .map((ClientServiceProduct p) => p.name.trim())
              .join(', ');

    setState(() => _isAddingToCart = true);
    bool added = false;
    try {
      added = await _addServiceToCartUseCase(
        serviceId: service.id,
        name: itemName,
        unitPriceCents: itemUnitPriceCents,
        productId: primaryProduct?.id,
        productName: selectedProductsLabel,
        selectedProductIds: selectedProducts
            .map((ClientServiceProduct p) => p.id)
            .toList(),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isAddingToCart = false);
      ClientFeedback.showMessage(
        context,
        message: ApiErrorMapper.toUserMessage(
          error,
          fallback: 'No se pudo agregar el servicio al carrito.',
        ),
      );
      HapticFeedback.selectionClick();
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _isAddingToCart = false);

    if (!added) {
      setState(() => _isInCart = true);
      ClientFeedback.showMessage(
        context,
        message: 'Este servicio ya está en el carrito.',
      );
      HapticFeedback.selectionClick();
      return;
    }

    final ClientTabUiStateService tabState = locator<ClientTabUiStateService>();
    tabState.setCartCount(tabState.badgeFor(ClientTab.cart) + 1);
    setState(() => _isInCart = true);
    ClientFeedback.showMessage(
      context,
      message: 'Servicio agregado al carrito.',
    );
    HapticFeedback.lightImpact();
  }

  List<ClientServiceProduct> _resolveSelectedProducts(
    ClientServiceItem service,
  ) {
    if (service.products.isEmpty || _selectedProductIds.isEmpty) {
      return const <ClientServiceProduct>[];
    }
    return service.products
        .where(
          (ClientServiceProduct product) =>
              _selectedProductIds.contains(product.id),
        )
        .toList();
  }

  int _resolveCtaTotalCents(ClientServiceItem service) {
    final List<ClientServiceProduct> selected = _resolveSelectedProducts(
      service,
    );
    final int selectedTotal = selected.fold<int>(
      0,
      (int sum, ClientServiceProduct product) => sum + product.unitPriceCents,
    );
    return service.unitPriceCents + selectedTotal;
  }

  String _formatPriceLabelFromCents(int cents) {
    if (cents <= 0) {
      return 'Precio por definir';
    }
    final double amount = cents / 100;
    final String fixed = amount.toStringAsFixed(
      amount.truncateToDouble() == amount ? 0 : 2,
    );
    final List<String> parts = fixed.split('.');
    final String wholePart = parts.first;
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < wholePart.length; i++) {
      final int reverseIndex = wholePart.length - i;
      buffer.write(wholePart[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    final String decimalPart = parts.length > 1 && parts[1] != '00'
        ? '.${parts[1]}'
        : '';
    return 'Desde \$$buffer$decimalPart MXN';
  }

  @override
  Widget build(BuildContext context) {
    return ClientShellScaffold(
      currentTab: ClientTab.services,
      showAppBar: false,
      onRefresh: () => _loadDetail(showLoader: false),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const ClientStatusView.loading(
        title: 'Cargando detalle',
        message: 'Preparando información del servicio...',
      );
    }

    if (_errorMessage != null || _service == null) {
      return ClientStatusView.error(
        message: _errorMessage ?? 'No encontramos el servicio solicitado.',
        onRetry: () => _loadDetail(showLoader: true),
      );
    }

    final ClientServiceItem service = _service!;
    final int ctaTotalCents = _resolveCtaTotalCents(service);
    final String ctaPriceLabel = _formatPriceLabelFromCents(ctaTotalCents);

    return Stack(
      children: <Widget>[
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 180),
          children: <Widget>[
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton.filledTonal(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                      return;
                    }
                    context.go(
                      AppRoutes.clientServicesCategory(widget.category.slug),
                    );
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _HeroGallery(
              service: service,
              onForbiddenImage: _refreshAfterImageForbidden,
            ),
            const SizedBox(height: 16),
            _ServiceHeader(service: service),
            const SizedBox(height: 12),
            _QuickFacts(category: widget.category, service: service),
            const SizedBox(height: 16),
            _AvailabilityCard(),
            if (service.products.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              _ProductOptionsSection(
                products: service.products,
                selectedProductIds: _selectedProductIds,
                onToggle: (String productId) {
                  setState(() {
                    final Set<String> next = <String>{..._selectedProductIds};
                    if (next.contains(productId)) {
                      next.remove(productId);
                    } else {
                      next.add(productId);
                    }
                    _selectedProductIds = next;
                  });
                },
              ),
            ],
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Descripción general',
              body: service.description.trim().isEmpty
                  ? 'El proveedor aún no agregó una descripción detallada para este servicio.'
                  : service.description,
            ),
            if (service.products.isEmpty) ...<Widget>[
              const SizedBox(height: 12),
              const _InfoSection(
                title: 'Productos',
                body:
                    'Este servicio aún no tiene productos publicados. En cuanto el proveedor los publique, aparecerán aquí.',
              ),
            ],
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 12,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 60),
            child: _BottomCta(
              priceLabel: ctaPriceLabel,
              isAdded: _isInCart,
              isBlockedByOrder: _isBlockedByActiveOrder,
              isAdding: _isAddingToCart,
              onAdd: _addCurrentServiceToCart,
              onOpenCart: () => context.go(AppRoutes.clientCart),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroGallery extends StatelessWidget {
  const _HeroGallery({required this.service, required this.onForbiddenImage});

  final ClientServiceItem service;
  final Future<void> Function() onForbiddenImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 220,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: AppRemoteImage(
                    imageUrl: service.imageUrl,
                    fit: BoxFit.cover,
                    onForbidden: onForbiddenImage,
                    placeholder: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            AppColors.appBar,
                            AppColors.secondaryButton,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.photo_library_rounded,
                        color: AppColors.appBarText.withValues(alpha: 0.8),
                        size: 56,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.22),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: Hero(
                    tag: 'client-service-badge-${service.id}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: _Badge(label: service.resolvedBadge),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Text(
                    'Vista previa',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.appBarText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                width: 86,
                child: AppRemoteImage(
                  imageUrl: service.imageUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(16),
                  onForbidden: onForbiddenImage,
                  placeholder: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.cardAccent,
                      border: Border.all(
                        color: AppColors.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ServiceHeader extends StatelessWidget {
  const _ServiceHeader({required this.service});

  final ClientServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Hero(
          tag: 'client-service-title-${service.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Text(
              service.resolvedName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(service.resolvedSubtitle),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            if (service.resolvedBadge.isNotEmpty) ...<Widget>[
              _ServiceBadgePill(label: service.resolvedBadge),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                service.resolvedPriceLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.activeIcon,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickFacts extends StatelessWidget {
  const _QuickFacts({required this.category, required this.service});

  final ClientServiceCategory category;
  final ClientServiceItem service;

  @override
  Widget build(BuildContext context) {
    final List<Widget> facts = <Widget>[
      _FactChip(icon: category.icon, label: category.title),
      _FactChip(
        icon: Icons.inventory_2_rounded,
        label: service.products.isEmpty
            ? 'Sin productos publicados'
            : '${service.products.length} productos disponibles',
      ),
    ];

    if (service.resolvedSubtitle.trim().isNotEmpty) {
      facts.add(
        _FactChip(
          icon: Icons.info_outline_rounded,
          label: service.resolvedSubtitle,
        ),
      );
    }

    return Wrap(spacing: 10, runSpacing: 8, children: facts);
  }
}

class _ProductOptionsSection extends StatelessWidget {
  const _ProductOptionsSection({
    required this.products,
    required this.selectedProductIds,
    required this.onToggle,
  });

  final List<ClientServiceProduct> products;
  final Set<String> selectedProductIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Productos adicionales',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Selecciona los que quieras agregar a tu servicio.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            ...products.map(
              (ClientServiceProduct product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProductOptionCard(
                  product: product,
                  isSelected: selectedProductIds.contains(product.id),
                  onTap: () => onToggle(product.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductOptionCard extends StatelessWidget {
  const _ProductOptionCard({
    required this.product,
    required this.isSelected,
    required this.onTap,
  });

  final ClientServiceProduct product;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondaryButton.withValues(alpha: 0.25)
                : AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.activeIcon.withValues(alpha: 0.6)
                  : AppColors.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: AppRemoteImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: AppColors.cardAccent,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.add_circle_outline_rounded,
                          size: 20,
                          color: isSelected
                              ? AppColors.activeIcon
                              : AppColors.secondaryText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description.trim().isEmpty
                          ? 'Sin descripcion disponible.'
                          : product.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.priceLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.activeIcon,
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

class _AvailabilityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Disponibilidad',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: const <Widget>[
                Icon(
                  Icons.event_available_rounded,
                  size: 18,
                  color: AppColors.activeIcon,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'La disponibilidad se confirma con el proveedor al momento de reservar.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Próximamente se mostrará calendario en tiempo real.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      Text(title, style: Theme.of(context).textTheme.titleMedium),
    ];

    if (body != null) {
      children.addAll(<Widget>[
        const SizedBox(height: 6),
        Text(body!, style: Theme.of(context).textTheme.bodyMedium),
      ]);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({
    required this.priceLabel,
    required this.isAdded,
    required this.isBlockedByOrder,
    required this.isAdding,
    required this.onAdd,
    required this.onOpenCart,
  });

  final String priceLabel;
  final bool isAdded;
  final bool isBlockedByOrder;
  final bool isAdding;
  final VoidCallback onAdd;
  final VoidCallback onOpenCart;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primaryText.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Total desde',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        priceLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: isAdding
                      ? null
                      : (isBlockedByOrder
                            ? null
                            : (isAdded ? onOpenCart : onAdd)),
                  icon: Icon(
                    isBlockedByOrder
                        ? Icons.lock_clock_rounded
                        : isAdded
                        ? Icons.shopping_cart_checkout_rounded
                        : isAdding
                        ? Icons.hourglass_top_rounded
                        : Icons.add_shopping_cart_rounded,
                  ),
                  label: Text(
                    isBlockedByOrder
                        ? 'Orden activa'
                        : isAdded
                        ? 'Ver carrito'
                        : (isAdding ? 'Agregando...' : 'Agregar'),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardAccent.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.activeIcon),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _ServiceBadgePill extends StatelessWidget {
  const _ServiceBadgePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondaryButton.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.sell_rounded, size: 16, color: AppColors.appBar),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
