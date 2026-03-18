import 'package:festum/features/provider/models/service_category.dart';

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
}
