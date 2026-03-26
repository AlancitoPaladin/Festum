class ProductFormData {
  String name;
  double price;
  String pricingUnit;
  String description;
  int stock;
  List<String> imageUrls;
  Map<String, bool> inclusions;
  Map<String, bool> policies;

  // Photography
  int? approxPhotos;
  String? deliveryTime;

  // Decoration
  String? decorationType;
  String? setupTime;

  // Banquet
  String? banquetType;
  int? minGuests;
  int? maxGuests;
  String? menuIncluded;

  // Furniture / Equipment
  String? dimensions;
  String? weight;
  String? colorMaterial;

  // Venue
  String? venueCapacity;
  bool isPricePerHour;

  // DJ / Entertainment
  String? minDuration;
  bool extraHourAllowed;
  double extraHourPrice;

  ProductFormData({
    this.name = '',
    this.price = 0,
    this.pricingUnit = 'Por evento',
    this.description = '',
    this.stock = 1,
    this.imageUrls = const [],
    this.inclusions = const {},
    this.policies = const {},
    this.approxPhotos,
    this.deliveryTime,
    this.decorationType = 'Boda',
    this.setupTime,
    this.banquetType = 'Buffet',
    this.minGuests,
    this.maxGuests,
    this.menuIncluded,
    this.dimensions,
    this.weight,
    this.colorMaterial,
    this.venueCapacity,
    this.isPricePerHour = false,
    this.minDuration,
    this.extraHourAllowed = false,
    this.extraHourPrice = 0,
  });

  static double parseDecimalInput(String rawValue) {
    final String sanitized = rawValue
        .trim()
        .replaceAll('\$', '')
        .replaceAll(RegExp(r'[^0-9.,]'), '');
    if (sanitized.isEmpty) {
      return 0;
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

    final String integerPart =
        (useDecimalSeparator
                ? sanitized.substring(0, separatorIndex)
                : sanitized)
            .replaceAll(RegExp(r'[^0-9]'), '');
    final String decimalPart = useDecimalSeparator ? tailDigits : '';

    if (integerPart.isEmpty && decimalPart.isEmpty) {
      return 0;
    }

    final String normalizedInteger = integerPart.isEmpty ? '0' : integerPart;
    final String normalized = decimalPart.isEmpty
        ? normalizedInteger
        : '$normalizedInteger.$decimalPart';
    return double.tryParse(normalized) ?? 0;
  }
}
