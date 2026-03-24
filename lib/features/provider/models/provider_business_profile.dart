class ProviderBusinessProfile {
  const ProviderBusinessProfile({
    required this.providerId,
    required this.businessName,
    required this.location,
    required this.coverageArea,
    required this.contactNumber,
    required this.whatsapp,
    required this.instagram,
    required this.facebook,
    required this.website,
    required this.logoUrl,
    required this.photoUrls,
  });

  final String providerId;
  final String businessName;
  final String location;
  final String coverageArea;
  final String contactNumber;
  final String whatsapp;
  final String instagram;
  final String facebook;
  final String website;
  final String logoUrl;
  final List<String> photoUrls;

  factory ProviderBusinessProfile.fromJson(Map<String, dynamic> json) {
    return ProviderBusinessProfile(
      providerId: (json['provider_id'] ?? '').toString(),
      businessName: (json['business_name'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      coverageArea: (json['coverage_area'] ?? '').toString(),
      contactNumber: (json['contact_number'] ?? '').toString(),
      whatsapp: (json['whatsapp'] ?? '').toString(),
      instagram: (json['instagram'] ?? '').toString(),
      facebook: (json['facebook'] ?? '').toString(),
      website: (json['website'] ?? '').toString(),
      logoUrl: (json['logo_url'] ?? '').toString(),
      photoUrls:
          ((json['photo_urls'] as List<dynamic>? ?? <dynamic>[])
              .map((dynamic item) => item.toString())
              .toList()),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'business_name': businessName,
      'location': location,
      'coverage_area': coverageArea,
      'contact_number': contactNumber,
      'whatsapp': whatsapp,
      'instagram': instagram,
      'facebook': facebook,
      'website': website,
      'logo_url': logoUrl,
      'photo_urls': photoUrls,
    };
  }

  ProviderBusinessProfile copyWith({
    String? providerId,
    String? businessName,
    String? location,
    String? coverageArea,
    String? contactNumber,
    String? whatsapp,
    String? instagram,
    String? facebook,
    String? website,
    String? logoUrl,
    List<String>? photoUrls,
  }) {
    return ProviderBusinessProfile(
      providerId: providerId ?? this.providerId,
      businessName: businessName ?? this.businessName,
      location: location ?? this.location,
      coverageArea: coverageArea ?? this.coverageArea,
      contactNumber: contactNumber ?? this.contactNumber,
      whatsapp: whatsapp ?? this.whatsapp,
      instagram: instagram ?? this.instagram,
      facebook: facebook ?? this.facebook,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }
}
