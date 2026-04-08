import 'package:festum/features/provider/models/service_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServiceCategory mapping', () {
    test('maps frontend categories to backend slugs for services/products', () {
      expect(ServiceCategory.venue.providerApiValue, 'salones-sociales');
      expect(ServiceCategory.furniture.providerApiValue, 'mobiliario');
      expect(ServiceCategory.equipment.providerApiValue, 'mobiliario');
      expect(ServiceCategory.banquet.providerApiValue, 'banquetes');
    });

    test('parses both new slugs and legacy aliases from backend', () {
      expect(
        ServiceCategory.tryFromProviderApiValue('salones-sociales'),
        ServiceCategory.venue,
      );
      expect(
        ServiceCategory.tryFromProviderApiValue('mobiliario'),
        ServiceCategory.furniture,
      );
      expect(
        ServiceCategory.tryFromProviderApiValue('banquetes'),
        ServiceCategory.banquet,
      );
      expect(
        ServiceCategory.tryFromProviderApiValue('venue'),
        ServiceCategory.venue,
      );
      expect(
        ServiceCategory.tryFromProviderApiValue('furniture'),
        ServiceCategory.furniture,
      );
      expect(
        ServiceCategory.tryFromProviderApiValue('banquet'),
        ServiceCategory.banquet,
      );
    });
  });
}
