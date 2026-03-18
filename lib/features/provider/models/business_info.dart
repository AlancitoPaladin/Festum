class BusinessInfo {
  String name;
  String location;
  String coverageArea;
  String contactNumber;
  String whatsapp;
  String instagram;
  String facebook;
  String website;
  String? logoUrl;
  List<String> photoUrls;

  BusinessInfo({
    this.name = '',
    this.location = '',
    this.coverageArea = '',
    this.contactNumber = '',
    this.whatsapp = '',
    this.instagram = '',
    this.facebook = '',
    this.website = '',
    this.logoUrl,
    this.photoUrls = const [],
  });

  BusinessInfo copyWith({
    String? name,
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
    return BusinessInfo(
      name: name ?? this.name,
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
