class UpdateBookingRequest {
  const UpdateBookingRequest({
    this.customerName,
    this.eventDate,
    this.hasSpecificSchedule,
    this.startTime,
    this.endTime,
    this.eventType,
    this.guests,
    this.contactPhone,
    this.contactEmail,
    this.eventLocation,
    this.paymentDetails,
    this.totalAmount,
    this.paidAmount,
    this.notes,
  });

  final String? customerName;
  final DateTime? eventDate;
  final bool? hasSpecificSchedule;
  final String? startTime;
  final String? endTime;
  final String? eventType;
  final int? guests;
  final String? contactPhone;
  final String? contactEmail;
  final String? eventLocation;
  final String? paymentDetails;
  final double? totalAmount;
  final double? paidAmount;
  final String? notes;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> payload = <String, dynamic>{};

    if (customerName != null) {
      payload['customer_name'] = customerName!.trim();
    }
    if (eventDate != null) {
      payload['event_date'] = _formatDate(eventDate!);
    }
    if (hasSpecificSchedule != null) {
      payload['has_specific_schedule'] = hasSpecificSchedule;
    }
    if (startTime != null) {
      payload['start_time'] = startTime;
    }
    if (endTime != null) {
      payload['end_time'] = endTime;
    }
    if (eventType != null) {
      payload['event_type'] = eventType!.trim();
    }
    if (guests != null) {
      payload['guests'] = guests;
    }
    if (contactPhone != null) {
      payload['contact_phone'] = contactPhone!.trim();
    }
    if (contactEmail != null) {
      payload['contact_email'] = contactEmail!.trim();
    }
    if (eventLocation != null) {
      payload['event_location'] = eventLocation!.trim();
    }
    if (paymentDetails != null) {
      payload['payment_details'] = paymentDetails!.trim();
    }
    if (totalAmount != null) {
      payload['total_amount'] = totalAmount;
    }
    if (paidAmount != null) {
      payload['paid_amount'] = paidAmount;
    }
    if (notes != null) {
      payload['notes'] = notes!.trim();
    }

    return payload;
  }
}

String _formatDate(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
