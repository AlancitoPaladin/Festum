import 'package:festum/features/provider/models/service_category.dart';

class ServiceFormData {
  ServiceFormData({
    this.name = '',
    this.subtitle = '',
    this.description = '',
    this.priceLabel = '',
    this.badge = '',
    this.mainImageKey = '',
    this.imageKeys = const <String>[],
    this.category,
    this.unitPriceInput = '',
  });

  String name;
  String subtitle;
  String description;
  String priceLabel;
  String badge;
  String mainImageKey;
  List<String> imageKeys;
  ServiceCategory? category;
  String unitPriceInput;

  int get unitPriceCents => parseCurrencyToCents(unitPriceInput);

  ServiceFormData copyWith({
    String? name,
    String? subtitle,
    String? description,
    String? priceLabel,
    String? badge,
    String? mainImageKey,
    List<String>? imageKeys,
    ServiceCategory? category,
    String? unitPriceInput,
  }) {
    return ServiceFormData(
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      priceLabel: priceLabel ?? this.priceLabel,
      badge: badge ?? this.badge,
      mainImageKey: mainImageKey ?? this.mainImageKey,
      imageKeys: imageKeys ?? this.imageKeys,
      category: category ?? this.category,
      unitPriceInput: unitPriceInput ?? this.unitPriceInput,
    );
  }

  static int parseCurrencyToCents(String rawValue) {
    final String normalized = rawValue.trim().replaceAll('\$', '');
    if (normalized.isEmpty) {
      return 0;
    }

    final double? amount = double.tryParse(normalized.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      return 0;
    }

    return (amount * 100).round();
  }

  static String formatCentsToCurrencyInput(int cents) {
    if (cents <= 0) {
      return '';
    }

    final double amount = cents / 100;
    final String fixed = amount.toStringAsFixed(2);
    if (fixed.endsWith('.00')) {
      return fixed.substring(0, fixed.length - 3);
    }
    return fixed;
  }

  static List<String> parseImageKeys(String rawValue) {
    return rawValue
        .split(RegExp(r'[\n,]'))
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList();
  }

  static String stringifyImageKeys(List<String> imageKeys) {
    return imageKeys.join(', ');
  }
}
