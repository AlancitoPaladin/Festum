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
  ),
  dj(slug: 'dj', title: 'Musica / DJ', icon: Icons.music_note_rounded),
  decoration(
    slug: 'decoracion',
    title: 'Decoracion',
    icon: Icons.celebration_rounded,
  ),
  photography(
    slug: 'fotografia',
    title: 'Fotografia y video',
    icon: Icons.camera_alt_rounded,
  ),
  entertainment(
    slug: 'entretenimiento',
    title: 'Entretenimiento',
    icon: Icons.theater_comedy_rounded,
  ),
  uncategorized(slug: 'otros', title: 'Otros', icon: Icons.grid_view_rounded);

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
    this.description = '',
    required this.priceLabel,
    required this.unitPriceCents,
    required this.badge,
    this.products = const <ClientServiceProduct>[],
    this.imageKey = '',
    this.imageUrl = '',
    this.imageExpiresAt,
    this.displayNameShort,
    this.displaySubtitleShort,
  });

  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String priceLabel;
  final int unitPriceCents;
  final String badge;
  final List<ClientServiceProduct> products;
  final String imageKey;
  final String imageUrl;
  final DateTime? imageExpiresAt;
  final String? displayNameShort;
  final String? displaySubtitleShort;

  String get resolvedName {
    final String candidate = name.trim();
    return candidate.isEmpty ? 'Servicio sin nombre' : candidate;
  }

  String get resolvedSubtitle {
    final String candidate = subtitle.trim();
    return candidate.isEmpty ? 'Sin descripcion breve' : candidate;
  }

  String get resolvedPriceLabel {
    final String candidate = priceLabel.trim();
    if (candidate.isEmpty || _isQuoteOnlyLabel(candidate)) {
      if (unitPriceCents > 0) {
        return _buildPriceLabelFromCents(unitPriceCents);
      }
      return 'Precio por definir';
    }
    return candidate;
  }

  String get resolvedBadge {
    final String candidate = badge.trim();
    return candidate;
  }

  String get cardName => displayNameShort ?? _truncateForCard(resolvedName, 26);
  String get cardSubtitle =>
      displaySubtitleShort ?? _truncateForCard(resolvedSubtitle, 34);

  String _truncateForCard(String value, int maxChars) {
    final String input = value.trim();
    if (input.length <= maxChars) {
      return input;
    }
    final int pivot = input.lastIndexOf(' ', maxChars);
    if (pivot <= 0) {
      return '${input.substring(0, maxChars - 1)}...';
    }
    return '${input.substring(0, pivot)}...';
  }

  bool _isQuoteOnlyLabel(String value) {
    final String normalized = value.trim().toLowerCase();
    return normalized == 'cotiza' ||
        normalized == 'cotizar' ||
        normalized == 'precio por definir';
  }

  String _buildPriceLabelFromCents(int cents) {
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
}

class ClientServiceProduct {
  const ClientServiceProduct({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.description,
    required this.priceLabel,
    required this.unitPriceCents,
    required this.category,
    this.imageKey = '',
    this.imageUrl = '',
    this.imageExpiresAt,
  });

  final String id;
  final String serviceId;
  final String name;
  final String description;
  final String priceLabel;
  final int unitPriceCents;
  final String category;
  final String imageKey;
  final String imageUrl;
  final DateTime? imageExpiresAt;
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
            name: 'Salon Norte Imperial',
            subtitle: 'Hasta 350 invitados',
            priceLabel: 'Desde \$45,000 MXN',
            unitPriceCents: 4500000,
            badge: 'Popular',
          ),
          ClientServiceItem(
            id: 'hall-bosque',
            name: 'Terraza Bosque Alto',
            subtitle: 'Formato jardin con pista',
            priceLabel: 'Desde \$38,500 MXN',
            unitPriceCents: 3850000,
            badge: 'Exterior',
          ),
          ClientServiceItem(
            id: 'hall-aurora',
            name: 'Salon Aurora',
            subtitle: 'Paquete completo con iluminacion',
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
            subtitle: 'Menu gourmet personalizable',
            priceLabel: 'Desde \$740 p/p',
            unitPriceCents: 74000,
            badge: 'Chef',
          ),
          ClientServiceItem(
            id: 'banq-mex',
            name: 'Tradicion Mexicana',
            subtitle: 'Estaciones y menu regional',
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
        ClientServiceCategory.dj: <ClientServiceItem>[
          ClientServiceItem(
            id: 'dj-night',
            name: 'DJ Night Experience',
            subtitle: 'Audio, cabina e iluminacion',
            priceLabel: 'Desde \$6,500 MXN',
            unitPriceCents: 650000,
            badge: 'Party',
          ),
        ],
        ClientServiceCategory.decoration: <ClientServiceItem>[
          ClientServiceItem(
            id: 'deco-romance',
            name: 'Decoracion Romance',
            subtitle: 'Montaje floral y mesa principal',
            priceLabel: 'Desde \$9,900 MXN',
            unitPriceCents: 990000,
            badge: 'Romantico',
          ),
        ],
        ClientServiceCategory.photography: <ClientServiceItem>[
          ClientServiceItem(
            id: 'photo-cinema',
            name: 'Cobertura Foto y Video',
            subtitle: 'Sesion, teaser y entrega digital',
            priceLabel: 'Desde \$13,500 MXN',
            unitPriceCents: 1350000,
            badge: 'Cinema',
          ),
        ],
        ClientServiceCategory.entertainment: <ClientServiceItem>[
          ClientServiceItem(
            id: 'show-led',
            name: 'Show de Robots LED',
            subtitle: 'Apertura de pista y performance',
            priceLabel: 'Desde \$7,200 MXN',
            unitPriceCents: 720000,
            badge: 'Impacto',
          ),
        ],
      };
}
