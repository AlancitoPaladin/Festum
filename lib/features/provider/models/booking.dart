class Booking {
  final String providerId;
  final String serviceId;
  final String serviceName;
  final String productId;
  final String productName;
  final String bookingId;
  final String id;
  final String customerName;
  final String customerImageUrl;
  final String customerPhone;
  final String contactEmail;
  final DateTime date;
  final bool hasExplicitEventDate;
  final String time;
  final String eventType;
  final int guests;
  final String eventLocation;
  final String paymentDetails;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final String source;
  final String status;
  final String rawStatus;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasValidEventDate => hasExplicitEventDate && date.year >= 2000;

  Booking({
    this.providerId = '',
    this.serviceId = '',
    this.serviceName = '',
    this.productId = '',
    this.productName = '',
    String? bookingId,
    required this.id,
    required this.customerName,
    required this.customerImageUrl,
    this.customerPhone = '',
    this.contactEmail = '',
    required this.date,
    this.hasExplicitEventDate = false,
    this.time = '',
    this.eventType = '',
    this.guests = 0,
    this.eventLocation = '',
    this.paymentDetails = '',
    this.totalAmount = 0,
    this.paidAmount = 0,
    double? pendingAmount,
    this.source = '',
    required this.status,
    String? rawStatus,
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  }) : bookingId = bookingId ?? id,
       pendingAmount = pendingAmount ?? (totalAmount - paidAmount),
       rawStatus = rawStatus ?? status;

  factory Booking.fromJson(Map<String, dynamic> json) {
    final String startTime = _readString(json, const <String>['start_time']);
    final String endTime = _readString(json, const <String>['end_time']);
    final String timeLabel = _readString(json, const <String>['time_label']);
    final DateTime? explicitEventDate = _readDateTime(json, const <String>[
      'event_date',
      'booking_date',
      'reservation_date',
    ]);
    final DateTime? fallbackDate = _readDateTime(json, const <String>['date']);
    return Booking(
      id: _readString(json, const <String>['id', 'booking_id']),
      bookingId: _readString(json, const <String>['booking_id', 'id']),
      providerId: _readString(json, const <String>['provider_id']),
      serviceId: _readString(json, const <String>['service_id']),
      serviceName: _readString(json, const <String>['service_name']),
      productId: _readString(json, const <String>['product_id']),
      productName: _readString(json, const <String>['product_name']),
      customerName: _readString(json, const <String>['customer_name']),
      customerImageUrl: _readImageUrl(json),
      customerPhone: _readString(json, const <String>[
        'contact_phone',
        'customer_phone',
        'phone',
      ]),
      contactEmail: _readString(json, const <String>['contact_email']),
      date:
          explicitEventDate ??
          fallbackDate ??
          DateTime.fromMillisecondsSinceEpoch(0),
      hasExplicitEventDate: explicitEventDate != null,
      time: timeLabel.isNotEmpty
          ? timeLabel
          : _mergeTimeRange(startTime, endTime),
      eventType: _readString(json, const <String>['event_type']),
      guests: _readInt(json, const <String>['guests']),
      eventLocation: _readString(json, const <String>['event_location']),
      paymentDetails: _readString(json, const <String>['payment_details']),
      totalAmount: _readDouble(json, const <String>['total_amount']),
      paidAmount: _readDouble(json, const <String>['paid_amount']),
      pendingAmount: _readDouble(json, const <String>['pending_amount']),
      source: _readString(json, const <String>['source']),
      status: _readString(json, const <String>['status_label', 'status']),
      rawStatus: _readString(json, const <String>['status', 'status_label']),
      notes: _readString(json, const <String>['notes']),
      createdAt: _readDateTime(json, const <String>['created_at']),
      updatedAt: _readDateTime(json, const <String>['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'provider_id': providerId,
      'service_id': serviceId,
      'service_name': serviceName,
      'product_id': productId,
      'product_name': productName,
      'id': id,
      'booking_id': bookingId,
      'customer_name': customerName,
      'customer_image_url': customerImageUrl,
      'contact_phone': customerPhone,
      'contact_email': contactEmail,
      'event_date': date.toIso8601String(),
      'has_explicit_event_date': hasExplicitEventDate,
      'time_label': time,
      'event_type': eventType,
      'guests': guests,
      'event_location': eventLocation,
      'payment_details': paymentDetails,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'pending_amount': pendingAmount,
      'source': source,
      'status': rawStatus,
      'status_label': status,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final String value = (json[key] ?? '').toString().trim();
    if (value.isNotEmpty) {
      return value;
    }
  }
  return '';
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final dynamic value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    final int? parsed = int.tryParse((value ?? '').toString());
    if (parsed != null) {
      return parsed;
    }
  }
  return 0;
}

double _readDouble(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final dynamic value = json[key];
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    final double? parsed = double.tryParse((value ?? '').toString());
    if (parsed != null) {
      return parsed;
    }
  }
  return 0;
}

DateTime? _readDateTime(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final String value = (json[key] ?? '').toString().trim();
    if (value.isEmpty) {
      continue;
    }
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}

String _readImageUrl(Map<String, dynamic> json) {
  final List<String> directKeys = <String>[
    'customer_image_url',
    'avatar_url',
    'image_url',
  ];
  for (final String key in directKeys) {
    final String value = (json[key] ?? '').toString().trim();
    if (value.isNotEmpty) {
      return value;
    }
  }

  final List<String> objectKeys = <String>['customer_image', 'avatar', 'image'];
  for (final String key in objectKeys) {
    final dynamic raw = json[key];
    if (raw is Map) {
      final Map<String, dynamic> object = Map<String, dynamic>.from(raw);
      final String value = (object['url'] ?? object['image_url'] ?? '')
          .toString()
          .trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
  }

  return '';
}

String _mergeTimeRange(String startTime, String endTime) {
  if (startTime.isEmpty && endTime.isEmpty) {
    return '';
  }
  if (startTime.isNotEmpty && endTime.isNotEmpty) {
    return '${_hhmm(startTime)} - ${_hhmm(endTime)}';
  }
  return _hhmm(startTime.isNotEmpty ? startTime : endTime);
}

String _hhmm(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  return trimmed.length >= 5 ? trimmed.substring(0, 5) : trimmed;
}
