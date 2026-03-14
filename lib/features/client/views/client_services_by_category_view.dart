import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/usecases/get_services_by_category_use_case.dart';
import 'package:festum/features/client/widgets/client_feedback.dart';
import 'package:festum/features/client/widgets/client_shell_scaffold.dart';
import 'package:festum/features/client/widgets/client_status_view.dart';
import 'package:flutter/material.dart';
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

  bool _isLoading = true;
  String? _errorMessage;
  List<ClientServiceItem> _services = <ClientServiceItem>[];

  @override
  void initState() {
    super.initState();
    _getServicesByCategoryUseCase = locator<GetServicesByCategoryUseCase>();
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
      });
      if (!showLoader) {
        ClientFeedback.showMessage(context, message: 'Servicios actualizados');
      }
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
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.secondaryButton.withValues(
                alpha: 0.35,
              ),
              child: Icon(widget.category.icon, color: AppColors.activeIcon),
            ),
            title: Text(item.name),
            subtitle: Text(item.subtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              context.go(
                AppRoutes.clientServiceDetails(
                  category: widget.category.slug,
                  serviceId: item.id,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
