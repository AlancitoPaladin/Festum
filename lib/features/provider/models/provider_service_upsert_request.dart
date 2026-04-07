import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/models/service_form_data.dart';

class ProviderServiceUpsertRequest {
  const ProviderServiceUpsertRequest({
    required this.category,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.unitPriceCents,
    required this.priceLabel,
    required this.badge,
    required this.mainImageKey,
    required this.imageKeys,
  });

  final ServiceCategory category;
  final String name;
  final String subtitle;
  final String description;
  final int unitPriceCents;
  final String priceLabel;
  final String badge;
  final String mainImageKey;
  final List<String> imageKeys;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'category': category.providerApiValue,
      'name': name.trim(),
      'subtitle': subtitle.trim(),
      'description': description.trim(),
      'unit_price_cents': unitPriceCents,
      'price_label': priceLabel.trim(),
      'badge': badge.trim(),
      'main_image_key': mainImageKey.trim(),
      'image_keys': imageKeys,
    };
  }

  factory ProviderServiceUpsertRequest.fromForm(ServiceFormData formData) {
    final int unitPriceCents = formData.unitPriceCents;
    return ProviderServiceUpsertRequest(
      category: formData.category!,
      name: formData.name,
      subtitle: formData.subtitle,
      description: formData.description,
      unitPriceCents: unitPriceCents,
      priceLabel: _buildPriceLabel(unitPriceCents),
      badge: _buildBadge(formData.category!),
      mainImageKey: formData.mainImageKey,
      imageKeys: List<String>.from(formData.imageKeys),
    );
  }

  static String _buildPriceLabel(int unitPriceCents) {
    if (unitPriceCents <= 0) {
      return 'Cotiza';
    }

    final double amount = unitPriceCents / 100;
    final String fixed = amount.toStringAsFixed(
      amount.truncateToDouble() == amount ? 0 : 2,
    );
    final List<String> parts = fixed.split('.');
    final String wholePart = parts.first;
    final StringBuffer buffer = StringBuffer();

    for (int index = 0; index < wholePart.length; index++) {
      final int reverseIndex = wholePart.length - index;
      buffer.write(wholePart[index]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    final String decimalPart = parts.length > 1 ? '.${parts.last}' : '';
    return 'Desde \$$buffer$decimalPart MXN';
  }

  static String _buildBadge(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.venue:
        return 'Espacio';
      case ServiceCategory.furniture:
      case ServiceCategory.equipment:
        return 'Renta';
      case ServiceCategory.banquet:
        return 'Catering';
      case ServiceCategory.dj:
        return 'Música';
      case ServiceCategory.decoration:
        return 'Decoración';
      case ServiceCategory.photography:
        return 'Foto y video';
      case ServiceCategory.entertainment:
        return 'Show';
    }
  }
}
