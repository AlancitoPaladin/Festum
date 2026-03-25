import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/app_remote_image.dart';
import 'package:festum/core/widgets/custom_app_bar.dart';
import 'package:festum/features/provider/models/provider_product.dart';
import 'package:festum/features/provider/models/provider_tab.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/usecases/delete_provider_service_product_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_service_products_use_case.dart';
import 'package:festum/features/provider/viewmodels/manage_service_viewmodel.dart';
import 'package:festum/features/provider/widgets/provider_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stacked/stacked.dart';

class ManageServiceView extends StatelessWidget {
  const ManageServiceView({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.category,
  });

  final String serviceId;
  final String serviceName;
  final ServiceCategory category;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ManageServiceViewModel>.reactive(
      viewModelBuilder: () => ManageServiceViewModel(
        serviceId: serviceId,
        serviceName: serviceName,
        category: category,
        getProviderServiceProductsUseCase:
            locator<GetProviderServiceProductsUseCase>(),
        deleteProviderServiceProductUseCase:
            locator<DeleteProviderServiceProductUseCase>(),
        providerReactivityService: locator<ProviderReactivityService>(),
      ),
      onViewModelReady: (ManageServiceViewModel model) => model.initialise(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: serviceName,
          showBackButton: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.primaryText),
              onPressed: () {},
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Administra los productos de este servicio',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _AddProductButton(
                    onTap: () {
                      context.push(
                        AppRoutes.providerAddProductRoute(
                          serviceId,
                          category.name,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(child: _buildBody(context, model)),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ProviderBottomNavBar(
                currentTab: ProviderTab.services,
                onTabPressed: (tab) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ManageServiceViewModel model) {
    if (model.isBusy && model.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.errorMessage != null && model.products.isEmpty) {
      return _ManageServiceErrorState(
        message: model.errorMessage!,
        onRetry: model.initialise,
      );
    }

    if (model.products.isEmpty) {
      return _EmptyManageServiceState(onRefresh: model.initialise);
    }

    return RefreshIndicator(
      onRefresh: model.initialise,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        itemCount: model.products.length,
        itemBuilder: (BuildContext context, int index) {
          final ProviderProduct product = model.products[index];
          return _ProductCard(
            product: product,
            isDeleting: model.isDeleting(product.id),
            onEdit: () {
              context.push(
                AppRoutes.providerEditProductRoute(product.id),
              );
            },
            onDelete: () => _deleteProduct(context, model, index),
          );
        },
      ),
    );
  }

  Future<void> _deleteProduct(
    BuildContext context,
    ManageServiceViewModel model,
    int index,
  ) async {
    final String? errorMessage = await model.deleteProduct(index);
    if (!context.mounted) {
      return;
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Producto eliminado.')));
  }
}

class _ManageServiceErrorState extends StatelessWidget {
  const _ManageServiceErrorState({
    required this.message,
    required this.onRetry,
  });

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
              Icons.inventory_2_outlined,
              size: 34,
              color: AppColors.secondaryText,
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

class _EmptyManageServiceState extends StatelessWidget {
  const _EmptyManageServiceState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 36,
                  color: AppColors.secondaryText,
                ),
                SizedBox(height: 14),
                Text(
                  'Todavia no tienes productos en este servicio.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Agrega el primer producto para empezar a manejar precios, disponibilidad y reservas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddProductButton extends StatelessWidget {
  const _AddProductButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryText.withValues(alpha: 0.2),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.primaryText),
            SizedBox(width: 8),
            Text(
              'Anadir producto',
              style: TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  final ProviderProduct product;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: AppRemoteImage(
              imageUrl: product.resolvedImageUrl,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(12),
              placeholder: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: AppColors.secondaryText,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '\$${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.description.trim().isNotEmpty
                      ? product.description
                      : 'Sin descripcion disponible.',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Colors.black12),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.secondaryText,
                      ),
                      onPressed: isDeleting ? null : onEdit,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    if (isDeleting)
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.alert,
                        ),
                        onPressed: onDelete,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
