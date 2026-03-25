import 'package:festum/features/provider/models/product_form_data.dart';
import 'package:festum/features/provider/models/service_category.dart';

class CreateProviderProductRequest {
  const CreateProviderProductRequest({
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.pricingUnit,
    this.details = const <String, dynamic>{},
    this.inclusions = const <String, bool>{},
    this.policies = const <String, bool>{},
  });

  final ServiceCategory category;
  final String name;
  final String description;
  final double price;
  final String pricingUnit;
  final Map<String, dynamic> details;
  final Map<String, bool> inclusions;
  final Map<String, bool> policies;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'category': category.providerApiValue,
      'name': name.trim(),
      'description': description.trim(),
      'price': price,
      'pricing_unit': pricingUnit.trim(),
      if (details.isNotEmpty) 'details': details,
      if (inclusions.isNotEmpty) 'inclusions': inclusions,
      if (policies.isNotEmpty) 'policies': policies,
    };
  }

  factory CreateProviderProductRequest.fromForm({
    required ServiceCategory category,
    required ProductFormData formData,
  }) {
    return CreateProviderProductRequest(
      category: category,
      name: formData.name,
      description: formData.description,
      price: formData.price,
      pricingUnit: formData.pricingUnit,
      details: _buildDetails(category: category, formData: formData),
      inclusions: Map<String, bool>.from(formData.inclusions),
      policies: Map<String, bool>.from(formData.policies),
    );
  }
}

class UpdateProviderProductRequest {
  const UpdateProviderProductRequest({
    this.name,
    this.description,
    this.price,
    this.pricingUnit,
    this.details,
    this.inclusions,
    this.policies,
  });

  final String? name;
  final String? description;
  final double? price;
  final String? pricingUnit;
  final Map<String, dynamic>? details;
  final Map<String, bool>? inclusions;
  final Map<String, bool>? policies;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> payload = <String, dynamic>{};

    if (name != null) {
      payload['name'] = name!.trim();
    }
    if (description != null) {
      payload['description'] = description!.trim();
    }
    if (price != null) {
      payload['price'] = price;
    }
    if (pricingUnit != null) {
      payload['pricing_unit'] = pricingUnit!.trim();
    }
    if (details != null) {
      payload['details'] = details;
    }
    if (inclusions != null) {
      payload['inclusions'] = inclusions;
    }
    if (policies != null) {
      payload['policies'] = policies;
    }

    return payload;
  }

  factory UpdateProviderProductRequest.fromForm({
    required ServiceCategory category,
    required ProductFormData formData,
  }) {
    return UpdateProviderProductRequest(
      name: formData.name,
      description: formData.description,
      price: formData.price,
      pricingUnit: formData.pricingUnit,
      details: _buildDetails(category: category, formData: formData),
      inclusions: Map<String, bool>.from(formData.inclusions),
      policies: Map<String, bool>.from(formData.policies),
    );
  }
}

Map<String, dynamic> _buildDetails({
  required ServiceCategory category,
  required ProductFormData formData,
}) {
  final Map<String, dynamic> details = <String, dynamic>{};

  void addValue(String key, dynamic value) {
    if (value == null) {
      return;
    }
    if (value is String && value.trim().isEmpty) {
      return;
    }
    details[key] = value;
  }

  switch (category) {
    case ServiceCategory.dj:
    case ServiceCategory.entertainment:
      addValue('min_duration', formData.minDuration);
      addValue('extra_hour_allowed', formData.extraHourAllowed);
      addValue('extra_hour_price', formData.extraHourPrice);
      break;
    case ServiceCategory.photography:
      addValue('approx_photos', formData.approxPhotos);
      addValue('delivery_time', formData.deliveryTime);
      addValue('min_duration', formData.minDuration);
      addValue('extra_hour_allowed', formData.extraHourAllowed);
      addValue('extra_hour_price', formData.extraHourPrice);
      break;
    case ServiceCategory.banquet:
      addValue('banquet_type', formData.banquetType);
      addValue('min_guests', formData.minGuests);
      addValue('max_guests', formData.maxGuests);
      addValue('menu_included', formData.menuIncluded);
      break;
    case ServiceCategory.furniture:
    case ServiceCategory.equipment:
      addValue('stock', formData.stock);
      addValue('dimensions', formData.dimensions);
      addValue('weight', formData.weight);
      addValue('color_material', formData.colorMaterial);
      break;
    case ServiceCategory.venue:
      addValue('venue_capacity', formData.venueCapacity);
      addValue('is_price_per_hour', formData.isPricePerHour);
      break;
    case ServiceCategory.decoration:
      addValue('decoration_type', formData.decorationType);
      addValue('setup_time', formData.setupTime);
      break;
  }

  return details;
}
