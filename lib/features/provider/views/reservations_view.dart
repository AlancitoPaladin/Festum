import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/custom_app_bar.dart';
import 'package:festum/features/provider/models/provider_tab.dart';
import 'package:festum/features/provider/viewmodels/reservations_viewmodel.dart';
import 'package:festum/features/provider/widgets/provider_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ReservationsView extends StatelessWidget {
  const ReservationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReservationsViewModel>.reactive(
      viewModelBuilder: () => ReservationsViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Gestión de reservas'),
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _AddServiceButton(onTap: model.addService),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: model.products.length,
                    itemBuilder: (context, index) {
                      final product = model.products[index];
                      return _ProductReservationCard(
                        product: product,
                        onDelete: () => model.deleteProduct(product.id),
                        onEdit: () => model.editProduct(product.id),
                        onManage: () => model.manageReservations(product.id),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ProviderBottomNavBar(
                currentTab: ProviderTab.reservations,
                onTabPressed: (tab) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddServiceButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddServiceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD1D5DB), // Color grisáceo del boceto
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Añadir servicio.',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _ProductReservationCard extends StatelessWidget {
  final ProductReservationSummary product;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onManage;

  const _ProductReservationCard({
    required this.product,
    required this.onDelete,
    required this.onEdit,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nombre del servidor', // Placeholder según boceto
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.black54),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          Container(
            height: 180,
            width: double.infinity,
            color: const Color(0xFFE5E7EB),
            child: const Icon(Icons.image_outlined, size: 64, color: Colors.black26),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  product.category.label,
                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  product.description,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: onEdit,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        side: const BorderSide(color: Colors.black12),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Editar', style: TextStyle(color: Colors.black87)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: onManage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B58AD), // Color morado del boceto
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Gestionar reservas', style: TextStyle(color: Colors.white)),
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
