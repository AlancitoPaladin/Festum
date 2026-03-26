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
    final String normalized = _normalizeCurrency(rawValue);
    if (normalized.isEmpty) {
      return 0;
    }

    final List<String> parts = normalized.split('.');
    final int whole = int.tryParse(parts.first) ?? 0;
    final String decimal = parts.length > 1 ? parts[1] : '';
    final int cents = int.tryParse(decimal.padRight(2, '0')) ?? 0;
    final int total = (whole * 100) + cents;
    if (total <= 0) {
      return 0;
    }

    return total;
  }

  static String formatCentsToCurrencyInput(int cents) {
    if (cents <= 0) {
      return '';
    }

    final double amount = cents / 100;
    final String fixed = amount.toStringAsFixed(2);
    final List<String> parts = fixed.split('.');
    final String formattedWhole = _withThousands(parts.first);
    if (parts.length == 1 || parts[1] == '00') {
      return formattedWhole;
    }
    return '$formattedWhole.${parts[1]}';
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

  static String _normalizeCurrency(String rawValue) {
    final String sanitized = rawValue
        .trim()
        .replaceAll('\$', '')
        .replaceAll(RegExp(r'[^0-9.,]'), '');
    if (sanitized.isEmpty) {
      return '';
    }

    final int lastDot = sanitized.lastIndexOf('.');
    final int lastComma = sanitized.lastIndexOf(',');
    final int separatorIndex = lastDot > lastComma ? lastDot : lastComma;
    final bool hasSeparator = separatorIndex >= 0;
    final String tailDigits = hasSeparator
        ? sanitized
              .substring(separatorIndex + 1)
              .replaceAll(RegExp(r'[^0-9]'), '')
        : '';
    final bool useDecimalSeparator = hasSeparator && tailDigits.length <= 2;

    final String wholePart =
        (useDecimalSeparator
                ? sanitized.substring(0, separatorIndex)
                : sanitized)
            .replaceAll(RegExp(r'[^0-9]'), '');
    String decimalPart = useDecimalSeparator ? tailDigits : '';
    if (decimalPart.length > 2) {
      decimalPart = decimalPart.substring(0, 2);
    }

    if (wholePart.isEmpty && decimalPart.isEmpty) {
      return '';
    }

    final String normalizedWhole = wholePart.isEmpty ? '0' : wholePart;
    if (decimalPart.isEmpty) {
      return normalizedWhole;
    }
    return '$normalizedWhole.$decimalPart';
  }

  static String _withThousands(String digits) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final int reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}
