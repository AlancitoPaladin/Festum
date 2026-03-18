import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/usecases/get_client_service_by_id_use_case.dart';
import 'package:festum/features/client/widgets/client_feedback.dart';
import 'package:festum/features/client/widgets/client_shell_scaffold.dart';
import 'package:festum/features/client/widgets/client_status_view.dart';
import 'package:flutter/material.dart';
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

  bool _isLoading = true;
  String? _errorMessage;
  ClientServiceItem? _service;

  @override
  void initState() {
    super.initState();
    _getClientServiceByIdUseCase = locator<GetClientServiceByIdUseCase>();
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
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'No pudimos cargar el detalle del servicio.';
        _isLoading = false;
      });
    }
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
        message: 'Preparando informacion del servicio...',
      );
    }

    if (_errorMessage != null || _service == null) {
      return ClientStatusView.error(
        message: _errorMessage ?? 'No encontramos el servicio solicitado.',
        onRetry: () => _loadDetail(showLoader: true),
      );
    }

    final ClientServiceItem service = _service!;

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
            _HeroGallery(service: service),
            const SizedBox(height: 16),
            _ServiceHeader(service: service),
            const SizedBox(height: 12),
            _QuickFacts(category: widget.category),
            const SizedBox(height: 16),
            _AvailabilityCard(),
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Descripcion general',
              body:
                  'Servicio premium con coordinacion completa, montaje, desmontaje y soporte durante el evento. Los ajustes finales se definen en la confirmacion.',
            ),
            const SizedBox(height: 12),
            _InfoSection(
              title: 'Incluye',
              bullets: const <String>[
                'Asesoria de logistica y layout',
                'Montaje y desmontaje completo',
                'Soporte durante el evento',
                'Personal dedicado en sitio',
              ],
            ),
            const SizedBox(height: 12),
            _InfoSection(
              title: 'Politicas',
              bullets: const <String>[
                'Anticipo requerido para apartar fecha',
                'Cambios sujetos a disponibilidad',
                'Cancelaciones con 15 dias de anticipacion',
              ],
            ),
            const SizedBox(height: 12),
            _InfoSection(
              title: 'Resenas destacadas',
              body:
                  '"Atencion impecable y montaje sin retrasos. Nos ayudaron a resolver todo el mismo dia."',
            ),
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
              priceLabel: service.priceLabel,
              onAdd: () {
                ClientFeedback.showMessage(
                  context,
                  message: 'Servicio agregado al carrito.',
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroGallery extends StatelessWidget {
  const _HeroGallery({required this.service});

  final ClientServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: <Color>[AppColors.appBar, AppColors.secondaryButton],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                right: 16,
                top: 16,
                child: _Badge(label: service.badge),
              ),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.appBarText.withValues(alpha: 0.8),
                  size: 56,
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
        const SizedBox(height: 10),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                width: 86,
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
        Text(service.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(service.subtitle),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            _RatingPill(),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                service.priceLabel,
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
  const _QuickFacts({required this.category});

  final ClientServiceCategory category;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: <Widget>[
        _FactChip(icon: Icons.location_on_rounded, label: 'Monterrey, N.L.'),
        _FactChip(icon: Icons.schedule_rounded, label: '8-10 horas'),
        _FactChip(icon: Icons.group_rounded, label: 'Hasta 350 invitados'),
        _FactChip(icon: category.icon, label: category.title),
      ],
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
              'Disponibilidad sugerida',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const <Widget>[
                _Pill(label: 'Vie 22 Mar'),
                _Pill(label: 'Sab 30 Mar'),
                _Pill(label: 'Dom 07 Abr'),
                _Pill(label: 'Sab 13 Abr'),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Selecciona una fecha para confirmar disponibilidad real.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, this.body, this.bullets});

  final String title;
  final String? body;
  final List<String>? bullets;

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

    if (bullets != null) {
      children.add(const SizedBox(height: 6));
      children.add(
        Column(
          children: bullets!
              .map(
                (String item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: AppColors.activeIcon,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      );
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
  const _BottomCta({required this.priceLabel, required this.onAdd});

  final String priceLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundElevated,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text('Agregar'),
            ),
          ],
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

class _RatingPill extends StatelessWidget {
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
          const Icon(Icons.star_rounded, size: 16, color: AppColors.appBar),
          const SizedBox(width: 4),
          Text(
            '4.9',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 4),
          Text('(128)', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardAccent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
