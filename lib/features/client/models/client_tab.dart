import 'package:festum/app/router/app_routes.dart';
import 'package:flutter/material.dart';

enum ClientTab {
  services(
    label: 'Servicios',
    route: AppRoutes.clientServices,
    icon: Icons.room_service_outlined,
    activeIcon: Icons.room_service,
  ),
  cart(
    label: 'Carrito',
    route: AppRoutes.clientCart,
    icon: Icons.shopping_bag_outlined,
    activeIcon: Icons.shopping_bag,
  ),
  orders(
    label: 'Mis órdenes',
    route: AppRoutes.clientOrders,
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long,
  );

  const ClientTab({
    required this.label,
    required this.route,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final String route;
  final IconData icon;
  final IconData activeIcon;
}
