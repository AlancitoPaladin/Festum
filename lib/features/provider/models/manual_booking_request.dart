import 'package:flutter/material.dart';

class ManualBookingRequest {
  const ManualBookingRequest({
    required this.customerName,
    required this.customerImageUrl,
    required this.eventDate,
    required this.hasSpecificSchedule,
    required this.startTime,
    required this.endTime,
    required this.eventType,
    required this.guests,
    required this.contactPhone,
    required this.contactEmail,
    required this.eventLocation,
    required this.paymentDetails,
    required this.totalAmount,
    required this.paidAmount,
    required this.notes,
  });

  final String customerName;
  final String customerImageUrl;
  final DateTime eventDate;
  final bool hasSpecificSchedule;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String eventType;
  final int guests;
  final String contactPhone;
  final String contactEmail;
  final String eventLocation;
  final String paymentDetails;
  final double totalAmount;
  final double paidAmount;
  final String notes;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> payload = <String, dynamic>{
      'customer_name': customerName.trim(),
      'customer_image_url': customerImageUrl,
      'event_date': _formatDate(eventDate),
      'has_specific_schedule': hasSpecificSchedule,
      'event_type': eventType.trim(),
      'guests': guests,
      'contact_phone': contactPhone.trim(),
      'contact_email': contactEmail.trim(),
      'event_location': eventLocation.trim(),
      'payment_details': paymentDetails.trim(),
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'notes': notes.trim(),
    };

    if (hasSpecificSchedule) {
      payload['start_time'] = _formatTime(startTime);
      payload['end_time'] = _formatTime(endTime);
    } else {
      payload['start_time'] = null;
      payload['end_time'] = null;
    }

    return payload;
  }
}

String _formatDate(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String? _formatTime(TimeOfDay? time) {
  if (time == null) {
    return null;
  }
  final String hour = time.hour.toString().padLeft(2, '0');
  final String minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute:00';
}
