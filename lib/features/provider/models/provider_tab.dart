import 'package:flutter/material.dart';

enum ProviderTab {
  home(
    label: 'Inicio',
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
  ),
  reservations(
    label: 'Reservas',
    icon: Icons.calendar_today_outlined,
    activeIcon: Icons.calendar_today,
  ),
  services(
    label: 'Servicios',
    icon: Icons.handyman_outlined,
    activeIcon: Icons.handyman,
  ),
  profile(
    label: 'Perfil',
    icon: Icons.person_outline,
    activeIcon: Icons.person,
  );

  const ProviderTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
