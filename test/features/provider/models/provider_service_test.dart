import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProviderService.fromJson', () {
    test('maps provider payload with signed image object and published status', () {
      final ProviderService service = ProviderService.fromJson(
        <String, dynamic>{
          'id': 'service_123',
          'category': 'salones-sociales',
          'name': 'Salon Imperial',
          'subtitle': 'Hasta 250 invitados',
          'description': 'Paquete premium',
          'unit_price_cents': 125000,
          'price_label': 'Desde \$1,250 MXN',
          'badge': 'Popular',
          'status': 'published',
          'main_image_key': 'services/main.webp',
          'image_keys': <String>['services/main.webp', 'services/side.webp'],
          'image': <String, dynamic>{
            'key': 'services/main.webp',
            'url': 'https://cdn.example.com/services/main.webp',
            'expires_at': '2026-03-24T10:00:00Z',
          },
        },
      );

      expect(service.id, 'service_123');
      expect(service.category, ServiceCategory.venue);
      expect(service.isPublished, isTrue);
      expect(service.mainImageKey, 'services/main.webp');
      expect(service.imageKeys, <String>[
        'services/main.webp',
        'services/side.webp',
      ]);
      expect(service.resolvedImageUrl, 'https://cdn.example.com/services/main.webp');
    });

    test('normalizes legacy active status as published', () {
      final ProviderService service = ProviderService.fromJson(
        <String, dynamic>{
          'id': 'service_legacy',
          'category': 'banquetes',
          'name': 'Banquete Clasico',
          'subtitle': 'Menu para 100 personas',
          'unit_price_cents': 99000,
          'price_label': 'Desde \$990 MXN',
          'status': 'active',
        },
      );

      expect(service.category, ServiceCategory.banquet);
      expect(service.isPublished, isTrue);
      expect(service.isDraft, isFalse);
      expect(service.isInactive, isFalse);
    });
  });
}
