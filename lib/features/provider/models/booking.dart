class Booking {
  final String id;
  final String customerName;
  final String customerImageUrl;
  final String customerPhone;
  final DateTime date;
  final String time;
  final String eventType;
  final int guests;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final String notes;

  Booking({
    required this.id,
    required this.customerName,
    required this.customerImageUrl,
    required this.customerPhone,
    required this.date,
    required this.time,
    required this.eventType,
    required this.guests,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    this.notes = '',
  });

  double get pendingAmount => totalAmount - paidAmount;
}
