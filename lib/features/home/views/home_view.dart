import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/home/viewmodels/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(title: const Text('Festum')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Setup inicial listo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(viewModel.statusMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.isBusy ? null : viewModel.checkApi,
                    child: Text(
                      viewModel.isBusy
                          ? 'Validando API...'
                          : 'Probar conexión API',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _ColorPreview(),
          const SizedBox(height: 16),
          Text(
            'Rive: agrega tus archivos .riv en assets/rive/ para comenzar animaciones.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}

class _ColorPreview extends StatelessWidget {
  const _ColorPreview();

  @override
  Widget build(BuildContext context) {
    final List<({String label, Color color})> palette = [
      (label: 'Fondo General', color: AppColors.background),
      (label: 'Top App Bar', color: AppColors.appBar),
      (label: 'Botón Primario', color: AppColors.primaryButton),
      (label: 'Botón Secundario', color: AppColors.secondaryButton),
      (label: 'Texto Principal', color: AppColors.primaryText),
      (label: 'Alertas', color: AppColors.alert),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: palette
              .map(
                (item) => SizedBox(
                  width: 150,
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: item.color,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.label,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
