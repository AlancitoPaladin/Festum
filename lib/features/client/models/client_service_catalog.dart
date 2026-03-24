import 'package:flutter/material.dart';

enum ClientServiceCategory {
  socialHalls(
    slug: 'salones-sociales',
    title: 'Salones sociales',
    icon: Icons.apartment_rounded,
  ),
  furniture(
    slug: 'mobiliario',
    title: 'Mobiliario',
    icon: Icons.chair_alt_rounded,
  ),
  banquets(
    slug: 'banquetes',
    title: 'Banquetes',
    icon: Icons.restaurant_menu_rounded,
  );

  const ClientServiceCategory({
    required this.slug,
    required this.title,
    required this.icon,
  });

  final String slug;
  final String title;
  final IconData icon;

  static ClientServiceCategory? fromSlug(String value) {
    for (final ClientServiceCategory category in values) {
      if (category.slug == value) {
        return category;
      }
    }
    return null;
  }
}

class ClientServiceItem {
  const ClientServiceItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.priceLabel,
    required this.unitPriceCents,
    required this.badge,
    this.displayNameShort,
    this.displaySubtitleShort,
  });

  final String id;
  final String name;
  final String subtitle;
  final String priceLabel;
  final int unitPriceCents;
  final String badge;
  final String? displayNameShort;
  final String? displaySubtitleShort;

  String get cardName => displayNameShort ?? _truncateForCard(name, 26);
  String get cardSubtitle =>
      displaySubtitleShort ?? _truncateForCard(subtitle, 34);

  String _truncateForCard(String value, int maxChars) {
    final String input = value.trim();
    if (input.length <= maxChars) {
      return input;
    }
    final int pivot = input.lastIndexOf(' ', maxChars);
    if (pivot <= 0) {
      return '${input.substring(0, maxChars - 1)}…';
    }
    return '${input.substring(0, pivot)}…';
  }
}

class ClientServiceCatalog {
  const ClientServiceCatalog._();

  static List<ClientServiceItem> servicesByCategory(
    ClientServiceCategory category,
  ) {
    return _catalog[category] ?? const <ClientServiceItem>[];
  }

  static ClientServiceItem? findService({
    required ClientServiceCategory category,
    required String serviceId,
  }) {
    for (final ClientServiceItem item in servicesByCategory(category)) {
      if (item.id == serviceId) {
        return item;
      }
    }
    return null;
  }

  static const Map<ClientServiceCategory, List<ClientServiceItem>> _catalog =
      <ClientServiceCategory, List<ClientServiceItem>>{
        ClientServiceCategory.socialHalls: <ClientServiceItem>[
          ClientServiceItem(
            id: 'hall-norte',
            name: 'Salón Norte Imperial',
            subtitle: 'Hasta 350 invitados',
            priceLabel: 'Desde \$45,000 MXN',
            unitPriceCents: 4500000,
            badge: 'Popular',
          ),
          ClientServiceItem(
            id: 'hall-bosque',
            name: 'Terraza Bosque Alto',
            subtitle: 'Formato jardín con pista',
            priceLabel: 'Desde \$38,500 MXN',
            unitPriceCents: 3850000,
            badge: 'Exterior',
          ),
          ClientServiceItem(
            id: 'hall-aurora',
            name: 'Salón Aurora',
            subtitle: 'Paquete completo con iluminación',
            priceLabel: 'Desde \$41,200 MXN',
            unitPriceCents: 4120000,
            badge: 'Premium',
          ),
        ],
        ClientServiceCategory.furniture: <ClientServiceItem>[
          ClientServiceItem(
            id: 'furn-lounge',
            name: 'Set Lounge Moderno',
            subtitle: '12 salas con mesas auxiliares',
            priceLabel: 'Desde \$12,400 MXN',
            unitPriceCents: 1240000,
            badge: 'Top',
          ),
          ClientServiceItem(
            id: 'furn-wood',
            name: 'Mobiliario Vintage Madera',
            subtitle: 'Mesas redondas y sillas',
            priceLabel: 'Desde \$9,800 MXN',
            unitPriceCents: 980000,
            badge: 'Vintage',
          ),
          ClientServiceItem(
            id: 'furn-led',
            name: 'Pista y Periqueras LED',
            subtitle: 'Montaje completo para noche',
            priceLabel: 'Desde \$14,600 MXN',
            unitPriceCents: 1460000,
            badge: 'Iluminado',
          ),
        ],
        ClientServiceCategory.banquets: <ClientServiceItem>[
          ClientServiceItem(
            id: 'banq-signature',
            name: 'Banquete Signature',
            subtitle: 'Menú gourmet personalizable',
            priceLabel: 'Desde \$740 p/p',
            unitPriceCents: 74000,
            badge: 'Chef',
          ),
          ClientServiceItem(
            id: 'banq-mex',
            name: 'Tradición Mexicana',
            subtitle: 'Estaciones y menú regional',
            priceLabel: 'Desde \$590 p/p',
            unitPriceCents: 59000,
            badge: 'Tradicional',
          ),
          ClientServiceItem(
            id: 'banq-sweet',
            name: 'Mesa Dulce y Postres',
            subtitle: 'Incluye montaje premium',
            priceLabel: 'Desde \$8,500 MXN',
            unitPriceCents: 850000,
            badge: 'Dulce',
          ),
        ],
      };
}
